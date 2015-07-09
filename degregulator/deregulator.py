import sys
import os

interface = str(sys.argv[1])
power = sys.argv[2]
grab_pow = "iwconfig " + interface + ''' | grep Tx-Power | awk 'BEGIN {FS="=[ \t]*|/[ \t]*|:[ \t]*|[ \t]+"}{print $8 $9}' '''

old_pow = os.popen(grab_pow).read()
print "[+] Starting inteface power: " + old_pow.strip()

print "[+] Configuring the interface..."
os.system("ifconfig " + interface + " down") #Take the interface down
os.system("iw reg set BO") #Set the country code to Bolivia
os.system("iwconfig " + interface + " txpower  " + power) #Set the Tx-Power
os.system("ifconfig " + interface + " up") #Bring the interface back up

new_pow = os.popen(grab_pow).read()
print "[+] New interface power: " + new_pow.strip()
