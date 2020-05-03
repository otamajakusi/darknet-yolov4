#!/bin/bash

set -ex

# git clone https://github.com/otamajakusi/darknet-yolov4.git
# cd darknet-yolov4

# before running this script, google drive should be mounted.
# tile score w/ darknet
googledrive="/content/drive/My Drive"
stat "${googledrive}"
if [ $? -ne 0 ]; then
    echo "google drive should be mounted"
    exit 1
fi

make

# tar -C directory --strip-components 1 has a problem for darknet??
# `'Couldn't open file:`
tar zxf /content/drive/My\ Drive/public/2018-06-23.tgz
tar zxf /content/drive/My\ Drive/public/2018-09-15.tgz
tar zxf /content/drive/My\ Drive/public/2018-09-29.tgz
tar zxf /content/drive/My\ Drive/public/2018-12-20.tgz
mv 2018-09-15/* 2018-09-29/* 2018-12-20/* 2018-06-23
mkdir -p anno
tar zxf /content/drive/My\ Drive/public/tile-labels.tgz -C anno

if [ -f "/content/drive/My Drive/ml/yolov4-backup/anno.tgz" ]; then
    tar zxf "/content/drive/My Drive/ml/yolov4-backup/anno.tgz"
else
    python3 scripts/tile_label.py 2018-06-23 anno
    tar zcf "/content/drive/My Drive/ml/yolov4-backup/anno.tgz" {train,valid}.txt 2018-06-23/*.txt
fi

if [ -f "/content/drive/My Drive/ml/yolov4-backup/yolov4-tile.backup" ]; then
    weight="backup/yolov4-tile.backup"
else
    weight="yolov4.conv.137"
    wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137
fi

rm -r backup
ln -s "/content/drive/My Drive/ml/yolov4-backup" backup

./darknet detector train cfg/tiles.data cfg/yolov4-tile.cfg ${weight}
