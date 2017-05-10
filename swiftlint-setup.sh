#!/bin/bash

SWIFTLINT_VERSION=0.18.1

set -euf -o pipefail

download_error() {
  >&2 echo "error: Download failed."
  exit 1
}

rm -rf SwiftLint
mkdir SwiftLint
cd SwiftLint

echo Downloading SwiftLint $SWIFTLINT_VERSION...

BASEURL=https://github.com/realm/SwiftLint/releases/download
FILEURL=$BASEURL/$SWIFTLINT_VERSION/portable_swiftlint.zip 

curl -LOs $FILEURL || download_error

echo Unpacking...

unzip -q portable_swiftlint.zip
rm portable_swiftlint.zip

echo SwiftLint setup complete.
