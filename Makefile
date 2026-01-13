.PHONY: help up down submit logs clean

help:
	@echo "Targets:"
	@echo "  make up                 Start platform"
	@echo "  make down               Stop platform"
	@echo "  make submit PROCESS=... DATA=..."
	@echo "  make logs JOB=<id>"

up:
	docker compose build
	docker compose up -d

down:
	docker compose down

init:
	docker compose run --rm init

submit:
	@test -n "$(PROCESS)" || (echo "PROCESS missing"; exit 1)
	@test -n "$(DATA)" || (echo "DATA missing"; exit 1)
	docker compose run --rm login $(PROCESS) $(DATA)

decrypt:
	@test -n "$(JOB)" || (echo "JOB id missing"; exit 1)
	python decrypter.py $(JOB)

clean:
	rm -rf data_encrypted/job_*.csv.enc jobs_encrypted/job_*.key jobs_encrypted/job_*.py.enc output/job_*.out.enc database_enc/*
