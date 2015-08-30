Readme:
I have a ¡®crash detector¡¯ running on 3r and 12r (/iris/tmp/IFCCrash.sh). 
It checks for the timeouts in dmesg and will stop apps running when its sees a failure. 
Also in failure, it prints a message ( and my cell #! ) to all open terminals. 

geo@g511-mbc1000-1-1r:/iris/tmp$ more ./IFCCrashMBC.sh
#!/bin/bash

# run if user hits control-c
control_c()
{
  echo " - user stopped..."
  exit 1
}
trap control_c SIGINT

# now check dmesg for
echo "Checking for Timeouts in kern.log..."
while true ; do
  if tail -100 /var/log/kern.log | grep "A Completion Timeout Occured" ; then
    crm resource stop mc
    mydate="`date`"
    echo "" | wall
    echo "!!!" | wall
    echo "!!! Found PCIe completion timeout at $mydate - Call GREG - 972 824-1761!!" | wall
    echo "!!!" | wall
    exit 1
  fi
  sleep 2
done

exit 0