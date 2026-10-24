#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "glab binary is executable" test -x /usr/local/bin/glab
check "glab runs" /usr/local/bin/glab --version

reportResults
