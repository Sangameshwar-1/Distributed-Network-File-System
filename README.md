# Distributed Network File System (NFS)

A custom, distributed Network File System (NFS) implemented in C. This project simulates a highly scalable file system environment composed of three main components: a central **Naming Server**, multiple distributed **Storage Servers**, and end-user **Clients**.

## How It Works (Architecture & Flow)

The system is built on a scalable 3-tier architecture designed to decouple metadata management from heavy file I/O operations.

1. **Naming Server (NM):** 
   - Acts as the central registry and directory service. 
   - When a Storage Server starts, it dynamically registers itself with the NM.
   - Maintains a fast distributed Hashmap of all files and their corresponding Storage Servers.
   - Enforces Access Control Lists (ACLs) to ensure only authorized users can read or write files.
   - Utilizes an LRU (Least Recently Used) cache to dramatically speed up frequent file location lookups.
   - Does *not* handle file contents directly. Instead, it responds to the Client with the IP and Port of the appropriate Storage Server.

2. **Storage Server (SS):**
   - The servers that physically hold the file data.
   - Communicates with the NM for registration and receives replication commands.
   - Opens an independent listener port to process high-throughput commands directly from the Client (Read, Write, Execute, Stream, Delete).
   - Implements fine-grained concurrency: it utilizes sentence-level POSIX Read-Write locks (`pthread_rwlock`), allowing multiple clients to read/write to different parts of the same file simultaneously without corruption.

3. **Client:**
   - The interactive interface for end-users.
   - The Client initiates contact with the NM. If authorized, the NM hands over the `SS_INFO` (IP and port).
   - The Client seamlessly opens a direct socket to the Storage Server for data transfer, meaning the Naming Server never becomes a bottleneck for large file operations.

## Features Supported

* **Core File Operations:** Create, Read, Write, Delete, and Info.
* **Concurrency:** Fine-grained sentence-level concurrency controls. Concurrent reads are fully supported. Writes can optionally be asynchronous.
* **Directory Operations:** Creation of directories (`MKDIR`) and listing contents (`LSDIR`).
* **Advanced File Interaction:**
  * **UNDO:** Revert the most recent file changes using hidden backup states.
  * **STREAM:** Stream large media or text files in chunks from the Storage Server to the Client without overwhelming memory.
  * **EXEC:** Trigger remote execution of bash/binary files on the Storage Server and receive standard output over the network.
* **High Availability & Reliability:**
  * **Replication:** Asynchronous replication triggered on file creation/write to duplicate files across Storage Servers for fault tolerance.
* **User Security & Permissions:**
  * User authentication and file-level authorization. The creator is implicitly granted access, and can use `GRANT` to share access with others.
* **Naming Server Search:** Allows substring-based searching of files and directories across all active Storage Servers (`SEARCH`).

## Compilation

The project uses a standard Makefile for easy compilation. Ensure you have `gcc` and `make` installed in your POSIX environment (e.g., Linux, WSL, macOS).

```bash
# Compile all components (Naming Server, Storage Server, Client)
make
```

*This will generate the executable binaries in the `bin/` directory.*

## Usage Guide (Step-by-Step)

Here is a full walkthrough of how to run the architecture and interact with the system.

### 1. Start the Servers
You must start the Naming Server first, followed by one (or more) Storage Servers. Open different terminal windows for each:

**Terminal 1 (Naming Server):**
```bash
./bin/naming_server
# Listens for SS on port 8080 and Clients on 8082
```

**Terminal 2 (Storage Server):**
```bash
./bin/storage_server
# Automatically registers with the NM and opens a client-listener on port 8180
```

### 2. Connect a Client
Open a third terminal and launch the client REPL interface:
```bash
./bin/client
```

### 3. Client Interaction Example
Once the client starts, you will be prompted for a username. The system dynamically creates a session for you. 
```text
Enter your username: testuser
[INFO] Client started and connected to NM for user: testuser
```

You must explicitly register your user with the Naming Server, and then you can begin executing commands:

```text
Client> ADDUSER testuser
USER_ADDED

Client> CREATE mydocument.txt
CREATE Successful!

Client> WRITE mydocument.txt 0 SYNC
ACK: Write session started
Client (WRITE mydocument.txt)> 0 Hello
ACK: Word inserted
Client (WRITE mydocument.txt)> 1 World!
ACK: Word inserted
Client (WRITE mydocument.txt)> ETIRW
Write Successful!

Client> READ mydocument.txt
--- File Content (mydocument.txt) ---
Hello World!. 
--- End of File ---

Client> INFO mydocument.txt
Size: 13 bytes
Permissions: 777

Client> EXIT
```

## Supported Client Commands Reference

- `ADDUSER <username>`: Register a new user with the Naming Server.
- `LOGIN <username>`: Login to an existing user session.
- `CREATE <filename>`: Create a new empty file.
- `READ <filename>`: Read the contents of a file.
- `WRITE <filename> <sentence_index> [SYNC|ASYNC]`: Enter interactive mode to insert words into a specific sentence block. Type `ETIRW` to save and exit.
- `DELETE <filename>`: Delete a file permanently.
- `UNDO <filename>`: Revert the file to its state before the last WRITE operation.
- `INFO <filename>`: Fetch metadata (size, permissions) of a file.
- `STREAM <filename>`: Stream the contents of a file in continuous chunks.
- `EXEC <filename>`: Execute a remote script file and retrieve its output.
- `MKDIR <dirname>`: Create a new directory.
- `LSDIR <dirname>`: List contents of a directory.
- `SEARCH <substring>`: Search across the distributed hashmap for specific file patterns.
- `GRANT <filename> <username>`: Grant access to a file you own to another user.
