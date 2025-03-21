echo "Running notebooks:"
pgrep -af papermill
notebooksObj=$(echo "$NOTEBOOKS" | jq -r '.notebooks')
echo "${notebooksObj}" | jq -c '.[]' | while read -r obj; do
    notebook=$(echo "$obj" | jq -r '.name')
    echo "Terminating notebook run: ${notebook}"
    PID=$(ps aux | grep papermill | grep ''${notebook}'' | awk '{print $2}')
    kill ${PID}
    echo "kill process ID: ${PID}"
done
echo "Notebook termination completed !!"
