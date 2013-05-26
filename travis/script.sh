#!/bin/sh
set -e

# xctool -find-target SIStoreExampleTests test
xctool -workspace SIStoreExample.xcworkspace  -scheme SIStoreExample test