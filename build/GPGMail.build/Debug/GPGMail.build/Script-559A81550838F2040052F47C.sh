#!/bin/sh
myRez="/tmp/Icon.r"
format1='"    $@"'
format2='"%04X "'
format3='"@\n"'
myDest="${TARGET_BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}"
directoryImageFile=`echo Iconr | tr r "\r"`

rm -rf "${myRez}"

echo "data 'icns' (-16455) {" > "${myRez}"
hexdump -v -e " ${format1} 8/2 ${format2} ${format3}" "${SRCROOT}/MacOSX/GPGMail.icns" | tr '@' '"' >> "${myRez}"
echo '};' >> "${myRez}"

/Developer/Tools/Rez "${myRez}" -o "${myDest}/${directoryImageFile}"
/Developer/Tools/SetFile -c "MACS" -t "icon" -a V "${myDest}/${directoryImageFile}"
/Developer/Tools/SetFile -a BCE "${myDest}"
echo Modified "${myDest}"
#/usr/sbin/chown "${INSTALL_OWNER}:${INSTALL_GROUP}" "${myDest}/${directoryImageFile}"
#/bin/chmod "${INSTALL_MODE_FLAG}" "${myDest}/${directoryImageFile}"
rm -rf "${myRez}"

