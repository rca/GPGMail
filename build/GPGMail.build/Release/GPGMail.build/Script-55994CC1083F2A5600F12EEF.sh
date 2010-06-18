#!/bin/sh
MAC_GPGME_FRAMEWORK_VERSION=1.1.4

chmod u+w "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}/Contents/Frameworks/MacGPGME.framework/Versions/${MAC_GPGME_FRAMEWORK_VERSION}/MacGPGME"
install_name_tool -id "@loader_path/../Frameworks/MacGPGME.framework/Versions/${MAC_GPGME_FRAMEWORK_VERSION}/MacGPGME" "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}/Contents/Frameworks/MacGPGME.framework/Versions/${MAC_GPGME_FRAMEWORK_VERSION}/MacGPGME"

# rewrite install_name in the app
install_name_tool -change "@executable_path/../Frameworks/MacGPGME.framework/Versions/${MAC_GPGME_FRAMEWORK_VERSION}/MacGPGME" "@loader_path/../Frameworks/MacGPGME.framework/Versions/${MAC_GPGME_FRAMEWORK_VERSION}/MacGPGME" "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}/Contents/MacOS/${PRODUCT_NAME}"

# remove headers and documentation
rm -rf "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}/Contents/Frameworks/MacGPGME.framework/Versions/${MAC_GPGME_FRAMEWORK_VERSION}/Headers"
rm -rf "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}/Contents/Frameworks/MacGPGME.framework/Versions/${MAC_GPGME_FRAMEWORK_VERSION}/PrivateHeaders"
rm -rf "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}/Contents/Frameworks/MacGPGME.framework/Versions/${MAC_GPGME_FRAMEWORK_VERSION}/Resources/English.lproj/Documentation"

