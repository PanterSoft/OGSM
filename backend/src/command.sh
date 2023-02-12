#!/bin/bash

### Logging ###

#lwarn # Warning
#lerror # Error
#linfo # Info
#ldebug # Debugging
#lcrit # Critical Error
#ldumpvar HOSTNAME # Dump all Enviromnent Vars

# ARGS
ACTION=$1
SERVERNAME=$2

# Vars
SERVERS_PATH="$WORK_DIR/Servers"
SERVER_HOME_PATH="$SERVERS_PATH/$SERVERNAME"
source $WORK_DIR/src/logging.sh $LOG_LEVEL $ACTION $SERVERNAME

check_dependencys() {
    # Check if LinuxGSM installer exists
    if (test -f "./linuxgsm.sh") then
        linfo "linuxgsm.sh exists"
    else
        wget -O linuxgsm.sh "https://linuxgsm.sh"
    fi
}

check_user() {
    if (id -u $SERVERNAME != 0) then
        useradd $SERVERNAME -d $SERVER_HOME_PATH
    else
        linfo "User already exists"
    fi
}

check_server_path() {
    if (! test -d $SERVERS_PATH) then
        mkdir -p $SERVERS_PATH
        linfo $SERVERS_PATH
    fi
}

install_srv() {
    if (! test -d $SERVER_HOME_PATH) then
        mkdir $SERVER_HOME_PATH
        cp linuxgsm.sh $SERVER_HOME_PATH
        cd $SERVER_HOME_PATH
        bash linuxgsm.sh $SERVERNAME
        bash $SERVERNAME install
    else
        lerror "!!! A Server is Already Installed !!!"
    fi
}

run_init() {
    check_dependencys
    check_server_path
    install_srv
}

# RUN
Log_Open
run_init
Log_Close