GO ?= go

PWD = $(shell pwd)

# Detecting GOPATH and removing trailing "/" if any
GOPATH = $(realpath $(shell $(GO) env GOPATH))

STORAGE_DEVGO_PATH ?= $(PWD)/makefiles
STORAGE_DEVGO_SCRIPTS ?= $(STORAGE_DEVGO_PATH)
