<h1 align="center">E-certsDS v0.2 (beta)</h1>
<h5 align="center">
Certificados Eletrônicos com Assinatura Digital
</h5>

>Sistema desenvolvido em Bash Scripting e Python para  geração, publicação e validação de certificados eletrônicos digitalmente assinados utilizando chaves do padrão OpenPGP.

## Apresentação
A Figura a seguir ilustra a organização e operação da ferramenta. A partir de um template LaTeX com *tags* pre-definidas (1) e um arquivo contendo os dados dos participantes (2), a ferramenta gera e publica (5) os certificados em servidores Web. Além disso, a ferramenta também envia o link dos certificados publicados (6) para os e-mails dos participantes do evento ou atividade.

![e-certs-model](/imagens/e-certs-model.png?raw=true "e-certs-model")

A imagem a seguir apresenta um exemplo de certificado gerado.

![e-certs-model](/imagens/certificado-mauricio.png "e-certs-certificate")

## QR Codes do certificado
Os três primeiros QR Codes seguem o padrão de distribuição dos arquivos de instalação (arquivos ISO) de distribuições GNU/Linux.
Cada arquivo *.iso* acompanha um arquivo de resumos criptográficos e um segundo arquivo *.asc* para verificação da assinatura OpenPGP.
Com estas informações em mãos, assumindo que o responsável pela assinatura digital dos certificados é pré-definido e conhecido (i.e., nome e email), os usuários podem verificar a integridade e a autenticidade dos certificados.
O quarto QR Code é meramente técnico e opcional, uma vez que a chave pública OpenPGP pode ser recuperada através do email do autor da assinatura digital. 
Finalmente, o último QR Code apresenta o resumo criptográfico resultante da aplicação da primitiva HMAC, utilizando uma chave secreta conhecida apenas pelo emissor dos certificados, sobre os dados dos outros quatro QR Codes. Em outras palavras, o quinto QR Code autentica o conteúdo dos demais.

1. Link do PDF original do certificado.\
Ex: `https://certificado.unihacker.club/20200611/97658b389b9be5ed568f95cb98a6ad0e.pdf`

2. Link do arquivo contendo o resumo criptográfico SHA256 do PDF.\
Ex: `https://certificado.unihacker.club/20200611/97658b389b9be5ed568f95cb98a6ad0e.pdf.sha256`

3. Link do arquivo *.asc*, que contém a assinatura digital OpenPGP do certificado.\
Ex: `https://certificado.unihacker.club/20200611/97658b389b9be5ed568f95cb98a6ad0e.pdf.asc`

4. Identificador da chave pública OpenPGP e instruções para download.\
Ex: `gpg --recv-key C6BC50CA3BF7A752`

5. Resumo criptográfico do código de autenticação HMAC do certificado.\
Ex: `78a47e94934ff015a81fe1326186213d1b29207161e401cd0ac578815476f2dc`

## Arquivos de Entrada
1. **Template LaTeX contendo os componentes textuais e visuais**, como logomarcas, informações sobre o evento e *tags* para preenchimento automatizado dos certificados.
Exemplo do uso de *tags* em um arquivo LaTeX:
```tex
Certificado de TAGTIPO
para TAGNOME
TAGHORAS hora(s) de atividades.
```
2. **Arquivo CSV contendo os dados de entrada** são utilizados para preencher os campos idenfificados nas *tags* e devem conter as informações básicas dos participantes do evento, como nome completo, endereço de email, tipo de participação e número de horas, *e.g.*:
```csv
Alice Silva,alice@gmail.com,Co-Organizador,1
Bob Souza,bob@gmail.com,Ouvinte,2
Eve Martins,eve@gmail.com,Ouvinte,2
