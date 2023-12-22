#-## Manage required postgresql tools
GO ?= go

## Check/install pg-isready tool
pg-isready-cli:
	@bash $(STORAGE_DEVGO_SCRIPTS)/pg_isready-cli.sh

## Check postgres service and database is up and running
pg-ready: pg_isready-cli
	@POSTGRES_TEST_HOST=$(POSTGRES_TEST_HOST) \
	POSTGRES_TEST_PORT=$(POSTGRES_TEST_PORT) \
	POSTGRES_TEST_USER=$(POSTGRES_TEST_USER) \
	POSTGRES_TEST_PASSWORD=$(POSTGRES_TEST_PASSWORD) \
	POSTGRES_TEST_DATABASE=$(POSTGRES_TEST_DATABASE) \
	DOCKER_POSTGRES_TAG=$(DOCKER_POSTGRES_TAG) \
	bash $(STORAGE_DEVGO_SCRIPTS)/pg-isready.sh

.PHONY: pg_isready-cli pg-isready