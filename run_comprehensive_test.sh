#!/bin/bash
rm -f nm.log ss.log client_comp.log
./bin/naming_server &
NM_PID=$!
sleep 1
./bin/storage_server &
SS_PID=$!
sleep 1

# Commands to send to client:
# 1. username
# 2. CREATE
# 3. INFO
# 4. WRITE testfile.txt 0
#   (Server replies "ACK: Write session started")
#   Wait, WRITE sends interactive commands!
#   Client reads from stdin for the interactive commands.
#   So we can just pipe everything!
# 5. 0 hello
# 6. 1 world
# 7. ETIRW
# 8. READ testfile.txt
# 9. DELETE testfile.txt
# 10. EXIT

cat << 'EOF' > test_commands.txt
testuser
CREATE testfile.txt
INFO testfile.txt
WRITE testfile.txt 0 SYNC
0 hello
1 world
ETIRW
READ testfile.txt
DELETE testfile.txt
EXIT
EOF

cat test_commands.txt | ./bin/client > client_comp.log 2>&1

sleep 1
kill $SS_PID
kill $NM_PID 2>/dev/null
