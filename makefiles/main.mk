GO ?= go

PWD = $(shell pwd)

# Checking vendor path using plugin variable: PLUGIN_DOHERNANDEZSTORAGE_VENDOR_PATH
ifeq ($(PLUGIN_DOHERNANDEZSTORAGE_VENDOR_PATH),)
	STORAGE_DEVGO_PATH = $(PLUGIN_DOHERNANDEZSTORAGE_VENDOR_PATH)
endif

ifeq ($(STORAGE_DEVGO_PATH),)
	STORAGE_DEVGO_PATH = $(PWD)
endif

STORAGE_DEVGO_SCRIPTS ?= $(STORAGE_DEVGO_PATH)/makefiles
