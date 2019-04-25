#!/system/bin/sh

# The patch details and latest version can be found at http://goo.gl/NRbCKN
# Please do not distribute this patch. Please link the URL above instead.
# credit to SimmoF
# https://forum.xda-developers.com/android/software-hacking/docomo-galaxy-lollipop-tethering-fix-t3307127

echo "\nSimmoF's Docomo Galaxy Lollipop Tethering Fix v.1\n"

busybox >/dev/null 2>/dev/null
if [ $? != 0 ]; then echo "Error: Please install BusyBox and try again.\n"; exit 1; fi
if [ $(busybox id -u) != 0 ] ; then echo "Error: This script must be executed with root privileges.\n"; exit 1; fi

mount -o rw,remount /system

echo Patching 'libsec-ril.so'...
false | busybox cp -i /system/lib/libsec-ril.so /system/lib/libsec-ril.so.bak 2>/dev/null
chmod 644 /system/lib/libsec-ril.so*
sed -e 's/dcmtrg.ne.jp,,,,,/,,,,,,,,,,,,,,,,,/' -i /system/lib/libsec-ril.so

echo Reading current apn settings...
for var in name apn proxy port user password server mmsc mmsproxy mmsport mcc mnc authtype; do
 var=$(content query --uri content://telephony/carriers/preferapn --projection $var)
 echo $var | cut -d0 -f2-
 apn+="$(echo $var | cut -d= -f2-),"
done

echo Setting tethering apn...
content insert --uri content://settings/secure --bind name:s:tether_dun_apn --bind value:s:$apn*

mount -o ro,remount /system 2>/dev/null

echo "Done.\n"

