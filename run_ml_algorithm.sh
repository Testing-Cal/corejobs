cd "${DIRECTORY}"

echo "${NOTEBOOKS}" | jq -c '.[]' | while read -r obj; do
    notebook=$(echo "$obj" | jq -r '.name')
    # if [[ -n "$CONNECTION_DETAILS" ]]; then
    #     yaml_output=$(echo "$CONNECTION_DETAILS" | jq -r 'to_entries[] | "\(.key): \(.value | tostring)"')
    #     echo "$yaml_output" > run_parameters.yaml
    #     yaml_output=$(echo "$obj" | jq -r 'to_entries[] | "\(.key): \(.value | tostring)"')
    #     echo "$yaml_output" >> run_parameters.yaml
    #     echo "Added run notebook parameters in Yaml file."
    # else
    #     echo "No data !!!"
    # fi

    str="${notebook::-6}"
    echo "Processing ${str}"

    startTime=$(date +%s%3N)
    # papermill "${notebook}" "${notebook}" -f run_parameters.yaml
    jupyter nbconvert --execute --to notebook --inplace "${notebook}"
    response="$?"
    if [[ "${response}" != "0" ]]; then
        echo "Error occurred in notebook compilation"
        echo "Notebook execution status=${str}:FAILED,$(($(date +%s%3N)-$startTime))"
        continueOnFailure=$(echo "$obj" | jq -r '.continueOnFailure')
        if [[ -n "$continueOnFailure" ]] && $continueOnFailure ; then
            echo "Continue on failure!!"
        else
            exit "${response}"
        fi
    else
        echo "Notebook execution status=${str}:SUCCESS,$(($(date +%s%3N)-$startTime))"
    fi
    
    MLOUTPUT_FILE="/tmp/mldeployoutput.log"
    echo "http://${DOCKERHOST}:${APPSERVER_PORT}/visualization-dashboard"
    curl -v -X POST -F model_name="${str}" "http://${DOCKERHOST}:${APPSERVER_PORT}/visualization-dashboard" > "${MLOUTPUT_FILE}" 2>&1
    response="$?"
    mlOutputStatusCode=$(cat "${MLOUTPUT_FILE}" | grep -oE '< HTTP/1.1 200 OK')
    #cat "${MLOUTPUT_FILE}"
    echo ""
    echo "Visualization Dashboard Post call process response : $response"
    echo "Visualization Dashboard Output Status : $mlOutputStatusCode"
    if [[ "${response}" != "0" || "${mlOutputStatusCode}" != '< HTTP/1.1 200 OK' ]]; then
        echo "Error occurred in uploading code to visualization endpoint"
        exit 1
    fi

done
