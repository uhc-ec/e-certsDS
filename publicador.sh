#!/bin/bash

[ $1 ] && [ -d $1 ] || { echo "Uso: $0 <dir_dos_certificados>"; exit; }

DIR=$(echo $1 | sed 's/\/$//')
LISTA_SERVIDORES=$(cat etc/servidores.cfg)

shift

for SERVIDOR in $LISTA_SERVIDORES
do
    rsync -av $DIR $SERVIDOR
done

