#!/bin/bash

[ $1 ] && [ -d $1 ] || { echo "Uso: $0 <dir_dos_certificados>"; exit; }

DIR=$(echo $1 | sed 's/\/$//')
DIR_REMOTO="/var/www/certificados/"
LISTA_SERVIDORES="servidor1 servidor2"

shift

for SERVIDOR in $LISTA_SERVIDORES
do
    rsync -av $DIR $SERVIDOR:$DIR_REMOTO
done

