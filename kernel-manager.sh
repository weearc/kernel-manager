#!/bin/bash
MIRROR=mirrors.cqu.edu.cn
COREDB=core.db.tar.gz
DIR=$HOME/.config/kernel-manager
DOWNLOAD_TOOL=/usr/bin/wget
ARCH=x86_64
VERSION=stable
TMP_DIR=$DIR/tmp

if [ ! -d $DIR ]; then
  mkdir -p $DIR
fi

if [ ! -d $TMP_DIR ]; then
  mkdir $TMP_DIR
fi

cd $DIR
mkdir -p src
cd src

$DOWNLOAD_TOOL "https://$MIRROR/manjaro/$VERSION/core/$ARCH/$COREDB"
tar -xf $COREDB >/dev/null 2>&1
rm -rf `ls | grep -v "^linux[0-9]." | grep -v $COREDB`
ls | grep -v $COREDB > filelist
sed -i '/filelist/d' filelist
sed -i '/headers/d' filelist
sha256sum $COREDB > $COREDB.sha256sum
cat $COREDB.sha256sum

awk 'BEGIN{FS="-"} {print $1}' filelist > pkgname

# zenity windows draw
SELECT=$(cat filelist | \
awk -F '-' '{
    for(i=1;i<=NF;i++){
        print $i; # Print Each Column separeted by Default EOL
    }
}' | \
zenity --list \
--title="kernel manager" \
--column="Package" --column="Packager Version" --column="Package Release" \
--print-column=ALL
)

SELECT_KERNEL=${SELECT//"|"/"-"}
i=`echo $SELECT_KERNEL | cut -d "-" -f1`
tmp="$i-headers"
SELECT_HEADERS=${SELECT_KERNEL//$i/$tmp}


cd $TMP_DIR
$DOWNLOAD_TOOL "https://$MIRROR/manjaro/$VERSION/core/$ARCH/$SELECT_KERNEL-$ARCH.pkg.tar.zst"
$DOWNLOAD_TOOL "https://$MIRROR/manjaro/$VERSION/core/$ARCH/$SELECT_HEADERS-$ARCH.pkg.tar.zst"

sudo pacman -U $i*
sudo grub-mkconfig -o /boot/grub/grub.cfg
