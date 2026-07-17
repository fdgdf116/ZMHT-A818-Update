
#!/bin/sh

#
# Unpacker for No-Erase-Limit-ZPK
#
# Ray, 180926, version 1.0.0
# Ray, 211206, version 1.1.0
#

BOOTLOG=/tmp/boot.log
ZPK_STORE_DIR=/userdata/zpk
ZPK_UNPACK_DIR=/oem/part

cd /tmp
echo 9 >/tmp/sd_update

# if [ ! -e zmv_sn ]
# then
#     echo 'RS* No machine descriptor file found!' >> $BOOTLOG
#     echo 1 >/tmp/sd_update
#     exit 1
# fi

if [ -e zpkname ]
then
    echo 'RS* Cant upgrade in once startup!' >> $BOOTLOG
    echo 2 >/tmp/sd_update
    exit 2
fi

ZPKFILE=`ls $ZPK_STORE_DIR/*.*.ZPK`
PACKNUM=`echo $ZPKFILE | wc -w`

if [ $PACKNUM -gt 1 ]
then
    echo 'RS* Detected multi-pack' >> $BOOTLOG
    echo 3 >/tmp/sd_update
    exit 3
fi

if [ $PACKNUM -eq 1 ]
then
    ZPK_TYPE=`cat zmv_sn | fgrep MACH_TP | cut -d' ' -f2`
    # ZPK_KEY=`cat zmv_sn | fgrep ZPK_KEY | cut -d' ' -f2`
    ZPK_KEY=6d6c763fc0b1b87e

    echo `basename $ZPKFILE` > /tmp/zpkname
    ln -s $ZPKFILE /tmp/upgrade.zpk
    PKGSUM16=`basename $ZPKFILE | cut -d'.' -f2 | tr [:upper:] [:lower:]`
    SHASUM16=`sha1sum /tmp/upgrade.zpk | cut -d' ' -f1 | head -c 16`
    ZNAME=`basename $ZPKFILE`
    
    if e2upg -h | fgrep '**CURRENT**' | fgrep $ZNAME
    then
        echo 'RS* Ignore same version ZPK' >> $BOOTLOG
        echo 4 >/tmp/sd_update
        exit 4
    fi
    
    if [ $PKGSUM16 == $SHASUM16 ]
    then
        echo "RS* Detected upgrade pack id $PKGSUM16" >> $BOOTLOG
        echo "$PKGSUM16" >> /tmp/upgrade_id
        
        if rcrypt -d $ZPK_KEY < /tmp/upgrade.zpk | tar -xJf -
        then
            echo 'RS* Unpack ZPK done' >> $BOOTLOG
            BOUND_TYPE=`cat /tmp/part_00000/misc/machine_model`
            if [ $BOUND_TYPE != $ZPK_TYPE ]
            then
                echo "RS* Type $BOUND_TYPE is incorrect!" >> $BOOTLOG
                echo 5 >/tmp/sd_update
                exit 5
            fi

            PART_PREV_ID=`find $ZPK_UNPACK_DIR -type d -name "part_*" | sort | tail -n 1 | sed 's/^.*part_//'`
            PART_CURR=`expr $PART_PREV_ID + 1`
            PART_CURR_FORMATED=`printf part_%05u $PART_CURR`
            
            mount -o remount,rw /oem
            sleep 1
            e2upg -b $ZNAME $PART_CURR
            echo "RS* Created new $PART_CURR_FORMATED" >> $BOOTLOG
            if ! mv /tmp/part_00000 $ZPK_UNPACK_DIR/$PART_CURR_FORMATED
            then
                echo 'RS* Move files failed due to insufficient disk space' >> $BOOTLOG
                echo 6 >/tmp/sd_update
                exit 6
            fi
            sleep 2
            sync
            mount -o remount,ro /oem
        else
            echo 'RS* Unpack fail' >> $BOOTLOG
            echo 7 >/tmp/sd_update
            exit 7
        fi
    else
        echo "RS* Checksum of pack id $PKGSUM16 is wrong ... discard" >> $BOOTLOG
        rm /tmp/upgrade.zpk
        echo 8 >/tmp/sd_update
        exit 8
    fi
fi
echo 0 >/tmp/sd_update
exit 0

