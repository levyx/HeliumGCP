#!/bin/bash
#
# Copyright (C) 2013-2015, Levyx, Inc.
#

INTERVAL=1
LOGDIR=logs
ARGS=$#

err_exit() {
	echo "$*"
	exit -1;
}

prereqs() {
	which iostat >/dev/null 2>&1 || err_exit "missing iostat"
	which vmstat >/dev/null 2>&1 || err_exit "missing vmstat"
}

usage() {
	echo ""
	echo "	Usage: log.sh start|stop"
	echo ""
}


log_start() {
	[ -d $LOGDIR ] || err_exit "missing $LOGDIR"
	vmstat $INTERVAL > ${LOGDIR}/vmstat.log &
	echo $! > ${LOGDIR}/pid
	
	iostat -xm $INTERVAL > ${LOGDIR}/iostat.log &
	echo $! >> ${LOGDIR}/pid

	(while true; do 						\
		top -b -n 1 | head -n 10 >> ${LOGDIR}/top.log;		\
		echo "" >> ${LOGDIR}/top.log;				\
		sleep $INTERVAL;					\
	done) &
	echo $! >> ${LOGDIR}/pid
} 

log_stop() {
	[ -d $LOGDIR ] || err_exit "missing $LOGDIR"
	for pid in `cat ${LOGDIR}/pid`; do
		kill -9 $pid
	done
	
	echo "Stats under $LOGDIR"
}

main() {
	prereqs
	LOGDIR=$2

	if [ $1 == "start" ]; then
		log_start
	elif [ $1 == "stop" ]; then
		log_stop
	else
		usage && err_exit
	fi
}

[ $# -ne 2 ] && usage && err_exit
main $1 $2
