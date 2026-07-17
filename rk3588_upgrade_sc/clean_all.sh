#!/bin/bash
cd ./upgrade_common_rk3588
rm *.ZPK 
rm *.zpk 

cd ../

rm -rf output/*

echo "clean app app_web zpk ok" 

exit 0
