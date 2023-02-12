#!/bin/bash

export WORK_DIR=$(pwd)
export LOG_LEVEL="-V" # -s = Silent; -V = Verbose; -D = Debug; -Z = No Logfile

bash $WORK_DIR/src/command.sh install mcserver
