#-## Utilities for checking code includes checks postgresql instance ready

#- Placeholders source only check that the file exists
#- require - dev/check
#- require - self/pg

#- target-group - test
BEFORE_TEST_TARGETS += pg-ready

#- target-group - check
BEFORE_CHECK_TARGETS += pg-ready