#!/bin/bash
# This script will build out one master and a specified number of AFL slave
# instances inside of screen sessions.
# Example usage:
# ./afl-multi.sh -n 32 -i /root/testcases -o /root/syncdir -c "tcpdump -nr @@"
#
# Author: Matt Hand (@matterpreter)

usage() {
  echo "Usage: $0 <args>" 1>&2
  echo "    -n = Number of AFL jobs to create (2 to 64)" 1>&2
  echo "    -i = Directory containing your testcase(s)" 1>&2
  echo "    -o = Location of your empty output directory" 1>&2
  echo '    -c = Command to run AFL against in quotes (ex. "tcpdump -nr @@")' 1>&2
  exit 1
}

build () {
  echo "[*] Initiating build of $instances fuzzers running 'afl-fuzz -i $testcases -o $syncdir $afl_command'"
  echo "[*] Creating master instance"
  screen -S master -d -m afl-fuzz -i /root/testcases/ -o /root/syncdir/ -M master $afl_command
  # Added in the sleep timers to help control random crashes on startup
  sleep 5
  for ((i=1;i<instances;i++));
  do
    echo "[*] Creating slave instance #$i"
    #echo "command: screen -S slave$i -d -m afl-fuzz -i $testcases -o $syncdir -S slave$i $afl_command"
    screen -S slave$i -d -m afl-fuzz -i /root/testcases/ -o /root/syncdir/ -S slave$i $afl_command
    sleep 5
  done
  let "i=i-1"
  echo "[+] $i fuzzers created!"
}

while getopts ":n:i:o:c:" o; do
    case "${o}" in
        n)
            if [[ ${OPTARG} -gt 2 && ${OPTARG} -lt 64 ]]; then
                instances=${OPTARG}
            else
                usage
            fi
            ;;
        i)
            testcases=${OPTARG}
            ;;
        o)
            syncdir=${OPTARG}
            ;;
        c)
            afl_command=${OPTARG}
            ;;
        h)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

build

echo "Listing of active screen sessions:"
screen -ls
sleep 3.14
echo "+=================================+"
echo "afl-whatsup Summary:"
afl-whatsup -s $syncdir
