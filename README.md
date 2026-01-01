# Secure-HPC-Platform-demo

## Objective
This repository presents a demonstrator of a secure computing platform for processing sensitive data.

The objective is to show how to provide research teams with a simple interface for running calculations on confidential data without directly exposing security mechanisms.

## Architecture (logical view)
- Login node: user interface (Ruby CLI)
- Secure compute node: processing execution (Python)
- Secure storage: encrypted storage mounted on the host side

This architecture is simulated via Docker on a single machine.

## Technologies
- Linux
- Docker / Docker Compose
- Ruby (orchestration, CLI)
- Python (data processing)
- Bash (secure storage setup)

## Limitations
This project is a functional demonstrator.
