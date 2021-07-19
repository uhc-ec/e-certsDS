import smtplib
from email.mime.text import MIMEText
import sys
from random import randint
from time import sleep

if len(sys.argv) < 6:
	print "Usage: " + sys.argv[0] + "<event_name> <file_URL> <file_GPG> <file_PASS> <n_participants> <n_hours>"
	sys.exit()

# Define to/from
sender = 'Clube UniHacker <unihackerclub@gmail.com>'
event_name = sys.argv[1]
URL = sys.argv[2]
URL_GPG = sys.argv[3]
file_password = sys.argv[4]
n_participants = sys.argv[5]
n_hours = sys.argv[6]
GPG_USER = sys.argv[7]

sleep(randint(1,6))

# Create message
body = "\nDear UniHacker.Club Projet Leader,\n\n"
body = body + "The PDF certificates for " + event_name + " have been issued and published online."
body = body + "\n\nThe list of participants is available at " + URL
body = body + "\n\nNumber of participants: " + n_participants
body = body + "\n\nTotal number of hours: " + str(n_hours)
body = body + "\n\nTo check the GPG signature: "
body = body + "\n\nshell$ wget --output-document=" + URL.rsplit('/', 1)[1] + " " + URL
body = body + "\n\nshell$ wget --output-document=" + URL_GPG.rsplit('/', 1)[1] + " " + URL_GPG
body = body + "\n\nshell$ gpg --keyserver keyserver.ubuntu.com --recv-key " + GPG_USER
body = body + "\n\nshell$ gpg --verify " + URL_GPG.rsplit('/', 1)[1] + " " + URL.rsplit('/', 1)[1] 
body = body + "\n\nTo uncompress the password-protected file: "
body = body + "\n\nshell$ 7z x -y -p" + file_password + " " + URL.rsplit('/', 1)[1]
body = body + "\n\nYours faithfully,"
body = body + "\n\nDev Null @ UniHacker.Club\n\n WARNING: Do NOT reply this message! Your reply will go directly to /dev/null! In other words, nobody will read it! ;-)\n\n"

msg = MIMEText(body)
msg['Subject'] = "[unihacker.club] " + event_name + ": summary"
msg['From'] = sender
msg['To'] = "info@unihacker.club"

# Create server object with SSL option
#server = smtplib.SMTP_SSL('smtp.zoho.com', 465)
server = smtplib.SMTP_SSL('smtp.gmail.com', 465)

# Perform operations via server
server.login('unihackerclub@gmail.com', 'senhaGmail')
server.sendmail(sender, ["info@unihacker.club", "sandro@unihacker.club"], msg.as_string())
server.quit()
