#!/bin/bash

[ $1 ] && [ -d $1 ] || { echo "Usage: $0 <dir>"; exit; }

DIR=$(echo $1 | sed 's/\/$//')

rsync -av $DIR c1:/var/www/certificados/
rsync -av $DIR c2:/var/www/certificados/

