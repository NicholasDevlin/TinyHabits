#!/bin/bash

# Create notification icons for Android app

ICON_DIRS="hdpi mdpi xhdpi xxhdpi xxxhdpi"

# Create mipmap directories
for dir in $ICON_DIRS; do
    mkdir -p "mipmap-$dir"
    echo "Created mipmap-$dir directory"
done

# Copy icon files to all directories
echo "Creating notification icons for Android..."

# Copy icon files to all directories
for dir in $ICON_DIRS; do
    if [ -f "ic_menu_save.png" ] && [ -f "ic_media_next.png" ]; then
        echo "Copying icons to mipmap-$dir/"
        cp ic_menu_save.png "mipmap-$dir/"
        cp ic_media_next.png "mipmap-$dir/"
        echo "Copied icons to mipmap-$dir/"
    else
        echo "Source icons not found, skipping mipmap-$dir"
    fi
done

echo "Notification icons creation complete!"