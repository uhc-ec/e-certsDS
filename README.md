<h1 align="center">E-certsDS</h1>
<h5 align="center">
Certificados Eletrônicos com Assinatura Digital
</h5>

>Sistema desenvolvido em Bash Script e Python para  geração, publicação e validação de certificados eletrônicos digitalmente assinados utilizando chaves do padrão OpenPGP.

## Uso

```sh
./gera_certificados.sh <template.tex> <participantes.csv> <"Nome do Evento"> <SenhaGPG> <SenhaHMAC> <SenhaDoHistory> <[teste/deploy]>
```

## Descrição
A Figura a seguir ilustra a organização e operação do script:

![e-certs-model](/imgs/e-certs-model.png?raw=true "e-certs-model")

A partir de um template latex com *tags* (1), um arquivo contendo os dados dos participantes (2) e configurações do servidor responsável por armazenar os dados, o script publicará os certificados nos servidores(1) e enviará um link de para os e-mails dos participantes(6).

Exemplo de certificado gerado com o e-certs:
![e-certs-model](/imgs/certificado-mauricio.png "e-certs-certificate")


## Arquivos de Entrada
1. **Template LaTeX contendo os componentes textuais e visuais**, como logomarcas, informações sobre o evento e *tags* para preenchimento automatizado dos certificados.
Exemplo do uso de *tags* em um arquivo LaTeX:
```tex
Certificado de TAGTIPO
para TAGNOME
TAGHORAS hora(s) de atividades.
```
2. **Arquivo CSV contendo os dados de entrada**. Estes dados servirão para preencher os campos idenfificados nas *tags* e deverão conter as informações básicas dos participantes do evento, como nome completo, endereço de email, tipo de participação e número de horas, *e.g.*:
```csv
Alice Silva,alice@gmail.com,Co-Organizador,1
Bob Souza,bob@gmail.com,Ouvinte,2
Eve Martins,eve@gmail.com,Ouvinte,2
```
3. **Nome do Evento**. 
4. **Senha GPG**.  Senha utilizada para geração das assinaturas utilizando a chave privada OpenPGP.
5. **Senha HMAC**. Senha que é utilizada pela função HMAC para gerar os códigos de autenticação.
6. **Senha do arquivo histórico**. Senha do banco de dados que contém o histórico de eventos e certificados gerados.
7. **Modo de execução**. Pode ser *teste* ou *deploy*. Onde teste apenas gerará os certificados e deploy enviará os certificados para os e-mails dos participantes e para os servidores.

## Dependências
Para o software funcionar em distribuições baseadas no Debian, instale as dependências necessárias com o comando a seguir:
```sh
sudo apt-get install gnupg2 openssh-server p7zip-full python2.7 qrencode rsync texlive texlive-fonts-extra texlive-latex-extra -y
```

## QR Codes
Os três primeiros QR Codes seguem o padrão de distribuição dos arquivos de instalação (arquivos ISO) de distribuições GNU/Linux.
Cada arquivo *.iso* acompanha um arquivo de resumos criptográficos e um segundo arquivo *.asc* para verificação da assinatura OpenPGP.
Com estas informações em mãos, assumindo que o responsável pela assinatura digital dos certificados é pré-definido e conhecido (\emph{i.e.}, nome e email), os usuários podem verificar a integridade e a autenticidade dos certificados.
O quarto QR Code é meramente técnico e opcional, uma vez que a chave pública OpenPGP pode ser recuperada através do email do autor da assinatura digital. 
Finalmente, o último QR Code apresenta o resumo criptográfico resultante da aplicação da primitiva HMAC, utilizando uma chave secreta conhecida apenas pelo emissor dos certificados, sobre os dados dos outros quatro QR Codes.  
Em outras palavras, o quinto QR Code autentica o conteúdo dos demais.

1. Link do PDF original do certificado. Ex: `https://certificado.unihacker.club/20200611/97658b389b9be5ed568f95cb98a6ad0e.pdf`

2. Link do arquivo contendo o resumo criptográfico SHA256 do PDF. Ex: `https://certificado.unihacker.club/20200611/97658b389b9be5ed568f95cb98a6ad0e.pdf.sha256`

3. Link do arquivo *.asc*, que contém a assinatura digital OpenPGP do certificado. Ex: `https://certificado.unihacker.club/20200611/97658b389b9be5ed568f95cb98a6ad0e.pdf.asc`

4. Identificador da chave pública OpenPGP e instruções para download. Ex: `gpg --recv-key C6BC50CA3BF7A752`

5. Resumo criptográfico do código de autenticação HMAC do certificado. Ex: `78a47e94934ff015a81fe1326186213d1b29207161e401cd0ac578815476f2dc`

## Configuração servidores SSH


## Ambientes / Distribuições GNU/Linux

A ferramenta já foi testada e utilizada nos seguintes ambientes / distribuições GNU/Linux:

Debian 10:

- Kernel = `Linux deb 4.19.0-17-amd64 #1 SMP Debian 4.19.194-1 (2021-06-10) x86_64 GNU/Linux`

- Python = `Python 2.7.16`