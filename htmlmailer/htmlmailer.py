#!/usr/bin/env python
import sys
import smtplib
import MimeWriter
import mimetools
import getpass
import cStringIO
import base64
from optparse import OptionParser

####REQUIRED TO BE CHANGED BY USER!####
#Server variables
host = '' #Most accounts must be verified before sending email through!
port = '' #Try 25, 587, or 465
subject = "" #Subject of the message
######################################

#Setup arguments
usage = "Usage: %prog -m <message file> -t <recipient file>"
parser = OptionParser(usage=usage)
parser.add_option('-m', '--message', dest='message_file', type='string', \
    help='File with the body of the message you want to send.')
parser.add_option('-t', '--recipient', dest='recipient_file', type='string', \
    help='File with a list of emails you want to send the message to.')
(opts, args) = parser.parse_args()
message_file = opts.message_file
recipient_file = opts.recipient_file
if len(sys.argv) < 2:
    parser.print_help()
    sys.exit(1)

def createhtmlmail(subject, message_file, recipient):
    f = open(message_file, 'r')
    nonunique = f.read()
    f.close()
    unique = nonunique.replace("$IDENTIFIER$", base64.b64encode(recipient))
    out = cStringIO.StringIO()
    htmlin = cStringIO.StringIO(unique)
    writer = MimeWriter.MimeWriter(out)
    writer.addheader("To", recipient)
    writer.addheader("Subject", subject)
    writer.addheader("MIME-Version", "1.0")
    writer.startmultipartbody("alternative")
    writer.flushheaders()
    subpart = writer.nextpart()
    subpart.addheader("Content-Transfer-Encoding", "quoted-printable")
    pout = subpart.startbody("text/html", [("charset", 'us-ascii')])
    mimetools.encode(htmlin, pout, 'quoted-printable')
    htmlin.close()
    writer.lastpart()
    msg = out.getvalue()
    out.close()
    return msg

if __name__=="__main__":
    user = raw_input("Please provide the username: ") #Typically the full sender address
    passw = getpass.getpass("Please provide the password for " + user + ": ")
    server = smtplib.SMTP(host, port)
#    server.set_debuglevel(1) #Uncomment to turn on debugging
    server.ehlo()
    server.starttls()
    server.login(user, passw)
    with open(recipient_file) as r:
        for recipient in r:
            message = createhtmlmail(subject, message_file, recipient)
            try:
                server.sendmail(user, recipient, message)
                print "[+] Successfully sent email to " + recipient
            except smtplib.SMTPException as e:
                print "[!] Error: unable to send email to " + recipient
                print e
    server.quit()
