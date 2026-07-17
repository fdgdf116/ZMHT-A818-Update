#! /bin/sh

cd /tmp/real_part/bin
/tmp/real_part/script/change_cpu.sh  &

sleep 1
sync

# Change to working dir

ifconfig eth0 192.168.1.181 up 

sleep 1
sync

cd /tmp/real_part/modules/xdma_drv/tests
/tmp/real_part/modules/xdma_drv/tests/load_driver.sh  1
sleep 1
sync

rm /tmp/core
sysctl -w kernel.core_pattern=/tmp/core
ulimit -c unlimited
ulimit -s 81920

date -s 20240101
date -s 00:00:01

sleep 1
sync

cd /tmp/real_part/script/
./app_start.sh

sleep 5
./daemon.sh &
