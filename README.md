# Secure-HPC-Platform-demo

## Objective
This repository presents a demonstrator of a secure computing platform for processing sensitive data.

The objective is to show how to provide research teams with a simple interface for running calculations on confidential data without directly exposing security mechanisms.

## Architecture (logical view)
- Login node: user interface (Ruby)
- Secure compute node: processing execution (Python)
- Secure storage: encrypted storage mounted on the host side

This architecture is simulated via Docker on a single machine.

The login node submits jobs and the compute node continuously processes them.

## Technologies
- Linux
- Docker / Docker Compose
- Ruby (orchestration)
- Python (data processing)
- Bash (secure storage setup)

## Limitations
This project is a functional demonstrator.

## Usage

Use the makefile to interact with the platform:

- `make up`: Start the platform.
- `make down`: Stop the platform.
- `make submit PROCESS=... DATA=...`: Submit a job where the process is an allowed Python script.
- `make logs JOB=<id>`: View the output of a job. The id is shown when submitting a job.

