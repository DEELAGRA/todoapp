include .env
export

export PROJECT_ROOT=$(shell pwd) 



env-up:
	@docker compose up -d todoapp-postgres
env-down:
	@docker compose down todoapp-postgres
env-cleanup:
	@ read -p "Clear all volume environment files? Risk of data loss. [Y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down todoapp-postgres && \
		rm -rf out/pgdata && \
		echo "Environment files deleted"; \
	else \
		echo "File deletion canceled"; \
	fi
migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "The required parameter 'seq' is missing. Example: make migrate-create seq=init"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		create \
			-dir /migrations \
			-ext sql \
			-seq "$(seq)"
	


migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "The required parameter 'action' is missing. Example: make migrate-action action=up/down"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate\
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"