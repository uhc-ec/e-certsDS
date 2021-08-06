<h1 align="center">E-certsDS v0.2 (beta)</h1>
<h5 align="center">
Certificados Eletrônicos com Assinatura Digital
</h5>

>Sistema desenvolvido em Bash Scripting e Python para  geração, publicação e validação de certificados eletrônicos digitalmente assinados utilizando chaves do padrão OpenPGP.

## Passo a passo e-certs

**Preparando o ambiente (linux)**

Instalação do git:

```sudo apt-get install git -y```

Clone do repositório:

```git clone https://github.com/uhc-ec/e-certsDS.git ~/e-certsDS/```

Entre na pasta e dar permissão de execução para os scripts:
```
cd e-certsDS/
sudo chmod +x -R *.sh
```

Instale as dependências necessárias utilizando o comando:
```sh
sudo apt-get install gnupg2 openssh-server p7zip-full python2.7 qrencode rsync -y
sudo apt-get install texlive texlive-fonts-extra texlive-latex-extra -y
```

## Configuração de acesso aos servidores

Os certificados são publicados nos servidores *web* utilizando a ferramenta *rsync* sobre um túnel SSH, que utiliza chaves públicas para autenticação.

Nos servidores é necessário gerar as chaves e configurar o SSH para acesso remoto utilizando chaves públicas. A seguir, é ilustrado o processo de geração das chaves e as linhas de configuração do serviço SSH dos servidores.

```.sh
# no servidor1
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa_s1
# no servidor2
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa_s2 
# em ambos os servidores
cp -a ~/.ssh/id_rsa_s?.pub ~/.ssh/authorized_keys
```

Em ambos os servidores (habilitar o uso de chaves públicas e indicar o arquivo das chaves autorizadas), caso o serviço SSH ainda não esteja devidamente configurado. Os comandos a seguir devem ser executados como root.
```.sh
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config 
echo "AuthorizedKeysFile	.ssh/authorized_keys" >> /etc/ssh/sshd_config 
```

A chave privada deve ser copiada para a máquina / conta onde o gerador de certificados será executado. Exemplo: 
```.sh
# assumindo usuário "alice" na máquina "meu-pc"
scp servidor1:/home/publicador/.ssh/id_rsa_s1 ~/.ssh/
scp servidor2:/home/publicador/.ssh/id_rsa_s2 ~/.ssh/
```

Finalmente, para cada um dos servidores da lista, pode ser incluída uma configuração no arquivo padrão do SSH (*config*), na máquina e conta do próprio usuário (e.g. alice) que manipula a ferramenta.
O arquivo *config* fica tipicamente em *~/.ssh/*.
A seguir é apresentado um exemplo de configuração de dois servidores (*servidor1* e *servidor2*) remotos para publicação dos certificados. 

```.sh
Host servidor1
	Hostname 192.168.1.100
	User publicador
	Port 22
	IdentitiesOnly yes
	PubkeyAuthentication yes
	IdentityFile ~/.ssh/id_rsa_s1

Host servidor2
	Hostname 192.168.1.101
	User publicador
	Port 22
	IdentitiesOnly yes
	PubkeyAuthentication yes
	IdentityFile ~/.ssh/id_rsa_s2
```

Utilizando o túnel SSH, o *rsync* necessita apenas copiar/sincronizar o diretório do repositório local de certificados com o diretório remoto de destino/publicação dos certificados nos servidores *web* *e.g.*, */var/www/certificados/* no *servidor1*).

NOTA: o *rsync* deve estar instalado nos servidores. Além disso, deve ser configurado um servidor Web e um diretório para publicação dos certificados.

## Configurando o script

Os arquivos de configuração estão na pasta /etc/

**1 - emailer.cfg** - Nome e senha do enviador de e-mails.
```
SENDER=assina@unihacker.club
APPPASS=abcd-abcd-abacd-abcd
```

**2 - gpg.cfg** - iIdentificador da chave gpg e da chave gpg pública.
```
GPG_KEY_ID=assina@unihacker.club
GPG_PUB_KEY_ID=A1BC12CD3EF4G567
```

**3 - servidores.cfg** - Localização das pastas que deverão ser sincronizadas nos servidores, com o identificador do ssh, e caminho da pasta.
```
servidor1:/var/www/certificados/
servidor2:/var/www/certificados/
servidor3:/var/www/certificados/
```

**4 - url_publica.cfg** - Url pública do(s) certificado(s) no(s) servidor(es) web. Link que será inserido nos certificados.
```
https://certificado.unihacker.club
```

## Utilização

```sh
./gerador.sh <template.tex> <participantes.csv> <"AbbrDoEvento"> <SenhaGPG> <SenhaHMAC> <SenhaDoHistory> <[teste/deploy]>
```
1. **Nome do template** caminho do arquivo LaTeX.
2. **Nome do arquivo CSV** caminho do arquivo com os dados dos participantes.
3. **Abreviação do Nome do Evento**.
4. **Senha GPG**, utilizada para geração das assinaturas utilizando a chave privada OpenPGP.
5. **Senha HMAC**, utilizada pela função HMAC para gerar os códigos de autenticação dos QR Codes.
6. **Senha do arquivo histórico**, utilizada para cifrar e decifrar o banco de dados local, que contém o histórico de eventos e certificados gerados.
7. **Modo de execução**. Pode ser *teste* ou *deploy*. Onde teste apenas gerará os certificados e deploy enviará os certificados para os e-mails dos participantes e para os servidores.

## Ambientes 

A ferramenta foi testada e utilizada na prática nos seguintes ambientes:

Debian 10:

- Kernel = `Linux deb 4.19.0-17-amd64 #1 SMP Debian 4.19.194-1 (2021-06-10) x86_64 GNU/Linux`
- Python = `Python 2.7.16`
- Ferramentas = `rsync version 3.1.3 protocol version 31, p7zip 16.02+dfsg-6, qrencode version 4.0.2, gpg (GnuPG) 2.2.12 (libgcrypt 1.8.4), OpenSSH_7.9p1 Debian-10_deb10u2, OpenSSL 1.1.1d, Tex 3.14159265 (TeX Live 2019/dev/Debian)`

macOS Catalina 10.15.7:

- Kernel = `Darwin 19.6.0 Kernel Version 19.6.0: Tue Jan 12 22:13:05 PST 2021; root:xnu-6153.141.16~1/RELEASE_X86_64 x86_64`
- Python = `Python 3.9.5 e Python 2.7.18`
- Ferramentas = `rsync  version 3.2.3 protocol version 31, p7zip 16.02_5, qrencode 4.0.2, gpg (GnuPG) 2.2.14 (libgcrypt 1.8.4), OpenSSH_8.1p1, LibreSSL 2.7.3, shasum 6.01, OpenSSL 1.1.1k, texlive 2020`

## Créditos
* Maurício El Uri
* Diego Kreutz
