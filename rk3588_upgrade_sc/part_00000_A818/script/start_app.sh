#! /bin/sh

# Mount point
MOUNT_POINT="/userdata/sda1"

# Check if the mount point exists, create it if not
if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p "$MOUNT_POINT"
    echo "Created mount point: $MOUNT_POINT"
fi

# Loop through /dev/sda, /dev/sda1, ..., /dev/sda5
for i in {0..5}; do
    DEVICE="/dev/sda$i"
    if [ $i -eq 0 ]; then
       DEVICE="/dev/sda"
    fi

    
    # Check if the device exists
    if [ -e "$DEVICE" ]; then
        # Try to mount the device
        echo "Attempting to mount $DEVICE to $MOUNT_POINT"
        mount "$DEVICE" "$MOUNT_POINT" && {
            echo "Successfully mounted $DEVICE to $MOUNT_POINT"
            break
        } || {
            echo "Failed to mount $DEVICE"
        }
    else
        echo "$DEVICE does not exist"
    fi
done

sleep 4

sync

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
