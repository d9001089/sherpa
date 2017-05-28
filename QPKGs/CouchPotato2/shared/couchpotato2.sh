#!/bin/sh

WAITER_PATHFILE="$(getcfg SHARE_DEF defVolMP -f /etc/config/def_share.info)/.qpkg/wait-for-Entware.sh"
[ -e "$WAITER_PATHFILE" ] && . "$WAITER_PATHFILE" 300

Init()
	{

	# package specific
	QPKG_NAME="CouchPotato2"
	local TARGET_SCRIPT="CouchPotato.py"
	GIT_HTTP_URL="http://github.com/CouchPotato/CouchPotatoServer.git"

	QPKG_PATH="$(/sbin/getcfg $QPKG_NAME Install_Path -f /etc/config/qpkg.conf)"
	SETTINGS_PATH="${QPKG_PATH}/config"
	local SETTINGS_PATHFILE="${SETTINGS_PATH}/config.ini"
	local SETTINGS_DEFAULT_PATHFILE="${SETTINGS_PATHFILE}.def"
	STORED_PID_PATHFILE="/tmp/${QPKG_NAME}.pid"

	local SETTINGS="--data_dir $SETTINGS_PATH"
	local PIDS="--pid_file $STORED_PID_PATHFILE"

	# generic
	DAEMON_OPTS="$TARGET_SCRIPT --daemon $SETTINGS $PIDS"
	QPKG_GIT_PATH="${QPKG_PATH}/${QPKG_NAME}"
	LOG_PATHFILE="/var/log/${QPKG_NAME}.log"
	DAEMON="/opt/bin/python2.7"
	GIT_HTTPS_URL=${GIT_HTTP_URL/http/git}
	GIT_CMD="/opt/bin/git"
	errorcode=0

	[ ! -f "$SETTINGS_PATHFILE" ] && [ -f "$SETTINGS_DEFAULT_PATHFILE" ] && cp "$SETTINGS_DEFAULT_PATHFILE" "$SETTINGS_PATHFILE"

	return 0

	}

QPKGIsActive()
	{

	# $? = 0 if $QPKG_NAME is active
	# $? = 1 if $QPKG_NAME is not active

	local returncode=0
	local active=false
	local msg=""

	[ -f "$STORED_PID_PATHFILE" ] && { active_pid=$(cat "$STORED_PID_PATHFILE"); [ -d "/proc/$active_pid" ] && active=true ;}

	if [ "$active" == "true" ]; then
		msg="= ($QPKG_NAME) is active"
	else
		msg="= ($QPKG_NAME) is not active"
		returncode=1
	fi

	echo "$msg" | tee -a "$LOG_PATHFILE"
	return $returncode

	}

UpdateQpkg()
	{

	local returncode=0
	local msg=""
	SysFilePresent "$GIT_CMD" || { errorcode=1; return 1 ;}

	echo -n "* updating ($QPKG_NAME): " | tee -a "$LOG_PATHFILE"
	messages="$({

	[ -d "${QPKG_GIT_PATH}/.git" ] || $GIT_CMD clone "$GIT_HTTPS_URL" "$QPKG_GIT_PATH" || $GIT_CMD clone "$GIT_HTTP_URL" "$QPKG_GIT_PATH"
	cd "$QPKG_GIT_PATH" && $GIT_CMD checkout master && $GIT_CMD pull && /bin/sync

	} 2>&1)"
	result=$?

	if [ "$result" == "0" ]; then
		msg="OK"
		echo -e "$msg" | tee -a "$LOG_PATHFILE"
		echo -e "${messages}" >> "$LOG_PATHFILE"
	else
		msg="failed!\nresult=[$result]"
		echo -e "$msg\n${messages}" | tee -a "$LOG_PATHFILE"
		returncode=1
	fi

	return $returncode

	}

StartQPKG()
	{

	local returncode=0
	local msg=""

	cd "$QPKG_GIT_PATH"

	echo -n "* starting ($QPKG_NAME): " | tee -a "$LOG_PATHFILE"
	messages="$(PATH=${PATH} ${DAEMON} ${DAEMON_OPTS} 2>&1)"
	result=$?

	if [ "$result" == "0" ]; then
		msg="OK"
		echo -e "$msg" | tee -a "$LOG_PATHFILE"
		echo -e "${messages}" >> "$LOG_PATHFILE"
	else
		msg="failed!\nresult=[$result]"
		echo -e "$msg\n${messages}" | tee -a "$LOG_PATHFILE"
		returncode=1
	fi

	return $returncode

	}

StopQPKG()
	{

	local maxwait=60

	active_pid=$(cat "$STORED_PID_PATHFILE"); i=0

	kill $active_pid
	echo -n "* stopping ($QPKG_NAME) with SIGTERM: " | tee -a "$LOG_PATHFILE"; echo -n "waiting for upto $maxwait seconds: "

	while true; do
		while [ -d /proc/$active_pid ]; do
			sleep 1
			let i+=1
			echo -n "$i, "
			if [ "$i" -ge "$maxwait" ]; then
				echo -n "failed! " | tee -a "$LOG_PATHFILE"
				kill -9 $active_pid
				echo "sent SIGKILL." | tee -a "$LOG_PATHFILE"
				rm -f "$STORED_PID_PATHFILE"
				break 2
			fi
		done

		rm -f "$STORED_PID_PATHFILE"
		echo "OK"; echo "stopped OK in $i seconds" >> "$LOG_PATHFILE"
		break
	done

	}

SessionSeparator()
	{

	# $1 = message

	printf '%0.s-' {1..20}; echo -n " $1 "; printf '%0.s-' {1..20}

	}

SysFilePresent()
	{

	# $1 = pathfile to check

	[ -z "$1" ] && return 1

	if [ ! -e "$1" ]; then
		echo "! A required NAS system file is missing [$1]"
		errorcode=1
		return 1
	else
		return 0
	fi

	}

Init

if [ "$errorcode" -eq "0" ]; then
	case "$1" in
		start)
			echo -e "$(SessionSeparator "start requested")\n= $(date)" >> "$LOG_PATHFILE"
			! QPKGIsActive && UpdateQpkg; StartQPKG || errorcode=1
			;;

		stop)
			echo -e "$(SessionSeparator "stop requested")\n= $(date)" >> "$LOG_PATHFILE"
			QPKGIsActive && StopQPKG || errorcode=1
			;;

		restart)
			echo -e "$(SessionSeparator "restart requested")\n= $(date)" >> "$LOG_PATHFILE"
			QPKGIsActive && StopQPKG; UpdateQpkg; StartQPKG || errorcode=1
			;;

		*)
			echo "Usage: $0 {start|stop|restart}"
			;;
	esac
fi

exit $errorcode