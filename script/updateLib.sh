#!/bin/sh

#  updateLib.sh
#  HXJMVPlayer
#
#  Created by han on 2019/1/29.
#  Copyright © 2019年 han. All rights reserved.

lib=$1

basePath=${SRCROOT}

libOutputDir=${basePath}/${lib}

if [ ! -d "${libOutputDir}" ]; then
mkdir "${libOutputDir}"
fi

libOutputFilePath=${libOutputDir}/lib${TARGET_NAME}.a

echo "对外输出目录文件路径:"
echo "${libOutputFilePath}"

rm -rf "${libOutputFilePath}"

cp -R "${BUILD_DIR}/${CONFIGURATION}-${PLATFORM_NAME}/lib${TARGET_NAME}.a" "${libOutputDir}/"
