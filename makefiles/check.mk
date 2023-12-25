#-## Utilities for checking code includes checks postgresql instance ready

#- Placeholders source only check that the file exists
#- require - bool64/dev/lint
#- require - bool64/dev/test-unit

## Run tests
test: test-unit

## Run checks (pg-isready lint, test)
check: pg-ready lint test

.PHONY: test check