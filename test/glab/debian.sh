#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "glab is installed as a Debian package" dpkg-query -W glab
check "glab runs" glab --version

reportResults
