#!/bin/bash
rm -f nm.log ss.log client.log
./bin/naming_server &
NM_PID=$!
sleep 1
./bin/storage_server &
SS_PID=$!
sleep 1

# Run client to test file creation and retrieval
echo -e 'testuser\nCREATE testfile.txt\nINFO testfile.txt\nEXIT\n' | ./bin/client > client.log 2>&1

# Kill servers
kill $SS_PID
kill $NM_PID
