#!/bin/bash
#
# Copyright (C) 2013-2015, Levyx, Inc.
#

LOGDIR=logs_4k_5M
KVPERF=../kvperf/kvperf
CFG=../kvperf/cfg_4k_5M
DEVICE1=he://.//dev/nvme0n1
DEVICE2=he://.//dev/nvme0n1,/dev/nvme0n2
DEVICE4=he://.//dev/nvme0n1,/dev/nvme0n2,/dev/nvme0n3,/dev/nvme0n4

run() {
	./log.sh start $LOGDIR
	dev=$1

	# Updates
	sudo $KVPERF -c $CFG -T 28 -u -v 4000 -n 5000000 -d $dev > ${LOGDIR}/result_4k.out

	# Rand gets
	sudo $KVPERF -c $CFG -p -r -v 4000 -n 5000000 -T 16 -l ${LOGDIR}/lat_16.out -d $dev >> ${LOGDIR}/result_4k.out
	sudo $KVPERF -c $CFG -p -r -v 4000 -n 5000000 -T 32 -l ${LOGDIR}/lat_32.out -d $dev >> ${LOGDIR}/result_4k.out
	sudo $KVPERF -c $CFG -p -r -v 4000 -n 5000000 -T 64 -l ${LOGDIR}/lat_64.out -d $dev >> ${LOGDIR}/result_4k.out
	sudo $KVPERF -c $CFG -p -r -v 4000 -n 5000000 -T 128 -l ${LOGDIR}/lat_128.out -d $dev >> ${LOGDIR}/result_4k.out
	sudo $KVPERF -c $CFG -p -r -v 4000 -n 5000000 -T 256 -l ${LOGDIR}/lat_256.out -d $dev >> ${LOGDIR}/result_4k.out
	sudo $KVPERF -c $CFG -p -r -v 4000 -n 5000000 -T 512 -l ${LOGDIR}/lat_512.out -d $dev >> ${LOGDIR}/result_4k.out

	./log.sh stop $LOGDIR
}

sighandler() {
	./log.sh stop $LOGDIR
	exit -1
}

main() {
	trap sighandler SIGINT SIGTERM
	rm -rf $LOGDIR
	mkdir -p $LOGDIR
	if [ $1 -eq 1 ]; then
		dev=$DEVICE1
	elif [ $1 -eq 2 ]; then
		dev=$DEVICE2
	elif [ $1 -eq 4 ]; then
		dev=$DEVICE4
	else
		echo "args should be {1|2|4}"
		exit -1;
	fi
	run $dev
}

main $1
