#!/bin/bash

ZPKINFO=$1
ZPKKEY=6d6c763fc0b1b87e
ZPKTYPE=TYPE_W01
ZPKROOT=output

if [ ! $# -eq 1 ]
then
    echo 'Usage:'
    echo '    ./build_zpk.sh'
    echo '    source setup_rk3588_env.sh'
    echo '    ./build.sh ZPK_VERSION'
    echo 'ex: ./build.sh 5BCH_V90001R00000B01'
    exit 1
fi

mkdir -p ./output
sync

if [ ! -d $ZPKROOT ]
then
    echo 'RS* path upgrade not found!'
    exit 2
fi

# build app
rm -fr ./upgrade_common_rk3588/part_00000
sync
sleep 1
cp ./part_00000_A818 ./upgrade_common_rk3588/part_00000  -r

if [ $? -eq 1 ]
then    
    echo "cp part err"
    exit 2
fi  
sync
cd ./upgrade_common_rk3588/
./genzpk.sh  $1  $ZPKKEY $ZPKTYPE
if [ $? -eq 1 ]
then    
    echo "zpk gen err"
    exit 4
else
    chmod 777 *.ZPK
    mv *.ZPK  ../output/
fi

echo "build $ZPKINFO zpk ok" 

exit 0
