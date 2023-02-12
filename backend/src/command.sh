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
    if (! id -u $SERVERNAME >/dev/null 2>&1) then
        linfo "Creating User $SERVERNAME"
        useradd -N -s /bin/bash/ $SERVERNAME -d $SERVER_HOME_PATH
        passwd -d $SERVERNAME
        usermod -aG gameservers,sudo $SERVERNAME
    else
        linfo "User already exists"
    fi
}

check_server_path() {
    if (! test -d $SERVERS_PATH) then
        mkdir -p $SERVERS_PATH
        linfo "Created Server Path"
    else
        linfo "Server Path Exists/Valid"
    fi
}

install_srv() {
    check_user
    if (! test -d $SERVER_HOME_PATH) then
        mkdir $SERVER_HOME_PATH
        sudo chown $SERVERNAME:gameservers $SERVER_HOME_PATH
        cp linuxgsm.sh $SERVER_HOME_PATH
        cd $SERVER_HOME_PATH
        sudo -u $SERVERNAME bash linuxgsm.sh $SERVERNAME
        sudo -u $SERVERNAME bash $SERVERNAME ai
        linfo "Server Install Finished"
    else
        lerror "!!! Server is Already Installed !!!"
    fi
}

start_srv() {
    linfo "Server Starting"
}

stop_srv() {
    linfo "Server Stopping"
}

restart_srv() {
    linfo "Server Restarting"
}

status_srv() {
    linfo "Server Status"
}

uninstall_srv() {
    linfo "Server Uninstall Started"
}

run_init() {
    linfo "Backend init Started"
    check_dependencys
    check_server_path
    groupadd -f gameservers
}

run() {
    Log_Open
    case $ACTION in
        install)
            install_srv;;
        start)
            start_srv;;
        stop)
            stop_srv;;
        restart)
            restart_srv;;
        status)
            status_srv;;
        uninstall)
            uninstall_srv;;
        *)
            run_init;;
    esac
    Log_Close
}

run