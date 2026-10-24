#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "glab is installed as an RPM package" rpm -q glab
check "glab runs" glab --version

reportResults
