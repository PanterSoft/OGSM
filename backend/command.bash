#!/bin/bash

# Static vars
WORK_DIR=$(pwd)

# ARGS
SERVERNAME="mcserver"

# Dynamic vars
SERVERS_FOLDER="$WORK_DIR/Server"
SERVER_HOME_PATH=$SERVERS_FOLDER/$SERVERNAME

check_dependencys() {
    # Check if LinuxGSM installer exists
    if (test -f "./linuxgsm.sh") then
        echo "linuxgsm.sh exists"
    else
        wget -O linuxgsm.sh "https://linuxgsm.sh"
    fi
}

check_server_path() {
    if (! test -d $SERVER_HOME_PATH) then
        echo "$SERVER_HOME_PATH"
        #mkdir $SERVER_HOME_PATH
    fi
}

install_srv() {
    mkdir $SERVER_HOME_PATH
    cp linuxgsm.sh $SERVER_HOME_PATH
    cd $SERVER_HOME_PATH
    bash linuxgsm.sh $SERVERNAME
    bash $SERVERNAME install
}

run_init() {
    check_dependencys
    check_server_path
    #install_srv
}

run_init