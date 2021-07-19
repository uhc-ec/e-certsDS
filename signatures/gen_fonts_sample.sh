#!/bin/bash

[ "$1" ] && [ -f "$1" ] && [ "$2" ] && [ -f "$2" ] || {
    echo ""
    echo "Usage: $0 <input_ascii.txt> <list_of_fonts.txt>";
    echo ""
    exit;
}

DIR="output_imgs_fonts"
[ -d $DIR ] || { mkdir $DIR; }

while read FONT
do
    fmt < "$1" | convert -size 1000x2000 xc:white -font "$FONT" -pointsize 24 -fill black -annotate +15+30 "@-" -trim -bordercolor "#FFF" -border 10 +repage $DIR/$FONT.png
done < "$2"
