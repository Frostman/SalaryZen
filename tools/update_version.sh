#!/usr/bin/env bash

# Should be manually added to all targets
# Editor > Add Build Phase > Add Run Script Build Phase

set -x

APP_VERSION=$(git describe --always --dirty)
COMMITS_COUNT=$(git rev-list HEAD | wc -l)
APP_BUILD=$(($COMMITS_COUNT))

if [ "${CONFIGURATION}" != "Release" ]; then
    TS_SINCE=$(date -u -j -f %y-%M-%d 15-1-1 +%s)
    TS_NOW=$(date +%s)
    APP_BUILD=$APP_BUILD.$(expr $TS_NOW - $TS_SINCE)
fi

echo "App version (CFBundleShortVersionString): ${APP_VERSION#*v}"
echo "App build (CFBundleVersion): ${APP_BUILD}"

defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleShortVersionString" "${APP_VERSION#*v}"
defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleVersion" "${APP_BUILD}"