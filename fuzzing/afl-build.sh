#!/bin/bash
###
# Simple script to automatically build my AFL test bench.
###

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

#Update and install needed applications if they're not already there.
apt-get update && apt-get -y upgrade
apt-get install -y wget build-essential clang screen vim python3 python3-setuptools

#Setup the system for AFL
echo core >/proc/sys/kernel/core_pattern
mkdir /root/testcases
mkdir /root/findings

#Download and install AFL
rm afl-latest.tgz
wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
tar xzvf afl-latest.tgz
cd afl*
make && make install
cd llvm_mode
LLVM_CONFIG=llvm-config-3.8 make
cd ..
make install

#Download and install afl-utils
cd /opt
git clone https://github.com/rc0r/afl-utils.git
cd afl-utils
python3 setup.py install
echo "source /usr/lib/python3.5/site-packages/exploitable-1.32_rcor-py3.5.egg/exploitable/exploitable.py" >> ~/.gdbinit

echo "[+] AFL Test Bench ready to go!"
