.PHONY: help up down submit logs clean

help:
	@echo "Targets:"
	@echo "  make up                 Start platform"
	@echo "  make down               Stop platform"
	@echo "  make submit PROCESS=... DATA=..."
	@echo "  make logs JOB=<id>"

up:
	docker compose up -d

down:
	docker compose down

submit:
	@test -n "$(PROCESS)" || (echo "PROCESS missing"; exit 1)
	@test -n "$(DATA)" || (echo "DATA missing"; exit 1)
	docker compose run --rm login $(PROCESS) $(DATA)

logs:
	@test -n "$(JOB)" || (echo "JOB id missing"; exit 1)
	cat output/job_$(JOB).out

clean:
	rm -rf jobs/*.json output/*.out
