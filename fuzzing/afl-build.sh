#!/bin/bash
###
# Simple script to automatically build my AFL test bench.
###

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

#Update and install needed applications if they're not already there.
echo "[+] Updating system..."
apt-get update && apt-get -y upgrade >>build.log 2>&1
echo "[+] Installing required packages..."
apt-get install -y wget build-essential clang screen vim python3 python3-setuptools gdb >>build.log 2>&1

#Setup the system for AFL
echo "[+] Installing latest AFL..."
echo core >/proc/sys/kernel/core_pattern
mkdir ~/testcases
mkdir ~/findings
mount -t ramfs -o size=512m ramfs ~/testcases

#Download and install AFL
rm afl-latest.tgz
wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz >>build.log 2>&1
tar xzvf afl-latest.tgz >>build.log 2>&1
cd afl*
make && make install >>build.log 2>&1
cd llvm_mode
LLVM_CONFIG=llvm-config-3.8 make >>build.log 2>&1
cd ..
make install >>build.log 2>&1

#Download and install afl-utils
echo "[+] Installing afl-utils..."
cd /opt
git clone https://github.com/rc0r/afl-utils.git >>build.log 2>&1
cd afl-utils
python3 setup.py install >>build.log 2>&1
echo "source /usr/lib/python3.5/site-packages/exploitable-1.32_rcor-py3.5.egg/exploitable/exploitable.py" >> ~/.gdbinit

#Download and install PEDA
echo "[+] Installing PEDA..."
git clone https://github.com/longld/peda.git ~/peda >>build.log 2>&1
echo "source ~/peda/peda.py" >> ~/.gdbinit

AFL-GCC="$(which afl-gcc)"

echo "[+] AFL Test Bench ready to go!"
echo "afl-gcc location: ${AFL-GCC}"
