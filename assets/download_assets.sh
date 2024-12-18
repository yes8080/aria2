#!/bin/bash

DOWNLOAD_DIR="$GITHUB_WORKSPACE/downloads"
mkdir -p "$DOWNLOAD_DIR"

index=1
while read -r URL FILENAME ARCH; do
    echo "Downloading $URL"
    curl -L "$URL" -o "$DOWNLOAD_DIR/$FILENAME"
    unzip -o "$DOWNLOAD_DIR/$FILENAME" -d "$DOWNLOAD_DIR/$ARCH"
    cp ./dl.bat "$DOWNLOAD_DIR/$ARCH/"

    zip -r "$DOWNLOAD_DIR/$FILENAME-batch.zip" "$DOWNLOAD_DIR/$ARCH"
    index=$((index + 1))
done < assets_info.txt
