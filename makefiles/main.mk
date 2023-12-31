GO ?= go

PWD = $(shell pwd)

# Detecting GOPATH and removing trailing "/" if any
GOPATH = $(realpath $(shell $(GO) env GOPATH))

ifneq "$(wildcard ./vendor )" ""
  modVendor = -mod=vendor
endif
export MODULE_NAME := $(shell test -f go.mod && GO111MODULE=on $(GO) list $(modVendor) -m)

STORAGE_DEVGO_PATH ?= $(PWD)/vendor/github.com/dohernandez/storage
STORAGE_DEVGO_SCRIPTS ?= $(STORAGE_DEVGO_PATH)/makefiles
