#-## Create/replace GitHub Actions from template

GO ?= go

#- Placeholders require include the file in the Makefile
#- require - dev/github-actions

AFTER_GITHUB_ACTIONS_TARGETS += github-actions-test-db

## Inject/Replace GitHub Actions test db service
github-actions-test-db:
	@echo "Updating test-unit.yml"
	@bash $(STORAGE_DEVGO_SCRIPTS)/github-actions.sh

.PHONY: github-actions-test-db