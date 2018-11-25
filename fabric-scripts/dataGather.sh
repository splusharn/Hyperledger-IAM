#!/bin/sh
DOCKERFILE="$1docker.csv"
PSFILE="$1ps.csv"
SYSFILE="$1sys.csv"

sar -u -r -n DEV -d -b 5 >> $SYSFILE &
#xterm -hold -e sar -u -r -n DEV -d -b 5 10 >> $sysFile &

while true
do
docker stats -a --no-stream >> $DOCKERFILE
ps -Ao user,args,comm,pid,pcpu,pmem --sort=-pcpu | head -n 8 >> $PSFILE
sleep 5
done