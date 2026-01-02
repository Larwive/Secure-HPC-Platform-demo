# Secure-HPC-Platform-demo

## Objective
This repository presents a demonstrator of a secure computing platform for processing sensitive data.

The objective is to show how to provide research teams with a simple interface for running calculations on confidential data without directly exposing security mechanisms.

## Architecture (logical view)
- Login node: user interface (Ruby)
- Secure compute node: processing execution (Python)
- Secure storage: encrypted data manipulated by the compute node

This architecture is simulated via Docker on a single machine.

The login node submits encrypted jobs and the compute node continuously processes them. A symmetric key is generated for each job.

Encryption method: AES-256-GCM

Storage: The user container and compute node have access to different volumes to simulate secure storage.
The user container has access to:
- `/data` (RO): Raw data that will be used for processing in this demo.
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

## Usage

Use the makefile to interact with the platform:

- `make up`: Start the platform.
- `make down`: Stop the platform.
- `make submit PROCESS=... DATA=...`: Submit a job where the process is an allowed Python script.
- `make decrypt JOB=<id>`: View the encrypted files of a job. The id is shown when submitting a job.

## Quick Start
This project uses `uv` for dependency management.

```
uv sync
make up
make submit PROCESS=processing/mean.py DATA=data/numbers.csv
```
Then you can view the decrypted files with `make decrypt JOB=<id>`.

## What can be done
The following ideas can complete this demo.
- User permission management by adding a researcher role to submit jobs and an admin role to monitor compute nodes.
- Secure key transmission using a secure channel.