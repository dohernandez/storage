#GOLANGCI_LINT_VERSION := "v1.55.2" # Optional configuration to pinpoint golangci-lint version.

# The head of Makefile determines location of dev-go to include standard targets.
GO ?= go
export GO111MODULE = on

ifneq "$(wildcard ./vendor )" ""
  modVendor =  -mod=vendor
  ifeq (,$(findstring -mod,$(GOFLAGS)))
      export GOFLAGS := ${GOFLAGS} ${modVendor}
  endif
  ifneq "$(wildcard ./vendor/github.com/dohernandez/dev)" ""
  	EXTEND_DEVGO_PATH := ./vendor/github.com/dohernandez/dev
  endif
endif

ifeq ($(EXTEND_DEVGO_PATH),)
	EXTEND_DEVGO_PATH := $(shell GO111MODULE=on $(GO) list ${modVendor} -f '{{.Dir}}' -m github.com/dohernandez/dev)
	ifeq ($(EXTEND_DEVGO_PATH),)
    	$(info Module github.com/dohernandez/dev not found, downloading.)
    	EXTEND_DEVGO_PATH := $(shell export GO111MODULE=on && $(GO) get github.com/dohernandez/dev && $(GO) list -f '{{.Dir}}' -m github.com/dohernandez/dev)
	endif
endif

-include $(EXTEND_DEVGO_PATH)/makefiles/main.mk
-include $(EXTEND_DEVGO_PATH)/makefiles/recipe.mk

# Start extra recipes here.
-include $(PLUGIN_BOOL64DEV_MAKEFILES_PATH)/test-unit.mk
-include $(PLUGIN_BOOL64DEV_MAKEFILES_PATH)/lint.mk
-include $(PLUGIN_STORAGE_MAKEFILES_PATH)/pg.mk
-include $(PLUGIN_STORAGE_MAKEFILES_PATH)/github-actions.mk
-include $(PLUGIN_STORAGE_MAKEFILES_PATH)/check.mk
# End extra recipes here.

# DO NOT EDIT ANYTHING BELOW THIS LINE.

# Add your custom targets here.

.PHONY:
