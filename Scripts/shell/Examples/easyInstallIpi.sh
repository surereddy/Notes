#!/bin/bash

################
# By TanJunliang
################

myExit()
{
    if [ $# == 2 ]; then
        for TARGETHOST in `echo ${EII_HOST_MAIN} ${EII_HOST_SPARC}`; do
            MYCMD="ssh root@${TARGETHOST} 'rm -f ${EII_WORK_TMP}/${EII_TMP_CONF_SH} ${EII_WORK_TMP}/${EII_TMP_USER_CONF} ${EII_WORK_TMP}/${EII_TMP_DL_SH} ${EII_WORK_TMP}/${EII_TMP_MNT_SH} ${EII_WORK_TMP}/${EII_TMP_MIX_SH} ${EII_WORK_TMP}/${EII_TMP_DC_SH}'"
            echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
            chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
            /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
                set timeout 72000
                expect {
                -nocase "Password:" {send "inet.inet\r"}
                }
                expect eof
                exit 1
            }'
            rm -f "${EII_WORK_TMP}/${EII_TMP_SH}"
        done
    fi
    END_TIME="`date`"    
    echo "${PRG_NAME} started at ${START_TIME}, finished at ${END_TIME}!"
    exit $1
}

source `dirname $0`/easyInstallIpi.conf
if [ $? -ne 0 ]; then
    myExit 1
fi

PRG_NAME=$0
START_TIME="`date`"
    

### work settings
EII_WORKSPACE=$(cd `dirname $0` && pwd && (cd - >/dev/null))
EII_WORK_TMP=/tmp
EII_TMP_SH=.eiicmd.sh
EII_TMP_CONF_SH=.eiicmdconf.sh
EII_TMP_USER_CONF=.eiiuserconf
EII_TMP_DL_SH=.eiicmddl.sh
EII_TMP_MNT_SH=.eiicmdmnt.sh
EII_TMP_MIX_SH=.eiicmdmix.sh
EII_TMP_DC_SH=.eiicmddc.sh

if [ "${EII_SWITCH_DOWNLOAD_IPI}" == "" ];then
  EII_SWITCH_DOWNLOAD_IPI="Y"
fi
echo "Will download IPI iso or not:${EII_SWITCH_DOWNLOAD_IPI}"
### ENV check setting
if [ ! -f "${EII_WORKSPACE}/irisAppConfig.properties_conf" ]; then
    echo "File ${EII_WORKSPACE}/irisAppConfig.properties_conf not exist!"
    myExit 1
fi
if [ ! -d ${EII_WORK_TMP} ]; then
    mkdir ${EII_WORK_TMP}
fi
if [ "${EII_SWITCH_DOWNLOAD}" = "Y" ]; then
    if [ "${EII_IPI_DOWNLOAD_USER}" == "" ]; then
        echo "Please input the log user for download host ${EII_IPI_DOWNLOAD_HOST}:"
        read EII_IPI_DOWNLOAD_USER
    fi
    if [ "${EII_IPI_DOWNLOAD_PASSWD}" == "" ]; then
        echo "Please input the password for download host ${EII_IPI_DOWNLOAD_USER}@${EII_IPI_DOWNLOAD_HOST}:"
        read -s EII_IPI_DOWNLOAD_PASSWD
    fi
fi

for TARGETHOST in `echo ${EII_HOST_MAIN} ${EII_HOST_SPARC}`; do
cat > ${EII_WORK_TMP}/${EII_TMP_CONF_SH} << EOF
irisConfigAdmin -exportall
[ \$? != 0 ] && echo "irisConfigAdmin exportall failed!" && exit 1
cat /export0/home/iris/irisInstalls/irisAppConfig.properties ${EII_WORK_TMP}/${EII_TMP_USER_CONF} | egrep -v "^#" | sed 's/ = /~/g' | awk -F'~' '{myarr[\$1]=\$2;} END{ for (i in myarr) print i" = "myarr[i]}' > /export0/home/iris/irisInstalls/irisAppConfig.properties_tmp && mv /export0/home/iris/irisInstalls/irisAppConfig.properties_tmp /export0/home/iris/irisInstalls/irisAppConfig.properties
[ \$? != 0 ] && echo "irisConfigAdmin conf failed!" && exit 1
irisConfigAdmin -import | grep "DB Import is Finished"
[ \$? != 0 ] && echo "irisConfigAdmin import failed!" && exit 1
echo "irisConfigAdmin exportall & import success!" && exit 0
EOF
chmod +x ${EII_WORK_TMP}/${EII_TMP_CONF_SH}

cat > ${EII_WORK_TMP}/${EII_TMP_MIX_SH} << EOF
#!/opt/sfw/bin/expect -f

proc mix_install {mixname ipiversion args} {
spawn runIrisCli
set timeout 72000
set runCliRet 1
expect {
   "irisShell >" {send "mix\r"; system "rm -f /tmp/.eiilog.tmp"; log_file /tmp/.eiilog.tmp; exp_continue}
   "Do you really want to switch (y/n)>" {send "y\r"; exp_continue}
   "Select The Install Mix >" {log_file; set mixn [system "cat /tmp/.eiilog.tmp | grep \"\$mixname\" | awk -F'\[' '{print \\\$2}' | awk -F'\]' '{print \\\$1}' > /tmp/.eiimix.tmp"]; set mixn [exec cat /tmp/.eiimix.tmp]; set i [exec rm -f /tmp/.eiilog.tmp /tmp/.eiimix.tmp ]; send \$mixn\r}
   -nocase "Another instance of irisCli is already running" { set runCliRet 0 }
}

if { \$runCliRet < 1 } {
   return 1
}

expect {
   "irisShell >" {send "menu\r"; exp_continue}
   "Selection (Press <Enter> key to exit, 't' for top menu) >" {send "2\r"}
}

set toActivate 0
set isInstSuc 0
set isActSuc 0
expect {
   "Selection (Press <Enter> key to exit, 't' for top menu) >" {send "2\r"; exp_continue}
   "remember to run the activation" {set isInstSuc 1; set toActivate 1; sleep 1; send "\r"}
   "Done oracle wallet configuration" {set isInstSuc 1}
   "Oracle Installation Complete" {set isInstSuc 1}
   -re "The mix:.*TouchPoint Database Deployment.*was successfully installed." {set isInstSuc 1}
   -re "The mix:.*Touchpoint Aggregation Models Deployment.*was successfully installed." {set isInstSuc 1}
   -nocase "The action cannot be performed due to" {}
   "media could not be detected" {}
}

if { \$isInstSuc > 0  && \$toActivate < 1 } {
  expect {
     "Selection (Press <Enter> key to exit, 't' for top menu)" { send "\r" }
  }
} elseif { \$isInstSuc > 0 && \$toActivate > 0 } {
  set isloop 1
  set loopcnt 0
  while { \$isloop > 0 && \$loopcnt < 5 } {
  set isloop 0
  expect {
     "irisShell >" {system "rm -f /tmp/.eiilog.tmp"; log_file /tmp/.eiilog.tmp; send "activate\r"}
  }
  set processrunning 0
  expect {
     "Select The Version >" {log_file; set actn [system "cat /tmp/.eiilog.tmp | grep \"\$mixname\" | grep \$ipiversion | awk -F'\[' '{print \\\$2}' | awk -F'\]' '{print \\\$1}' > /tmp/.eiimix.tmp"]; set actn [exec cat /tmp/.eiimix.tmp]; set i [exec rm -f /tmp/.eiilog.tmp /tmp/.eiimix.tmp ]; send \$actn\r}
     -nocase -re "Error.*The following processes are still running" { sleep 1; set processrunning 1}
  }
  if { \$processrunning < 1 } {
  expect {
     -nocase -re "Activation.*successful.*" {set isActSuc 1}
     -nocase -re "Activate.*with the following mixes content" {set isActSuc 1}
     "already has active mixes, adding additional activations" {set isActSuc 1}
     -re ".*activation complete" {set isActSuc 1}
     -nocase "The action cannot be performed due to" { if { "\$mixname" == "Iris LDAP" } {set isloop 1; incr loopcnt} }
     -nocase "Failed during activation script" {}
     -nocase "The system could be in a inconsistent state" {}
  }
  }
  }
}

set timeout 1
expect {
    "irisShell >" {send "exit\r"}
}
if { \$isInstSuc < 1 || (\$toActivate > 0 && \$isActSuc < 1) } {
   send_user "\n\n============================= Install \$mixname \$ipiversion failed! ===========================\n\n"
   return 1
}
expect eof

send_user "\n\n============================= Install \$mixname \$ipiversion successful! ===========================\n\n"
return 0

}


set toInstallVersion [lindex \$argv 0]
set toInstallMix [lindex \$argv 1]

set result 0
set result [mix_install "\$toInstallMix" "\$toInstallVersion"]

expect eof

exit \$result

EOF
chmod +x ${EII_WORK_TMP}/${EII_TMP_MIX_SH}

cat > ${EII_WORK_TMP}/${EII_TMP_DL_SH} << EOF
#!/bin/bash
export DOWNLOAD_HOST=\$1
#export LOGUSER=
#export LOGPASSWD=
export VERSION=\$2
export DOWNLOAD_REMOTE_PATH=\$3
export DOWNLOAD_LOCAL_PATH=\$4
export DOWNLOAD_ORACLE=\$5
export DOWNLOAD_IPI=\$6
ARCH=\`(arch|egrep 86 >/dev/null && echo x86) || echo sparc\`
FILEPREFIX="cd-sol-"
if [ "\${DOWNLOAD_IPI}" == "Y" ];then
  DLFILEARR=(\${FILEPREFIX}\${ARCH}-\${VERSION}.iso \${FILEPREFIX}touchpoint-\${VERSION}.iso)
else
  DLFILEARR=(\${FILEPREFIX}\${ARCH}-\${VERSION}.iso)
fi
if [ "\${DOWNLOAD_ORACLE}" == "Y" ]; then
    DLFILEARR[\${#DLFILEARR[@]}]=\${FILEPREFIX}\${ARCH}-oracle-\${VERSION}.iso
fi
if [ "\${ARCH}" == "sparc" ]; then
    DLFILEARR[\${#DLFILEARR[@]}]=\${FILEPREFIX}\${ARCH}-adf-\${VERSION}.iso
    DLFILEARR[\${#DLFILEARR[@]}]=\${FILEPREFIX}\${ARCH}-cognos-\${VERSION}.iso
fi

if [ -f "\${DOWNLOAD_LOCAL_PATH}" ]; then
    rm -f "\${DOWNLOAD_LOCAL_PATH}"
fi

if [ ! -d "\${DOWNLOAD_LOCAL_PATH}" ]; then
    mkdir -p "\${DOWNLOAD_LOCAL_PATH}"
    if [ $? -ne 0 ]; then
        echo "download failed!"
        exit 1
    fi
fi
for i in \${DLFILEARR[@]}; do
    export i
    if [ ! -f "\${DOWNLOAD_LOCAL_PATH}/\$i" ]; then
        /opt/sfw/bin/expect -c '
        set user [exec sh -c "echo \\\$LOGUSER"]
        set password [exec sh -c "echo \\\$LOGPASSWD"]
        set myhost [exec sh -c "echo \\\$DOWNLOAD_HOST"]
        set remoteDir [exec sh -c "echo \\\$DOWNLOAD_REMOTE_PATH"]
        set localDir [exec sh -c "echo \\\$DOWNLOAD_LOCAL_PATH"]
        set file [exec sh -c "echo \\\$i"]
        set timeout 72000
        spawn scp -o StrictHostKeyChecking=no \$user@\$myhost:\$remoteDir/\$file \$localDir
        expect {
           default {exit 2}
           "node name or service name not known" {exit 3}
           "Are you sure you want to continue connecting (yes/no)?" {set timeout 0; send "yes\n"; exp_continue}
           "100%" {exit 0}
           -nocase "password:" {send "\$password\r"}
        }
        set timeout 72000
        expect {
           default {exit 2}
            -nocase "password:" {exit 4}
           "No such file or directory" {exit 5}
           "Not a directory" {exit 6}
           "100%" {exit 0}
        }
        '
        RET=\$?
        if [ \$RET -ne 0 ]; then
           echo "download failed!"
           exit \$RET
        fi
    fi
done
if [ \$# -gt 6 ]; then
    ARCH=\`(arch|egrep 86 >/dev/null && echo i386) || echo sparc\`
    shift 5
    export DC_LOCAL_DIR=\$1
    [ ! -d \$DC_LOCAL_DIR ] && mkdir -p \$DC_LOCAL_DIR
    shift
    DC_DL_FILES=\$@
    for i in \$(echo \$DC_DL_FILES); do
        ls \$DC_LOCAL_DIR | grep \$(basename \$i) > /dev/null 2>&1
        [ \$? -eq 0 ] && continue
        if [ "\`basename \$i\`" = "*" ]; then
            i="\$i\$ARCH*"
        fi
        export i
        /opt/sfw/bin/expect -c '
        set user [exec sh -c "echo \\\$LOGUSER"]
        set password [exec sh -c "echo \\\$LOGPASSWD"]
        set myhost [exec sh -c "echo \\\$DOWNLOAD_HOST"]
        set localDir [exec sh -c "echo \\\$DC_LOCAL_DIR"]
        set file [exec sh -c "echo \\\$i"]
        set timeout 72000
        spawn scp -o StrictHostKeyChecking=no \$user@\$myhost:\$file \$localDir
        expect {
           default {exit 2}
           eof {exit 0}
           "node name or service name not known" {exit 3}
           "Are you sure you want to continue connecting (yes/no)?" {set timeout 0; send "yes\n"; exp_continue}
           "100%" {exit 0}
           -nocase "password:" {send "\$password\r"}
        }
        set timeout 72000
        expect {
           eof {exit 0}
            -nocase "password:" {exit 4}
           "No such file or directory" {exit 5}
           "Not a directory" {exit 6}
           "100%" {exp_continue}
        }
        '
        RET=\$?
        if [ \$RET -ne 0 ]; then
           echo "download failed!"
           exit \$RET
        fi
    done
fi
echo "download done"
EOF
chmod +x ${EII_WORK_TMP}/${EII_TMP_DL_SH}

cat > ${EII_WORK_TMP}/${EII_TMP_MNT_SH} << EOF
#!/bin/bash
ACTION="\$1"
VER_FILE="\$2"
ISO_PATH="\$3"
MNT_IRIS="\$4"
MNT_ORACLE="\$5"
MNT_TP="\$6"
MNT_COGNOS="\$7"
MNT_ADF="\$8"
TO_MNT_ORACLE="\$9"
TO_MNT_IPI="\$10"
FILEPREFIX="cd-sol-"
ARCH=\`(arch|egrep 86 >/dev/null && echo x86) || echo sparc\`

[ ! -d \${MNT_IRIS} ] && mkdir \${MNT_IRIS}
[ ! -d \${MNT_ORACLE} ] && mkdir \${MNT_ORACLE}
[ ! -d \${MNT_TP} ] && mkdir \${MNT_TP}
if [ "\${ARCH}" == "sparc" ]; then
    [ ! -d \${MNT_ADF} ] && mkdir \${MNT_ADF}
    [ ! -d \${MNT_COGNOS} ] && mkdir \${MNT_COGNOS}
fi
if [ "\$1" = "mount" ] ; then
    SUCFLAG=0
    while true; do
        umount \${MNT_IRIS} >/dev/null 2>&1
        lofiadm -d \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-\${VER_FILE}.iso >/dev/null 2>&1
        lofiadm -a \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-\${VER_FILE}.iso
        [ \$? != 0 ] && break
        mount -F hsfs \`lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-\${VER_FILE}.iso 2>/dev/null\` \${MNT_IRIS}
        [ \$? != 0 ] && break
        if [ "\${TO_MNT_ORACLE}" == "Y" ]; then
            umount \${MNT_ORACLE} >/dev/null 2>&1
            lofiadm -d \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-oracle-\${VER_FILE}.iso >/dev/null 2>&1
            lofiadm -a \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-oracle-\${VER_FILE}.iso
            [ \$? != 0 ] && break
            mount -F hsfs \`lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-oracle-\${VER_FILE}.iso 2>/dev/null\` \${MNT_ORACLE}
            [ \$? != 0 ] && break
        fi
        umount \${MNT_TP} >/dev/null 2>&1
        if [ "\${TO_MNT_IPI}" == "Y" ]; then        
          lofiadm -d \`lofiadm \${ISO_PATH}/\${FILEPREFIX}touchpoint-\${VER_FILE}.iso 2>/dev/null\` >/dev/null 2>&1
          lofiadm -a \${ISO_PATH}/\${FILEPREFIX}touchpoint-\${VER_FILE}.iso
          [ \$? != 0 ] && break
          mount -F hsfs \`lofiadm \${ISO_PATH}/\${FILEPREFIX}touchpoint-\${VER_FILE}.iso\` \${MNT_TP}
          [ \$? != 0 ] && break
        fi
        if [ "\${ARCH}" == "sparc" -a -e \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-cognos-\${VER_FILE}.iso ] ; then
            umount \${MNT_COGNOS} >/dev/null 2>&1
            lofiadm -d \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-cognos-\${VER_FILE}.iso >/dev/null 2>&1
            lofiadm -a \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-cognos-\${VER_FILE}.iso
            [ \$? != 0 ] && break
            mount -F hsfs \`lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-cognos-\${VER_FILE}.iso 2>/dev/null\` \${MNT_COGNOS}
            [ \$? != 0 ] && break
        fi
        if [ "\${ARCH}" == "sparc" -a -e \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-adf-\${VER_FILE}.iso ] ; then
            umount \${MNT_ADF} >/dev/null 2>&1
            lofiadm -d \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-adf-\${VER_FILE}.iso >/dev/null 2>&1
            lofiadm -a \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-adf-\${VER_FILE}.iso
            [ \$? != 0 ] && break
            mount -F hsfs \`lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-adf-\${VER_FILE}.iso 2>/dev/null\` \${MNT_ADF}
            [ \$? != 0 ] && break
        fi
        SUCFLAG=1
        break
    done
    if [ \$SUCFLAG -eq 1 ]; then
        echo "mount success!"
        exit 0
    else
        echo "mount failed!"
        exit 1
    fi
fi
if [ "\$1" = "umount" ] ; then
        lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-\${VER_FILE}.iso >/dev/null 2>&1 && umount \`lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-\${VER_FILE}.iso\`
        lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-\${VER_FILE}.iso >/dev/null 2>&1 && lofiadm -d \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-\${VER_FILE}.iso
        lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-oracle-\${VER_FILE}.iso >/dev/null 2>&1 && umount \`lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-oracle-\${VER_FILE}.iso\`
        lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-oracle-\${VER_FILE}.iso >/dev/null 2>&1 && lofiadm -d \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-oracle-\${VER_FILE}.iso
        if [ "\${TO_MNT_IPI}" == "Y" ]; then      
          lofiadm \${ISO_PATH}/\${FILEPREFIX}touchpoint-\${VER_FILE}.iso >/dev/null 2>&1 && umount \`lofiadm \${ISO_PATH}/\${FILEPREFIX}touchpoint-\${VER_FILE}.iso\`
          lofiadm \${ISO_PATH}/\${FILEPREFIX}touchpoint-\${VER_FILE}.iso >/dev/null 2>&1 && lofiadm -d \${ISO_PATH}/\${FILEPREFIX}touchpoint-\${VER_FILE}.iso
        fi
        lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-cognos-\${VER_FILE}.iso >/dev/null 2>&1 && umount \`lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-cognos-\${VER_FILE}.iso\`
        lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-cognos-\${VER_FILE}.iso >/dev/null 2>&1 && lofiadm -d \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-cognos-\${VER_FILE}.iso
        lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-adf-\${VER_FILE}.iso >/dev/null 2>&1 && umount \`lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-adf-\${VER_FILE}.iso\`
        lofiadm \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-adf-\${VER_FILE}.iso >/dev/null 2>&1 && lofiadm -d \${ISO_PATH}/\${FILEPREFIX}\${ARCH}-adf-\${VER_FILE}.iso
        echo "umount finished!"
        exit 0
fi
EOF
chmod +x ${EII_WORK_TMP}/${EII_TMP_MNT_SH}


cat > ${EII_WORK_TMP}/${EII_TMP_DC_SH} << EOF
#!/bin/bash
cat /etc/passwd | grep -w bia >/dev/null 2>&1
if [ \$? -ne 0 ]; then
    sudo groupadd dba
    sudo useradd bia
    sudo usermod -g dba bia
fi
DC_DL_DIR=\$1
export DC_IRIS_HOME=~iris
export DC_WORK_DIR=~iris/DC

if [ -x ~iris/ngbase/pm/bin/pmStop ]; then
    ~iris/ngbase/pm/bin/pmStop
fi
if [ -x ~iris/irisInstalls/ipiPreproc/scripts/ipiAlias.sh ]; then
    ~iris/irisInstalls/ipiPreproc/scripts/ipiAlias.sh stopSql
    ~iris/irisInstalls/ipiPreproc/scripts/ipiAlias.sh stopIt7
    ~iris/irisInstalls/ipiPreproc/scripts/ipiAlias.sh stopLog
fi

if [ -d ~iris/server ]; then
    /opt/sfw/bin/expect -c '
        spawn sh -c "cd \\\$DC_IRIS_HOME/server && (ls ./INETdcast-deactivate >/dev/null 2>&1 && ./INETdcast-deactivate; ls ./INETdr-deactivate >/dev/null 2>&1 && ./INETdr-deactivate; ls ./INETbase-deactivate >/dev/null 2>&1 && ./INETbase-deactivate)"
        set timeout 72000
        expect {
        eof {exit 0}
        "Would you like to deactivate the package" {send "y\r"; exp_continue}
        }
    '
    RET=\$?
    if [ \$RET -ne 0 ]; then
        echo "DC install failed!"
        exit \$RET
    fi
fi
export PKGS="\`pkginfo | grep INET | awk '{print \$2}'; pkginfo | grep IRISgen | awk '{print \$2}'\`"
/opt/sfw/bin/expect -c '
    set timeout 72000
    spawn sh -c "for i in \`echo \\\$PKGS\`; do sudo pkgrm \\\$i; done"
    expect {
        eof {exit 0}
        "Do you want to remove this package" {send "y\r"; exp_continue}
        "Do you want to continue with the removal of this package" {send "y\r"; exp_continue}
    }
'
RET=\$?
if [ \$RET -ne 0 ]; then
    echo "DC install failed!"
    exit \$RET
fi

if [ -d \$DC_WORK_DIR ]; then
    sudo rm -fr \$DC_WORK_DIR/*
    rmdir \$DC_WORK_DIR
fi

mkdir -p \$DC_WORK_DIR
cp \$DC_DL_DIR/* \$DC_WORK_DIR/
cd \$DC_WORK_DIR

/opt/sfw/bin/expect -c '
    spawn installSparc -b /opt -t /tmp -f
    set timeout 72000
    expect {
        eof {exit 0}
        "Please enter root Password" {send "inet.inet\r"; exp_continue}
        "Do you want to continue with installation" {send "y\r"; exp_continue}
        "FAILURE" {exit 1}
        "Please check installSparc" {exit 0}
    }
'
RET=\$?
if [ \$RET -ne 0 ]; then
    echo "DC install failed!"
    exit \$RET
fi

/opt/sfw/bin/expect -c '
    spawn sh -c "cd \\\$DC_WORK_DIR && ./swActivate.sh"
    set timeout 72000
    expect {
        eof {exit 1}
        "Are you sure you want to continue" {send "y\r"; exp_continue}
        "Where is Cognos installed" {send "\r"; exp_continue}
        "Software Activation Completed" {exit 0}
    }
'
RET=\$?
if [ \$RET -ne 0 ]; then
    echo "DC install failed!"
    exit \$RET
fi

\$DC_IRIS_HOME/server/etc/iris-uacn/activate_dcast_preproc_all | grep -w collocation && \$DC_IRIS_HOME/server/etc/iris-uacn/activate_dcast_preproc_all collocation
\$DC_IRIS_HOME/server/etc/iris-uacn/activate_dcast_preproc_all | grep -w colocation1 && \$DC_IRIS_HOME/server/etc/iris-uacn/activate_dcast_preproc_all colocation1
RET=\$?
if [ \$RET -ne 0 ]; then
    echo "DC install failed!"
    exit \$RET
fi

echo "DC install success!"
exit 0
EOF
chmod +x ${EII_WORK_TMP}/${EII_TMP_DC_SH}

    echo "Setting install environment for ${TARGETHOST}..."
    MYCMD="scp ${EII_WORKSPACE}/irisAppConfig.properties_conf root@${TARGETHOST}:${EII_WORK_TMP}/${EII_TMP_USER_CONF} && scp ${EII_WORK_TMP}/${EII_TMP_CONF_SH} root@${TARGETHOST}:${EII_WORK_TMP}/${EII_TMP_CONF_SH} && scp ${EII_WORK_TMP}/${EII_TMP_MIX_SH} root@${TARGETHOST}:${EII_WORK_TMP}/${EII_TMP_MIX_SH} && scp ${EII_WORK_TMP}/${EII_TMP_DL_SH} root@${TARGETHOST}:${EII_WORK_TMP}/${EII_TMP_DL_SH} && scp ${EII_WORK_TMP}/${EII_TMP_MNT_SH} root@${TARGETHOST}:${EII_WORK_TMP}/${EII_TMP_MNT_SH} && scp ${EII_WORK_TMP}/${EII_TMP_DC_SH} root@${TARGETHOST}:${EII_WORK_TMP}/${EII_TMP_DC_SH}" 
    echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
    chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
    /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
    set timeout 60
    expect {
    -nocase "password" {send "inet.inet\r"; exp_continue}
    "Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
    "No such file or directory" {exit 1}
    "Not a directory" {exit 1}
    "100%" {exp_continue}
    }
    ' > /dev/null
    RET=$?
    rm -f "${EII_WORK_TMP}/${EII_TMP_SH}"
    if [ $RET != 0 ]; then
        echo "set work env for install failed for host:${TARGETHOST}!"
        myExit 1 1
    fi
done

### ISO download, mount
if [ "${EII_SWITCH_DOWNLOAD}" = "Y" ]; then
for TARGETHOST in `echo ${EII_HOST_MAIN} ${EII_HOST_SPARC}`; do
    DOFLAG=1
    while [ $DOFLAG -eq 1 ]; do
    echo "${EII_DC_HOSTS}" | grep -w "$TARGETHOST" > /dev/null
    DODCDLFLAG=$?
    if [ "${EII_SWITCH_DC}" = "Y" -a $DODCDLFLAG -eq 0 ]; then
        MYCMD_DC="${EII_DC_DOWNLOAD_LOCAL_PATH} ${EII_IPI_DC_DOWNLOAD_FILE_ARR[@]}"
    fi
    echo "Start download for ${TARGETHOST}..."
    if [ "${TARGETHOST}" == "${EII_DB_SERVER}" ]; then
        DLD_ORACLE=Y
    else
        DLD_ORACLE=N
    fi
    if [ "${EII_SWITCH_DOWNLOAD_IPI}" == "Y" ]; then
        DLD_IPI=Y
    else
        DLD_IPI=N
    fi

    MYCMD="ssh root@${TARGETHOST} 'echo XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX > /dev/null && LOGUSER=${EII_IPI_DOWNLOAD_USER} && LOGPASSWD=${EII_IPI_DOWNLOAD_PASSWD} && export LOGUSER && export LOGPASSWD && ${EII_WORK_TMP}/${EII_TMP_DL_SH} ${EII_IPI_DOWNLOAD_HOST} ${EII_IPI_VERSION} ${EII_IPI_DOWNLOAD_REMOTE_PATH} ${EII_IPI_DOWNLOAD_LOCAL_PATH} ${DLD_ORACLE} ${DLD_IPI} ${MYCMD_DC}' "
    echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
    chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
    (sleep 1 && rm -f "${EII_WORK_TMP}/${EII_TMP_SH}") &
    /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
        set timeout 72000
        expect {
        -nocase "Password:" {send "inet.inet\r"}
        }
        expect {
          -nocase "download failed" { exit 91 }
          -nocase "download done" { exit 90 }
        }
        expect eof
        exit 1
    }
    '
    RET=$?
    wait
    if [ $RET -eq 0 ]; then
        DOFLAG=1
        continue
    fi
    if [ $RET -eq 91 ]; then
        echo "Download failed for ${TARGETHOST}!"
        myExit 1 1
    fi
    DOFLAG=0
    done
done
fi

for TARGETHOST in `echo ${EII_HOST_MAIN} ${EII_HOST_SPARC}`; do
    if [ "${EII_SWITCH_MOUNT}" = "Y" ]; then
        ACTION=mount
    elif [ "${EII_SWITCH_MOUNT}" = "N" ]; then
        ACTION=umount
    else
        break
    fi
    MNT_RETRYCNT=0
    MNT_MAX_RETRYCNT=3
    if [ "${TARGETHOST}" == "${EII_DB_SERVER}" ]; then
        TO_MNT_ORACLE=Y
    else
        TO_MNT_ORACLE=N
    fi
    if [ "${EII_SWITCH_DOWNLOAD}" = "Y" ]; then
        TO_MNT_IPI=Y
    else
        TO_MNT_IPI=N
    fi    
    while [ $MNT_RETRYCNT -lt $MNT_MAX_RETRYCNT ]; do
    MYCMD="ssh root@${TARGETHOST} '${EII_WORK_TMP}/${EII_TMP_MNT_SH} ${ACTION} ${EII_IPI_VERSION} ${EII_IPI_DOWNLOAD_LOCAL_PATH} ${EII_MOUNT_IRIS} ${EII_MOUNT_ORACLE} ${EII_MOUNT_TOUCHPNT} ${EII_MOUNT_COGNOS} ${EII_MOUNT_ADF} ${TO_MNT_ORACLE} ${TO_MNT_IPI}' "
    echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
    chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
    /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
        set timeout 72000
        expect {
        -nocase "Password:" {send "inet.inet\r"}
        }
        expect {
          -nocase "mount failed" { exit 1 }
          -nocase "mount success" { exit 0 }
          -nocase "umount finished" { exit 0 }
        }
        expect eof
        exit 1
    }
    '
    RET=$?
    rm -f "${EII_WORK_TMP}/${EII_TMP_SH}"
    if [ $RET -ne 0 ]; then
        MNT_RETRYCNT=`expr $MNT_RETRYCNT + 1`
        if [ $MNT_RETRYCNT -lt $MNT_MAX_RETRYCNT ]; then
            continue
        fi
        echo "Mount failed for ${TARGETHOST}!"
        myExit 1 1
    else
        break
    fi
    done
done



### clean
for TARGETHOST in `echo ${EII_HOST_MAIN} ${EII_HOST_SPARC}`; do
echo "${EII_CLEAN_HOSTS}" | grep -w "$TARGETHOST" > /dev/null
HOSTDOFLAG=$?
if [ "${EII_SWITCH_CLEAN}" = "Y" -a $HOSTDOFLAG -eq 0 ]; then
    echo -e "\n\n!!!!!!!! You are going to do the clean on ${TARGETHOST} ... !!!!!!!!\n\n"
    sleep 10
    echo "Now begin the clean ..."
    DATADISK=`cat ${EII_WORKSPACE}/irisAppConfig.properties_conf | grep DATA_DISKS | awk -F'/' '{print $NF}' | awk -F"'" '{print $1}'`
    if [ "${TARGETHOST}" == "${EII_DB_SERVER}" ]; then
        MYCMD="ssh root@${TARGETHOST} 'cd ${EII_MOUNT_IRIS} && ./cleanup.sh && dd if=/dev/zero bs=1048576 count=30 of=/dev/rdsk/${DATADISK} && (umount /u01/app && rm -fr /u01 || sleep 1) && echo \"cleanup done.\"'"
    else
        MYCMD="ssh root@${TARGETHOST} 'cd ${EII_MOUNT_IRIS} && ./cleanup.sh && echo \"cleanup done.\"'"
    fi
    echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
    chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
    /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
        set timeout 72000
        expect {
        -nocase "password" {send "inet.inet\r"; exp_continue}
        "Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
        -nocase -re "Please enter.*yes.*to accept.*no.*to reject" { send "y\r"; exp_continue }
        -nocase "ERROR: Please logout from this user account" { exit 1}
        -nocase "One or more users logged in" { exit 1}
        "Clean up script completed" { exp_continue }
        -nocase "cleanup done" { exit 0 }
        "records out" { exit 0 }
        }
        expect eof
        exit 1
    }
    '
    RET=$?
    rm -f "${EII_WORK_TMP}/${EII_TMP_SH}"
    if [ $RET != 0 ]; then
        echo "Clean up failed for ${TARGETHOST}!"
        myExit 1 1
    fi
    echo "Clean up successful for ${TARGETHOST}!"
fi
done


###------- install ----------
for TARGETHOST in `echo ${EII_HOST_MAIN} ${EII_HOST_SPARC}`; do
# basic install
echo "${EII_BASIC_HOSTS}" | grep -w "$TARGETHOST" > /dev/null
HOSTDOFLAG=$?
if [ "${EII_SWITCH_BASIC}" = "Y" -a $HOSTDOFLAG -eq 0 ]; then
    if [ "${TARGETHOST}" == "${EII_DB_SERVER}" ]; then
        MYCMD="ssh root@${TARGETHOST} 'pkill -9 java; cd ${EII_MOUNT_IRIS} && ./irisInstallServer.sh -o' && ssh root@${TARGETHOST} 'su - iris -c \"createDerbySeedDb\"' && echo 'basic install successful'"
    else
        MYCMD="ssh root@${TARGETHOST} 'pkill -9 java; cd ${EII_MOUNT_IRIS} && ./irisInstallServer.sh' && echo 'basic install successful'"
    fi
    echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
    chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
    /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
        set timeout 72000
        expect {
        -nocase "password" {send "inet.inet\r"; exp_continue}
        "Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
        "GEO server detected, run geoServerInstall.sh to continue the installation" {send "Y\r"; exp_continue}
        -nocase -re "ERROR.*Cannot continue Installation" { exit 1}
        -re "ERROR.*" { exit 1}
        -nocase "basic install successful" { exit 0 }
        }
        expect eof
        exit 1
    }
    '
    RET=$?
    rm -f "${EII_WORK_TMP}/${EII_TMP_SH}"
    if [ $RET != 0 ]; then
        echo "Basic install failed for ${TARGETHOST}!"
        myExit 1 1
    fi
    echo "Basic install successful for ${TARGETHOST}!"
fi

# configure setting
echo "${EII_CONF_HOSTS}" | grep -w "$TARGETHOST" > /dev/null
HOSTDOFLAG=$?
if [ "${EII_SWITCH_CONF}" = "Y" -a $HOSTDOFLAG -eq 0 ]; then
    MYCMD="ssh root@${TARGETHOST} 'su - iris -c \"${EII_WORK_TMP}/${EII_TMP_CONF_SH} && rm -f ${EII_WORK_TMP}/${EII_TMP_CONF_SH}\"'"
    echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
    chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
    
    /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
    set timeout 600
    expect {
    -nocase "password" {send "inet.inet\r"; exp_continue}
    "Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
    -re "irisConfigAdmin.*fail" {exit 1}
    -nocase "update and import one more time" {exit 1}
    -re "irisConfigAdmin.*success" {exit 0}
    }
    expect eof
    '
    if [ $? != 0 ]; then
        echo "irisConfigAdmin failed for host ${TARGETHOST}!"
        myExit 1 1
    else
        echo "irisConfigAdmin successful for host ${TARGETHOST}!"
    fi
fi

# mix install
echo "${EII_MIX_HOSTS}" | grep -w "$TARGETHOST" > /dev/null
HOSTDOFLAG=$?
if [ "${EII_SWITCH_MIX}" = "Y" -a $HOSTDOFLAG -eq 0 ]; then
i=0
while [ $i -lt ${#EII_MIX_ITEMS[@]} ]; do
    INSTALL_FLAG=1
    if [ "${EII_MIX_ITEMS[$i]}" == "x86" ] && [ "${TARGETHOST}" != "${EII_HOST_MAIN}" ]; then
            INSTALL_FLAG=0
    fi
    if [ "${EII_MIX_ITEMS[$i]}" == "sparc" ] && [ "${TARGETHOST}" != "${EII_HOST_SPARC}" ]; then
            INSTALL_FLAG=0
    fi

    if [ "$INSTALL_FLAG" == "1" ]; then
    RETRYCNT=0
    while [ $RETRYCNT -lt $EII_MIX_MAX_RETRY_CNT ]; do
    MYCMD="ssh root@${TARGETHOST} 'su - "${EII_MIX_ITEMS[$i+1]}" -c \"ps -ef | grep cli.admin | grep -v grep | sed -n \\\"s/[ ]*\\\\([a-z]*\\\\)[ ]*\\\\([0-9]*\\\\)[ ]*.*/\\\\2/p\\\" | xargs kill -9 2>/dev/null; "${EII_WORK_TMP}/${EII_TMP_MIX_SH}" "${EII_IPI_VERSION}" \\\""${EII_MIX_ITEMS[$i+2]}"\\\"\"'"
    echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
    chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
    MIX_START_TIME="`date`"
    /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
    set timeout 72000
    expect {
        -nocase "password" {send "inet.inet\r"}
        "Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
    }
    expect {
        default { exit 1 }
        -re "=== Install.*failed.*" { exit 1 }
        -re "=== Install.*success.*" { exit 0 }
    }
    expect eof
    '
    if [ $? -ne 0 ]; then
        echo "======== Install ${EII_MIX_ITEMS[$i+2]} failed for ${EII_IPI_VERSION} on ${TARGETHOST}!(start at ${MIX_START_TIME}, end at `date`)"
        #for install issues
        if [ "${EII_SWITCH_FIXBUG}" == "Y" ]; then
            RETRYCNT=`expr $RETRYCNT + 1`
            if [ $RETRYCNT -eq ${EII_MIX_MAX_RETRY_CNT} ]; then
                myExit 1 1
            fi
            if [ "${EII_MIX_ITEMS[$i+2]}" == "Iris Main (UUMS and CAS)" ]; then
                MYCMD="ssh root@${TARGETHOST} 'svcadm disable irisOracleCheck'"
                echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
                chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
                /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
                set timeout 72000
                expect {
                    -nocase "password" {send "inet.inet\r"}
                    "Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
                }
                expect eof
                '
                echo "Fixed an install issue for Iris Main (UUMS and CAS)!"
            fi
            echo "Wait for a while to retry...($RETRYCNT of $EII_MIX_MAX_RETRY_CNT)"
            sleep ${EII_MIX_MAX_RETRY_INTERVAL}
            continue
        fi
        #:~
        myExit 1 1
    fi
    #for install issues
    if [ "${EII_SWITCH_FIXBUG}" == "Y" ] && [ "${EII_MIX_ITEMS[$i+2]}" == "Iris Oracle Client and Wallet Setup" ]; then
        MYCMD="ssh root@${TARGETHOST} 'su - iris -c \"[ ! -L /export0/home/iris/irisInstalls/current -a -d /export0/home/iris/irisInstalls/current/exp_util ] && mv /export0/home/iris/irisInstalls/current/exp_util /export0/home/iris/irisInstalls && rmdir /export0/home/iris/irisInstalls/current && ln -s /export0/home/iris/irisInstalls/${EII_IPI_VERSION} /export0/home/iris/irisInstalls/current && mv /export0/home/iris/irisInstalls/exp_util /export0/home/iris/irisInstalls/current/\"'"
        echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
        chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
        /opt/sfw/bin/expect -c 'spawn '${EII_WORK_TMP}/${EII_TMP_SH}'
        set timeout 72000
        expect {
            -nocase "password" {send "inet.inet\r"}
            "Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
        }
        expect eof
        '
        echo "Fixed an install issue for current link!"
    fi
    #:~
    rm -f "${EII_WORK_TMP}/${EII_TMP_SH}"
    break
    done
    echo "======== Install ${EII_MIX_ITEMS[$i+2]} successful for ${EII_IPI_VERSION} on ${TARGETHOST}!(start at ${MIX_START_TIME}, end at `date`)"
    fi

    i=`expr $i + 3`
done
fi

done

if [ "$EII_SWITCH_DC" == "Y" ]; then
    MYCMD="ssh root@${EII_DC_HOSTS} 'su - iris -c \"${EII_WORK_TMP}/${EII_TMP_DC_SH} ${EII_DC_DOWNLOAD_LOCAL_PATH}\"'"
    echo $MYCMD > "${EII_WORK_TMP}/${EII_TMP_SH}"
    chmod +x "${EII_WORK_TMP}/${EII_TMP_SH}"
    /opt/sfw/bin/expect -c 'spawn sh -c '${EII_WORK_TMP}/${EII_TMP_SH}'
    set timeout 72000
    expect {
        -nocase "password" {send "inet.inet\r"}
        -nocase "DC install failed" {exit 1}
        -nocase "DC install success" {exit 0}
    }
    expect eof
    '
    RET=$?
    rm -f "${EII_WORK_TMP}/${EII_TMP_SH}"
fi

myExit 0 1
