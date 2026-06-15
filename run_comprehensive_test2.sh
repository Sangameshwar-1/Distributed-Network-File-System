#!/bin/bash
rm -f nm.log ss.log client_comp.log test_commands.txt
./bin/naming_server &
NM_PID=$!
sleep 1
./bin/storage_server &
SS_PID=$!
sleep 1

# Make sure we use \n and not \r\n
printf "testuser\nCREATE testfile.txt\nINFO testfile.txt\nWRITE testfile.txt 0\n0 hello\n1 world\nETIRW\nREAD testfile.txt\nDELETE testfile.txt\nEXIT\n" > test_commands.txt

./bin/client < test_commands.txt > client_comp.log 2>&1

sleep 1
kill $SS_PID
kill $NM_PID 2>/dev/null
