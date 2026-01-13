# Secure-HPC-Platform-demo

## Objective
This repository presents a demonstrator of a secure computing platform for processing sensitive data.

The objective is to show how to provide research teams with a simple interface for running calculations on confidential data without directly exposing security mechanisms.

**This version is designed to prevent root from accessing sensitive data.** The changes from the `main` branch are in *italic*.

*No more temp file on compute node, the user only manipulates ciphered data protected by password.*

## Architecture (logical view)
- *Init node: user account creation (Ruby)*
- Login node: user interface (Ruby)
- Secure compute node: processing execution (Python)
- Secure storage: encrypted data manipulated by the compute node

This architecture is simulated via Docker on a single machine.

*The user begins by creating an account with an username and a password. There is no username verification for this demo.*
*On account creation, all the data is encrypted and stored in the secure storage (`database_enc`).*
The login node submits encrypted jobs and the compute node continuously processes them. A symmetric key is generated for each job.
*The data is first decrypted with the password and reciphered with the same key as the process script.*

Encryption method: AES-256-GCM

Storage: The user container and compute node have access to different volumes to simulate secure storage.
The user container has access to:
- `/data` (RO): Raw data that will be used for processing in this demo.
- *`/database_enc` (RO): Encrypted data that will be reciphered when submitted.*
- `/jobs_encrypted` (RW): Shared volume to share symmetric key and encrypted processing script. In a real use case, the key would not be stored.
- `/data_encrypted` (RW): Shared volume to store encrypted data. In a real use case, the data would be stored in a secure storage.

The compute node has access to:
- `/jobs_encrypted` (RO): To read the decipher key and encrypted processing script.
- `/data_encrypted` (RO): Encrypted data that will be processed.
- `/output` (RW): To store encrypted results that can be read by the user using the same key.


## Technologies
- Linux
- Docker / Docker Compose
- Ruby (orchestration)
- Python (data processing)
- Bash

## Limitations
This project is a functional demonstrator. The encrypted data are not deleted in this demo to allow verification through manual decryption. Do not use this project for production as the keys are stored raw and not transmitted securely.

*Only the password matters.*
*Every account has the same ciphered data. A real use case would require to select data to be ciphered.*
*Processing scripts are not ciphered with the password. It is more convenient this way for the user to edit it and the logic is already there if there is a need to cipher the scripts as well.*
*There is no physical access prevention. It's game over in that case.*
*Password can't be changed but you can just delete and recreate the account.*
*It is supposed that the `data` directory is NOT mounted on the user's machine. Data should come from another disk and potentially already ciphered upon creation.*

## Usage

Use the makefile to interact with the platform:

- `make up`: Start the platform.
- `make down`: Stop the platform.
- `make init`: Create an user account with ciphered data.
- `make submit PROCESS=... DATA=...`: Submit a job where the process is an allowed Python script.
- `make decrypt JOB=<id>`: View the encrypted files of a job. The id is shown when submitting a job.

## Quick Start
This project uses `uv` for dependency management.

Make sure Docker is installed and running.

```
# Install dependencies
uv sync
source .venv/bin/activate # Assuming your virtual environment is named .venv

# Start the platform
make up
make init
make submit PROCESS=processing/mean.py DATA=database_enc/users/USERNAME/db_YYYYMMDD_HHMMSS_XXXXXXXX/numbers.csv.enc
```
Then you can view the decrypted files with `make decrypt JOB=<id>`.

## What can be done
The following ideas can complete this demo.
- User permission management by adding a researcher role to submit jobs and an admin role to monitor compute nodes.
- Secure key transmission using a secure channel.
- *Username verification.*
