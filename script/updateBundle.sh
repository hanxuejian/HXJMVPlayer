#!/bin/sh

#  updateBundle.sh
#  HXJMVPlayer
#
#  Created by han on 2019/1/29.
#  Copyright © 2019年 han. All rights reserved.

lib=$1

basePath=${SRCROOT}

libOutputDir=${basePath}/${lib}

resourceOutputDir=${libOutputDir}/${TARGET_NAME}

echo "对外输出目录文件路径:"
echo "${resourceOutputDir}"

rm -rf "${resourceOutputDir}"

if [ ! -d "${resourceOutputDir}" ]; then
mkdir "${resourceOutputDir}"
fi

cp -R "${BUILD_DIR}/${CONFIGURATION}-${PLATFORM_NAME}/include/${TARGET_NAME}/" "${resourceOutputDir}/"
