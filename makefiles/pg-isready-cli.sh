#!/usr/bin/env bash

install_pg_isready () {
  case "$1" in
        Darwin*)
          {
            brew install libpq
            brew link --force libpq
          };;
        *)
          {
            echo "Unsupported OS, exiting"
            exit 1
          } ;;
    esac
}

osType="$(uname -s)"

# checking if pg_isready is available
if ! command -v pg_isready > /dev/null; then \
    echo ">> Installing pg_isready ..."; \
    install_pg_isready "$osType"
fi
