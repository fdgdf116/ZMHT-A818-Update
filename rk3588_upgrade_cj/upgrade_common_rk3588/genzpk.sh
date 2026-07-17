#!/bin/bash

ZPKINFO=$1
ZPKKEY=$2
ZPKTYPE=$3
ZPKTMP=`mktemp internal.XXXXX.zpk`
ZPKROOT=part_00000

if [ ! $# -eq 3 ]
then
    echo 'Usage:'
    echo '    genzpk.sh ZPK_INFO ZPK_KEY ZPK_TYPE'
    echo 'Available:'
    echo '    PINLING - genzpk.sh XXXX 46617AF37A395797 TYPE_W01'
    rm $ZPKTMP
    exit 1
fi

if [ ! -d $ZPKROOT ]
then
    echo 'RS* path upgrade not found!'
    rm $ZPKTMP
    exit 2
fi

# Remove any svn file
find $ZPKROOT -type d -name ".svn" -delete

# Generate type flag
echo "$ZPKTYPE" > $ZPKROOT/misc/machine_model

cd $ZPKROOT
rm -f check.lst
find . -type f -exec sha1sum '{}' \; > /tmp/check.lst
mv /tmp/check.lst .
cd -

tar -cvJf - $ZPKROOT | ./rcrypt -e $ZPKKEY > $ZPKTMP
./rcrypt -d $ZPKKEY < $ZPKTMP | tar -dJf -

if [ $? -ne 0 ]
then
    echo 'RS* pack failed'
    rm $ZPKTMP
    exit 3
fi

SHASUM16=`sha1sum $ZPKTMP | cut -d' ' -f1 | head -c 16`
NAME=`echo $ZPKINFO.$SHASUM16.ZPK | tr [:lower:] [:upper:]` 

mv $ZPKTMP $NAME
chmod 664 $NAME
echo "RS* --> pack $NAME build done!"
exit 0
