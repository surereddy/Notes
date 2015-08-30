#!/bin/sh

#This is for linux. For other OS, need to modify.
#Usage:
#   ÓÃrootµÇÂ½ root#./tcpdump_by_ip.sh <ip1> <ip2> <file.pkg>

tcpdump "((src net $1 mask 255.255.255.255) and (dst net $2 mask 255.255.255.255)) or ((src net $2 mask 255.255.255.255) and (dst net $1 mask 255.255.255.255))" -s 0 -w $3
