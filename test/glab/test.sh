#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "glab is available" glab --version
check "glab runs without authentication" glab help

reportResults
