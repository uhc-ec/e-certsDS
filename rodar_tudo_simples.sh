#!/bin/bash

[ "$1" ] && [ -f "$1" ] && [ "$2" ] && [ -f "$2" ] && [ "$3" ] && [ "$4" ] || { echo "";
    echo "Usage: $0 <template.tex> <participantes.csv> <nome_do_evento> <mode: test|hot>"; 
    echo "";
    echo "  <template.tex> = ./templates/certificado.tex"; 
    echo "  <participantes.csv> = ./nome_email_tipo_horas.csv"; 
    echo "  <nome_evento> = 1oHackingDay"; 
    echo "  <mode: test|hot>"; 
    echo "         test = run in TEST mode (generate only localy)";
    echo "         hot  = generate, publish and notify by email";
    echo "";
    exit; 
}

bash gera_certificados.sh "$1" "$2" "$3" SenhaGPG SenhaHMAC SenhaDoHistory "$4"

