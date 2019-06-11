#!/bin/bash

apt-get update && apt-get install -y curl

export TRAVIS_BUILD_DIR=/src
export HOME=/tmp

cd /src
echo "Installing test scripts"
./.travis/install-or1k-tests.sh

cd $HOME/src/tools

cd /src

echo "Running Job $JOB $SIM "
echo "Expected failures: $EXPECTED_FAILURES"

./.travis/run-${JOB}.sh