#!/bin/bash

WORK_DIR="$GITHUB_WORKSPACE"  # 工作目录
ASSETS_FILE="$WORK_DIR/assets_info.txt"  # 资产信息文件

if [ ! -f "$ASSETS_FILE" ]; then
    echo "Error: $ASSETS_FILE does not exist."
    exit 1
fi

DOWNLOAD_DIR="$WORK_DIR/downloads"
mkdir -p "$DOWNLOAD_DIR"

while read -r URL FILENAME ARCH; do
    echo "Downloading $URL"
    curl -L "$URL" -o "$DOWNLOAD_DIR/$FILENAME"
    unzip -o "$DOWNLOAD_DIR/$FILENAME" -d "$DOWNLOAD_DIR/$ARCH"
    cp ./dl.bat "$DOWNLOAD_DIR/$ARCH/"

    zip -r "$DOWNLOAD_DIR/$FILENAME-batch.zip" "$DOWNLOAD_DIR/$ARCH"
done < "$ASSETS_FILE"
