#!/bin/bash
rm -f nm.log ss.log client.log gdb_bt.txt
./bin/naming_server &
NM_PID=$!
sleep 1

# Run SS under GDB
gdb -batch -ex "run" -ex "bt" --args ./bin/storage_server > gdb_bt.txt 2>&1 &
SS_PID=$!
sleep 2

# Run client
echo -e 'testuser\nCREATE testfile.txt\nEXIT\n' | ./bin/client > client.log 2>&1
sleep 2

# Cleanup
kill $NM_PID
kill $SS_PID
