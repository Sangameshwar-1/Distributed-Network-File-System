#!/bin/bash
rm -f nm.log ss.log client_comp.log
./bin/naming_server &
NM_PID=$!
sleep 1
./bin/storage_server &
SS_PID=$!
sleep 1

printf "testuser\nADDUSER testuser\nCREATE test_script.sh\nEXEC test_script.sh\nSTREAM test_script.sh\nEXIT\n" > test_commands2.txt

stdbuf -o0 ./bin/client < test_commands2.txt > client_comp2.log 2>&1

sleep 1
kill $SS_PID
kill $NM_PID 2>/dev/null
