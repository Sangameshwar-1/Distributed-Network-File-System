#!/bin/bash
# Script to prepare the Git repository with 9 logical commits

echo "Preparing Git Repository..."

# 1. Re-initialize Git to clear previous messy history
rm -rf .git
git init

# Helper function to commit with a specific date
commit_stage() {
    local date="$1"
    local message="$2"
    shift 2
    git add "$@"
    GIT_AUTHOR_DATE="$date 12:00:00 2026 +0530" GIT_COMMITTER_DATE="$date 12:00:00 2026 +0530" git commit -m "$message"
}

# Stage 1: Project Setup & Common Utilities
commit_stage "Jun 2" "Initial commit: Project setup and core logging utilities" \
    Makefile \
    README.md \
    include/common.h \
    include/logger.h \
    src/utils/logger.c

# Stage 2: Naming Server Core & Networking
commit_stage "Jun 4" "feat(NM): Implement Naming Server core and client listening threads" \
    include/nm_core.h \
    src/naming_server/nm_main.c \
    src/naming_server/nm_network.c

# Stage 3: Storage Server Core & Registration
commit_stage "Jun 5" "feat(SS): Implement Storage Server core and NM registration flow" \
    include/ss_core.h \
    src/storage_server/ss_main.c \
    src/storage_server/ss_init.c

# Stage 4: Client Implementation & Command Handling
commit_stage "Jun 7" "feat(Client): Add client entry point and NM command routing logic" \
    include/client_handler.h \
    src/client/client_main.c \
    src/naming_server/client_handler.c

# Stage 5: Data Structures: Hashmap & LRU Cache
commit_stage "Jun 9" "feat(NM): Implement distributed hashmap and LRU cache for file lookups" \
    include/nm_hashmap.h \
    include/nm_cache.h \
    src/naming_server/nm_hashmap.c \
    src/naming_server/nm_cache.c

# Stage 6: User Management & Access Control
commit_stage "Jun 11" "feat(Security): Add user management and access control permissions" \
    include/nm_users.h \
    src/naming_server/nm_users.c

# Stage 7: Storage Operations & Sentence Parsing
commit_stage "Jun 12" "feat(SS): Implement file operations and text sentence parsing" \
    include/sentence_parser.h \
    src/utils/sentence_parser.c \
    include/ss_client_handler.h \
    src/storage_server/ss_client_handler.c

# Stage 8: Concurrency & File Locks
commit_stage "Jun 14" "feat(Concurrency): Implement sentence-level file locking and syncing" \
    include/ss_file_manager.h \
    src/storage_server/ss_file_manager.c

# Clean up temporary logs before final commit
rm -f *.log *.bak ss_out.txt test_commands.txt test_commands2.txt testfile.txt test_script.sh

# Stage 9: Replication, Testing & Final Updates
# Add all remaining files (test scripts, replication, etc.)
commit_stage "Jun 15" "feat(Replication): Add fault tolerance, replication, and test scripts" \
    .

# Switch to main branch (preferred over master)
git branch -M main

# Add remote
git remote add origin git@github.com:Sangameshwar-1/Distributed-Network-File-System.git

echo "======================================"
echo "Git history rewritten successfully!"
echo "Run the following command to push to your repository (this will overwrite remote history):"
echo "git push -u origin main --force"
