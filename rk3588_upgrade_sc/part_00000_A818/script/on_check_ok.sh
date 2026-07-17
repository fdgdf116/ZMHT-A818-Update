#!/bin/sh

NEED_REBOOT=0
BOOTLOG=/tmp/boot.log

LOGO_FILE=../misc/logo
UIMG_FILE=../misc/boot.img
UBOT_FILE=../misc/uboot.img

NPU_FILE=../misc/npu_fw/MiniLoaderAll.bin
NPU_UPDATE_FLAG=/tmp/npu_update_flag

NPU_SH_FILE=/etc/init.d/S11_npu_init
WEB_XML_FILE=/userdata/userconfig/caminfo.xml
WEB_XML1_FILE=/userdata/userconfig/system.xml.tar.gz

LOGO_PART=/dev/mmcblk0p6
UIMG_PART=/dev/mmcblk0p3
MIRR_PART=/dev/mmcblk0p5
UBOT_PART=/dev/mmcblk0p1

# Update uboot
if [ -e $UBOT_FILE ]
then
    UBOT_SIZE=`wc -c $UBOT_FILE | cut -d' ' -f1`
    dd if=$UBOT_PART of=/tmp/uboot bs=$UBOT_SIZE count=1
    if cmp -s $UBOT_FILE /tmp/uboot
    then
        echo 'RS* Ignore same uboot' >> $BOOTLOG
    else
        echo 'RS* Update new uboot' >> $BOOTLOG
        cat $UBOT_FILE > $UBOT_PART
        sync
        sleep 1
    fi
    rm /tmp/uboot
fi

# Update mirror
if [ -e $UIMG_FILE ]
then
    MIRR_SIZE=`wc -c $UIMG_FILE | cut -d' ' -f1`
    dd if=$MIRR_PART of=/tmp/uImage bs=$MIRR_SIZE count=1
    if cmp -s $UIMG_FILE /tmp/uImage
    then
        echo 'RS* Ignore same mirror' >> $BOOTLOG
    else
        echo 'RS* Update new mirror' >> $BOOTLOG
        cat $UIMG_FILE > $MIRR_PART
        sync
        sleep 1
    fi
    rm /tmp/uImage
fi

# Update logo
if [ -e $LOGO_FILE ]
then
    LOGO_SIZE=`wc -c $LOGO_FILE | cut -d' ' -f1`
    dd if=$LOGO_PART of=/tmp/logo.bin bs=$LOGO_SIZE count=1
    if cmp -s $LOGO_FILE /tmp/logo.bin
    then
        echo 'RS* Ignore same logo' >> $BOOTLOG
    else
        echo 'RS* Update new logo' >> $BOOTLOG
        cat $LOGO_FILE > $LOGO_PART
        sync
        sleep 1
    fi
    rm /tmp/logo.bin
fi

# Update kernel
if [ -e $UIMG_FILE ]
then
    UIMG_SIZE=`wc -c $UIMG_FILE | cut -d' ' -f1`
    dd if=$UIMG_PART of=/tmp/uImage bs=$UIMG_SIZE count=1
    if cmp -s $UIMG_FILE /tmp/uImage
    then
        echo 'RS* Ignore same kernel' >> $BOOTLOG
    else
        echo 'RS* Update new kernel' >> $BOOTLOG
        cat $UIMG_FILE > $UIMG_PART
        sync
        sleep 1
	    echo 'RS* Reboot after update kernel'
        reboot
    fi
    rm /tmp/uImage
fi

if [ -e $NPU_SH_FILE ]
then
    mount -o remount,rw /
    rm $NPU_SH_FILE
    sync
fi

if [ -e $NPU_FILE ]
then
    if  cmp /usr/share/npu_fw/MiniLoaderAll.bin $NPU_FILE
    then
        echo 'RS* Ignore same NPU_FILE' >> $BOOTLOG
    else
        touch $NPU_UPDATE_FLAG
    fi
fi


if [ ! -e $WEB_XML_FILE ]
then
        touch $WEB_XML_FILE
        touch $WEB_XML1_FILE 
fi

echo 'on check ok sh end' >> $BOOTLOG