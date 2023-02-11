#!/bin/bash

export LOGDIR=$WORK_DIR/logs
export DATE=`date +"%Y-%m-%d"`
export DATETIME=`date +"%Y%m%d_%H%M%S"`

NO_JOB_LOGGING=0

# $0 = Filename; $1 = Debug-Level; $2 = Action; $3 = Server-Name
#ScriptName= #`basename $0`
Job="$2" # Action
JobClass="$3" # Servername

colblk='\033[0;30m' # Black - Regular
colred='\033[0;31m' # Red
colgrn='\033[0;32m' # Green
colylw='\033[0;33m' # Yellow
colpur='\033[0;35m' # Purple
colwht='\033[0;97m' # White
colrst='\033[0m'    # Text Reset

verbosity=4

### verbosity levels
silent_lvl=0
crt_lvl=1
err_lvl=2
wrn_lvl=3
ntf_lvl=4
inf_lvl=5
dbg_lvl=6

## esilent prints output even in silent mode
function lsilent () { verb_lvl=$silent_lvl elog "$@" ;}
function lnotify () { verb_lvl=$ntf_lvl elog "$@" ;}
function lok ()    { verb_lvl=$ntf_lvl elog "SUCCESS - $@" ;}
function lwarn ()  { verb_lvl=$wrn_lvl elog "${colylw}WARNING${colrst} - $@" ;}
function linfo ()  { verb_lvl=$inf_lvl elog "${colwht}INFO${colrst} ---- $@" ;}
function ldebug () { verb_lvl=$dbg_lvl elog "${colgrn}DEBUG${colrst} --- $@" ;}
function lerror () { verb_lvl=$err_lvl elog "${colred}ERROR${colrst} --- $@" ;}
function lcrit ()  { verb_lvl=$crt_lvl elog "${colpur}FATAL${colrst} --- $@" ;}
function ldumpvar () { for var in $@ ; do edebug "$var=${!var}" ; done }
function elog() {
        if [ $verbosity -ge $verb_lvl ]; then
                datestring=`date +"%Y-%m-%d %H:%M:%S"`
                echo -e "$datestring - $@"
        fi
}

function Log_Open() {
        if [ $NO_JOB_LOGGING -eq 1 ] ; then
                linfo "Not logging to a logfile because -Z option specified." #(*)
        else
                [[ -d $LOGDIR/$JobClass ]] || mkdir -p $LOGDIR/$JobClass
                Pipe=${LOGDIR}/$JobClass/${Job}_${DATETIME}.pipe
                mkfifo -m 700 $Pipe
                LOGFILE=${LOGDIR}/$JobClass/${Job}_${DATETIME}.log
                exec 3>&1
                tee ${LOGFILE} <$Pipe >&3 &
                teepid=$!
                exec 1>$Pipe
                PIPE_OPENED=1
                # Logging String
                lnotify Logging to $LOGFILE  # (*)
                [ $SUDO_USER ] && enotify "Sudo user: $SUDO_USER" #(*)
        fi
}

function Log_Close() {
        if [ ${PIPE_OPENED} ] ; then
                exec 1<&3
                sleep 0.2
                ps -pid $teepid >/dev/null
                if [ $? -eq 0 ] ; then
                        # a wait $teepid whould be better but some
                        # commands leave file descriptors open
                        sleep 1
                        kill  $teepid
                fi
                rm $Pipe
                unset PIPE_OPENED
        fi
}


OPTIND=1
while getopts ":sVDZ" opt ; do
# shellcheck disable=SC2220
        case $opt in
        s)
                verbosity=$silent_lvl
                edebug "-s specified: Silent mode"
                ;;
        V)
                verbosity=$inf_lvl
                edebug "-V specified: Verbose mode"
                ;;
        G)
                verbosity=$dbg_lvl
                edebug "-D specified: Debug mode"
                ;;
        Z)
                NO_JOB_LOGGING=0
                ;;
        esac
done

# Options for logging
#lwarn "this is a warning"
#lerror "this is an error"
#linfo "this is an information"
#ldebug "debugging"
#lcrit "CRITICAL MESSAGE!"
#ldumpvar HOSTNAME