#!/bin/bash
rm -f nm.log ss.log client.log gdb_bt.txt ss_out.txt
./bin/naming_server &
NM_PID=$!
sleep 1

# Run SS under GDB, redirecting all output to ss_out.txt
gdb -x gdb_cmds.txt --args ./bin/storage_server > ss_out.txt 2>&1 &
SS_PID=$!
sleep 2

# Run client to trigger the crash
echo -e 'testuser\nCREATE testfile.txt\nEXIT\n' | ./bin/client > client.log 2>&1
sleep 2

# Cleanup
kill $NM_PID
kill $SS_PID 2>/dev/null
