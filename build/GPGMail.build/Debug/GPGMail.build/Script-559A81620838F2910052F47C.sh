#!/bin/sh
# Cleanup of files

# Remove framework headers
find -d "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}/Contents/Frameworks/MacGPGME.framework/" \( -name Headers -o -name PrivateHeaders \) -exec rm -rf {} \;

# Avoid having write privileges for anyone but owner
chmod -R go-w "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}"

