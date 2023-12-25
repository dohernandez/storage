#-## Create/replace GitHub Actions from template

GO ?= go

#- dev/github-actions => EXTEND_DEVGO_PATH/makefiles/github-actions.mk
#- Placeholders source only check that the file exists
#- source a dev/github-actions

## Create/Replace GitHub Actions from template
github-actions:
	@make -f $(EXTEND_DEVGO_PATH)/makefiles/github-actions.mk $@
	@echo "Updating test-unit.yml"
	@bash $(STORAGE_DEVGO_SCRIPTS)/github-actions.sh

.PHONY: github-actions