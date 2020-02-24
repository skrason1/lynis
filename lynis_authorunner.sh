#!/bin/sh

#  This script will automatically:
#     * download [Lynis](https://cisofy.com/lynis/), an open source security auditing tool
#     * run a full audit check, either privileged, or non-privileged if not logged in as root
#     * cleanup by removing the downloaded archive, and the extracted directory it ran out of
#     * save the audit report to your local directory (YYYYMMDD-lynis-report)
#
#  This script requires:
#     * awk
#     * tar
#     * curl
#     * sha256sum

url="https://cisofy.com/files"
file="lynis-2.5.5.tar.gz"    # if you change this version be sure to change the sum_target (sha256sum)
sum_target="638c587396fbd2e857d6a3d2229db3b071704c0e217e03055c9268b495ab8102"
date_stamp=`date +'%Y%m%d'`

echo "[ -- ] $file downloading"
curl -O -s $url/$file

sum_gen=`sha256sum $file | awk '{print $1}'`

if [ '$sum_target = $sum_gen' ]; then        
        echo "[ OK ] $file sha256 sum verified"
else
        echo "[ FF ] $file sha256 sum FAILED!"
        rm $file
        echo "[ FF ] $file deleted!"
        exit 1
fi

echo "[ -- ] $file extracting"
tar -zxf $file
echo "[ OK ] $file extracted"

echo "[ -- ] lynis preparing"
cd lynis
chmod 640 include/*
echo "[ ok ] lynis running"
./lynis audit system

echo "[ -- ] lynis complete"
cd ..

echo "[ -- ] lynis cleanup"
rm $file
echo "[ OK ] $file removed"

echo "[ -- ] lynis cleanup"
rm -rf lynis
echo "[ OK ] lynis direcotry removed"

echo "[ -- ] lynis report compilation"
mkdir $date_stamp-lynis-report
mv /tmp/lynis.log /tmp/lynis-report.dat $date_stamp-lynis-report
echo "[ OK ] lynis report in $date_stamp-lynis-report"

exit 0
