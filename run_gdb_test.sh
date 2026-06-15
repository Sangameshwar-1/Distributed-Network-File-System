#!/bin/bash
rm -f nm.log ss.log client.log
./bin/naming_server &
NM_PID=$!
sleep 1
gdb -batch -ex "run" -ex "bt" -ex "quit" --args ./bin/storage_server > gdb.log 2>&1 &
SS_PID=$!
sleep 1

# Run client
echo -e 'testuser\nCREATE testfile.txt\nINFO testfile.txt\nEXIT\n' | ./bin/client > client.log 2>&1

# Kill NM (SS is probably dead)
kill $NM_PID
