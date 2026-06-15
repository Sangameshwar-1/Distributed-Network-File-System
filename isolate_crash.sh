#!/bin/bash
rm -f nm.log ss.log client_create.log client_info.log ss_out.txt
./bin/naming_server &
NM_PID=$!
sleep 1
./bin/storage_server > ss_out.txt 2>&1 &
SS_PID=$!
sleep 1

echo -e 'testuser\nCREATE testfile.txt\nEXIT\n' | ./bin/client > client_create.log 2>&1
sleep 1

kill $NM_PID
kill $SS_PID 2>/dev/null
