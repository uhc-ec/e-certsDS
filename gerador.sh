#!/bin/bash

[ "$1" ] && [ -f "$1" ] && [ "$2" ] && [ -f "$2" ] && [ "$3" ] && [ "$4" ] && [ "$5" ] && [ "$6" ] && [ "$7" ] || { echo "";
    echo "Usage: $0 <template.tex> <participantes.csv> <GPG_PASS> <nome_do_evento> <HMAC_PASS> <HISTORY_PASS> <mode: teste|deploy>"; 
    echo "";
    echo "  <template.tex> = ./templates/certificado.tex"; 
    echo "  <participantes.csv> = ./nome_email_tipo_horas.csv"; 
    echo "  <nome_evento> = 1oHackingDay"; 
    echo "  <GPG_PASS> = MinhaSenhaGPG"; 
    echo "  <HMAC_PASS> = MinhaSenhaHMAC"; 
    echo "  <HISTORY_PASS> = SenhaDoArquivoHistorico"; 
    echo "  <mode: teste|deploy>"; 
    echo "         teste = run in TEST mode (generate only localy)";
    echo "         deploy  = generate, publish and notify by email";
    echo "";
    exit; 
}

for CMD in 7z qrencode pdflatex shasum gpg2 rsync python2.7 python3
do
    if [ "`which $CMD`" = "" ]
    then
        echo "[ERROR] Missing command/tool $CMD. Install it first."
        exit
    fi
done

MODE=$(echo $7 | tr '[:upper:]' '[:lower:]')
if [ "$MODE" != "teste" ] && [ "$MODE" != "deploy" ]
then
    echo ""
    echo "[ERROR] Invalide mode \"$MODE\""
    echo ""
    exit
fi

echo ""
echo -n "Running in \"$MODE\" mode ... " 
sleep 2
echo "done."
echo "" 

TEMPLATE_TEX="$1"
TEMPLATE_FILES=$(grep -E "(.pdf|.png|.eps|.jpg)" $TEMPLATE_TEX | grep -v "^%" | sed 's/^.*{\(.*\....\)}.*/\1/')
CSV_FILE="$2"

GPG_EMAIL="assina@unihacker.club"
GPG_USER="C6BC50CA3BF7A752" # pub key ID
EVENT_NAME="$3"
GPG_PASS="$4"
HMAC_PASS="$5"
HISTORY_PASS="$6"
HISTORY_STORE="history.db"
INDEX_HTML="etc/index.html"

[ "$MODE" = "teste" ] || {
    [ -f $HISTORY_STORE.7z ] || { 
        echo "# History File" > $HISTORY_STORE
        7z a -y -p$HISTORY_PASS $HISTORY_STORE.7z $HISTORY_STORE
        [ $? -eq 0 ] || { exit; }
        rm -f $HISTORY_STORE
    }
}

SERVER_URL="https://certificado.unihacker.club"
SERVER_DIR="/var/www/certificados/"
RSYNC_HOSTS="c1 c2"

DIR=`date +%Y%m%d`
[ -d $DIR ] || { mkdir -p $DIR; }

CSV_OK=$(sed -E 's/,[[:blank:]]*,//;s/^\s*,//;s/,\s*$//' $CSV_FILE | awk ' BEGIN{FS=","}!n{n=NF}n!=NF{failed=1;exit}END{print !failed}')
[ $CSV_OK -eq 1 ] || {
    echo "";
    echo "[ERROR] Double check the CSV file $CSV_FILE!";
    echo "Each line needs to have the SAME number of FIELDS/COMMAS.";
    echo "";
    exit;
}

LIST_FILE="$DIR/lista.txt"

echo "# EVENTO/ATIVIDADE: $EVENT_NAME DATA: $DIR" > $LIST_FILE
echo "# LISTA DOS PARTICIPANTES DO EVENTO" >> $LIST_FILE
echo "# Nome Completo, Tipo de Participação, Número de Horas" >> $LIST_FILE

[ ! -f $CSV_FILE.email ] || { rm -f $CSV_FILE.email; }

run_cmd() {
    $*
    [ $? -eq 0 ] || { exit; }
}

while read LINHA
do
    FULLNAME=$(echo $LINHA | cut -d"," -f1)
    EMAIL=$(echo $LINHA | cut -d"," -f2)
    TAGTIPO=$(echo $LINHA | cut -d"," -f3)
    TAGHORAS=$(echo $LINHA | cut -d"," -f4)

    echo "NOME: $FULLNAME EMAIL: $EMAIL TIPO: $TAGTIPO HORAS: $TAGHORAS"
    echo "$FULLNAME, $TAGTIPO, $TAGHORAS" >> $LIST_FILE

    TMP_FILE="$DIR.tex"
    run_cmd cp $TEMPLATE_TEX $TMP_FILE

    eval "sed 's/TAGTIPO/$TAGTIPO/' $TMP_FILE > .tmp"; mv .tmp $TMP_FILE
    eval "sed 's/TAGNOME/$FULLNAME/' $TMP_FILE > .tmp"; mv .tmp $TMP_FILE
    eval "sed 's/TAGHORAS/$TAGHORAS/' $TMP_FILE > .tmp"; mv .tmp $TMP_FILE
    CERT_FILE=$(openssl dgst -md5 -hmac $GPG_PASS $TMP_FILE | awk '{ print $2 }')
    [ $? -eq 0 ] || { exit; }
    run_cmd mv $TMP_FILE $DIR/$CERT_FILE.tex
	
    pushd $DIR
    PDF_FILE=$CERT_FILE.pdf
    TMP_FILE=$CERT_FILE.tex
    qrencode -t PNG -o qr_code_url.png "$SERVER_URL/$DIR/$PDF_FILE"
    [ $? -eq 0 ] || { exit; }
    qrencode -t PNG -o qr_code_url_sha256.png "$SERVER_URL/$DIR/$PDF_FILE.sha256"
    [ $? -eq 0 ] || { exit; }
    qrencode -t PNG -o qr_code_url_gpg.png "$SERVER_URL/$DIR/$PDF_FILE.asc"
    [ $? -eq 0 ] || { exit; }
    qrencode -t PNG -o qr_code_gpg_key.png "gpg --recv-key $GPG_USER" 
    [ $? -eq 0 ] || { exit; }
    echo "$SERVER_URL/$DIR/$PDF_FILE $SERVER_URL/$DIR/$PDF_FILE.sha256 $SERVER_URL/$DIR/$PDF_FILE.asc gpg --recv-key $GPG_USER" > hmac_sha256.txt
    HMAC_SHA256=$(openssl dgst -sha256 -hmac $HMAC_PASS hmac_sha256.txt | awk '{ print $2 }')
    [ $? -eq 0 ] || { exit; }
    qrencode -t PNG -o qr_code_hmac_qr_codes.png "$HMAC_SHA256"
    [ $? -eq 0 ] || { exit; }
    pdflatex -interaction=nonstopmode $CERT_FILE.tex
    [ $? -eq 1 ] || { exit; }
    shasum -a 256 $CERT_FILE.pdf > $CERT_FILE.pdf.sha256
    [ $? -eq 0 ] || { exit; }

    [ ! -f $CERT_FILE.pdf.asc ] || { rm -f $CERT_FILE.pdf.asc; }
    gpg2 --batch --passphrase $GPG_PASS --pinentry-mode loopback --local-user $GPG_USER --output $CERT_FILE.pdf.asc --armor --detach-sig $CERT_FILE.pdf 
    [ $? -eq 0 ] || { exit; }
    [ ! -f $CERT_FILE.pdf.sha256.asc ] || { rm -f $CERT_FILE.pdf.sha256.asc; }
    gpg2 --batch --passphrase $GPG_PASS --pinentry-mode loopback --local-user $GPG_USER --output $CERT_FILE.pdf.sha256.asc --armor --detach-sig $CERT_FILE.pdf.sha256 
    [ $? -eq 0 ] || { exit; }
    popd
    echo "$FULLNAME:$EMAIL:$PDF_FILE" >> $CSV_FILE.email
done < $CSV_FILE

N_PARTICIPANTS=$(cut -d"," -f1 $CSV_FILE | sort -u | wc -l | awk '{ print $1 }')
N_HOURS=$(cut -d"," -f4 $CSV_FILE | grep -oE "([0-9]*)")
N_HOURS=$(echo $N_HOURS | sed 's/ /+/g;s/+$//;s/^+//')
N_HOURS=$(echo "scale=2;$N_HOURS" | bc)
L_FILE=$(openssl dgst -md5 -hmac $HMAC_PASS $LIST_FILE | awk '{ print $2 }')
mv $LIST_FILE $DIR/$L_FILE.txt
[ $? -eq 0 ] || { exit; }
ZIP_PASS=$(echo $L_FILE.txt | shasum -a 256 | cut -c1-16)
7z a -y -p$ZIP_PASS $DIR/$L_FILE.txt.7z $DIR/$L_FILE.txt
[ $? -eq 0 ] || { exit; }

[ ! -f $DIR/$L_FILE.txt.7z.asc ] || { rm -f $DIR/$L_FILE.txt.7z.asc; }
gpg2 --batch --passphrase $GPG_PASS --pinentry-mode loopback --local-user $GPG_USER --output $DIR/$L_FILE.txt.7z.asc --armor --detach-sig $DIR/$L_FILE.txt.7z
[ $? -eq 0 ] || { exit; }

[ "$MODE" = "teste" ] || {
    7z x -y -p$HISTORY_PASS $HISTORY_STORE.7z
    if [ $? -eq 0 ]
    then
        echo "$EVENT_NAME, $HMAC_PASS, $N_PARTICIPANTS, $L_FILE.txt.7z, $ZIP_PASS" >> $HISTORY_STORE
        7z a -y -p$HISTORY_PASS $HISTORY_STORE.7z $HISTORY_STORE
        [ $? -eq 0 ] || { exit; }
        rm -f $HISTORY_STORE
    else
        echo "[ERROR] Could not write to history file \"$HISTORY_STORE\"!"
        echo "$EVENT_NAME, $HMAC_PASS, $N_PARTICIPANTS, $L_FILE.txt.7z, $ZIP_PASS"
    fi
}

pushd $DIR
find . -type f -not -name \*.pdf -not -name \*.asc -not -name \*.sha256 -not -name \*.7z -exec rm -f {} \;
popd

echo ""
echo "Publishing certificates ... "
[ "$MODE" = "teste" ] || {
    cp $INDEX_HTML $DIR/
    for RSYNC_HOST in $RSYNC_HOSTS
    do
        rsync -av $DIR $RSYNC_HOST:$SERVER_DIR
    done
}
echo "Publication ... done."
echo ""

while read DATA
do
    FULLNAME=$(echo $DATA | cut -d":" -f1)
    EMAIL=$(echo $DATA | cut -d":" -f2)
    PDF_FILE=$(echo $DATA | cut -d":" -f3)
    echo -n "Sending PDF certificate URLs by email to $EMAIL ... "
    [ "$MODE" = "teste" ] || {
        python3 e-mailer.py "$FULLNAME" "$EMAIL" "$SERVER_URL/$DIR/$PDF_FILE" "$EVENT_NAME"
    }
    echo "done."
done < $CSV_FILE.email

rm -f $CSV_FILE.email

echo ""
echo -n "Sending summary to project leaders ... "
[ "$MODE" = "teste" ] || {
    python2.7 envia_sumario.py "$EVENT_NAME" "$SERVER_URL/$DIR/$L_FILE.txt.7z" "$SERVER_URL/$DIR/$L_FILE.txt.7z.asc" "$ZIP_PASS" "$N_PARTICIPANTS" "$N_HOURS" "$GPG_USER"
}
echo "done."
echo ""

[ "$MODE" != "teste" ] || {
    echo ""
    echo "[INFO] Running on TEST mode. No email was actually sent."
    echo ""
}
