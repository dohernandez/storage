#-## Create/replace GitHub Actions from template

GO ?= go

#- Placeholders require include the file in the Makefile
#- require - bool64/dev/github-actions

## Inject/Replace GitHub Actions test db service
github-actions-test-db:
	@echo "Updating test-unit.yml"
	@bash $(STORAGE_DEVGO_SCRIPTS)/github-actions.sh

.PHONY: github-actions-test-db