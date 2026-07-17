#! /bin/sh
echo "T5 src board daemon start"

while :
do
	stillRunning=$(ps -ef |grep rk_a818_prj |grep -v "grep")
if [ -z "$stillRunning" ]
then
	echo "the p1source_sg was closed!!!!!!!!!!!!!!!!!"
	cd /tmp/real_part/bin/
	./reg_rw /dev/xdma0_control 0x10040 32 0
	./reg_rw /dev/xdma0_control 0x1003c 32 0
	./reg_rw /dev/xdma0_control 0x1003c 32 1
	cd -
        cd /tmp/real_part/script/
	./app_start.sh
        cd -
	echo "the t5_source restart!!!!!!!!!!!!!!  "
fi

if [ -f "/run/reboot" ];then
	echo "get reboot file ,reboot..."
	sleep 2
	reboot
fi
	sleep 2
done
