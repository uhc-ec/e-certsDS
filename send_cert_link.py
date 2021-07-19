import smtplib
from email.mime.text import MIMEText
import sys
from random import randint
from time import sleep

if len(sys.argv) < 5:
	print ("Usage: " + sys.argv[0] + " <user_name> <user_email> <URL> <event_name>")
	sys.exit()

# Define to/from
sender = 'Clube UniHacker <unihackerclub@gmail.com>'
recipient = sys.argv[2]
URL = sys.argv[3]
user = sys.argv[1]
user = user #.decode('iso-8859-1').encode('utf8')
first = user.split(" ")[0]
event_name = sys.argv[4]

sleep(randint(1,12))

# Create message
body = "\nCaro(a) " + first + ",\n\n"
body = body + "Um novo certificado (arquivo .PDF) foi gerado para você (" + user + ")."
body = body + "\n\nO download pode ser realizado através da URL " + URL
body = body + "\n\nAs seguintes URLs também podem ser utilizadas (são sistemas de backup): "
body = body + "\n\n - URL C1: " + URL.replace("//certificado", "//c1")
body = body + "\n - URL C2: " + URL.replace("//certificado", "//c2")
body = body + "\n\nA assinatura GPG do certificado está disponível em " + URL + ".asc"
body = body + "\n\nCordialmente,"
body = body + "\n\nDev Null @ UniHacker.Club\n\n ALERTA: Não responda esta mensagem! A sua eventual resposta será redirecionada para /dev/null! Em outras palavras, ninguém irá ler a sua resposta! ;-)\n\n"

msg = MIMEText(body)
msg['Subject'] = "[unihacker.club] " + event_name + ": certificado PDF disponível para você"
msg['From'] = sender
msg['To'] = recipient

# Create server object with SSL option
#server = smtplib.SMTP_SSL('smtp.zoho.com', 465)
server = smtplib.SMTP_SSL('smtp.gmail.com', 465)

# Perform operations via server
server.login('unihackerclub@gmail.com', 'senhaGmail')
server.sendmail(sender, [recipient, "info@unihacker.club","segundo@email.com"], msg.as_string())
server.quit()
