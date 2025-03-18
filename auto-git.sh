#!/usr/bin/expect -f

set timeout 120
set argsCount [llength $argv]
lassign $argv arg1 arg2 arg3 arg4 arg5

if { $argsCount == 1} {
    spawn git $arg1 
} elseif { $argsCount == 2} {
    spawn git $arg1 $arg2
} elseif { $argsCount == 3} {
    spawn git $arg1 $arg2 $arg3
} elseif { $argsCount == 4} {
    spawn git $arg1 $arg2 $arg3 $arg4
} elseif { $argsCount == 5} {
    spawn git $arg1 $arg2 $arg3 $arg4 $arg5
} else {
    send_user "expected at least 1 and at most 5 arguments\n"
    exit
}

expect {
     -re "Username for " {
        send -- "${env(GIT_REPOSITORY_USERNAME)}\n"
        expect -re "Password for " {
            send -- "${env(GIT_REPOSITORY_TOKEN)}\n"
        }
        expect eof
    }
    eof
}


send_user "\n"
