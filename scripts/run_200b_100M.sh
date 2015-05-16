#!/bin/bash
#
# Copyright (C) 2013-2015, Levyx, Inc.
#

DEVICE=he://.//dev/nvme0n1,/dev/nvme0n2,/dev/nvme0n3,/dev/nvme0n4
OPS=100000000
THREADS=32
VALSIZE=200
RUNS=2
KVPERF=../kvperf/kvperf
CFG=../kvperf/cfg_200b_100M

LOGDIR=logs_200b_100M

run_perf() {
	./log.sh start $LOGDIR
	$KVPERF -c $CFG -l ${LOGDIR}/latency_run_${1}.out -t $THREADS -v $VALSIZE -n $OPS -d $DEVICE > ${LOGDIR}/result_run_${1}.out
	if [ $? -ne 0 ]; then
		./log.sh stop $LOGDIR
		echo "Error: run $1 failed\n"
		exit -1
	fi
	./log.sh stop $LOGDIR
}

print_row() {
	I=`cat $2 | awk '{ sum+=$2; n++} END { if (NR>0) printf("%4.2f\n",sum/NR) }'`
	S=`cat $2 | awk '{ sum+=$3; n++} END { if (NR>0) printf("%4.2f\n",sum/NR) }'`
	R=`cat $2 | awk '{ sum+=$4; n++} END { if (NR>0) printf("%4.2f\n",sum/NR) }'`
	D=`cat $2 | awk '{ sum+=$5; n++} END { if (NR>0) printf("%4.2f\n",sum/NR) }'`
	M=`cat $2 | awk '{ sum+=$6; n++} END { if (NR>0) printf("%4.2f\n",sum/NR) }'`

        #echo "Threads    Inserts    SeqReads    RandReads    Deletes    MaxRdLatency"
	echo " $1        $I         $S          $R           $D         $M"
}

# Assumes that the output (line numbers) of kvperf is in a specific format!
average() {
	for i in `seq 1 $RUNS`
	do
		awk 'FNR==11' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t1
		awk 'FNR==12' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t2
		awk 'FNR==13' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t4
		awk 'FNR==14' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t8
		awk 'FNR==14' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t12
		awk 'FNR==15' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t16
		awk 'FNR==16' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t20
		awk 'FNR==17' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t24
		awk 'FNR==18' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t28
		awk 'FNR==19' ${LOGDIR}/result_run_${i}.out >> ${LOGDIR}/t32
	done

	echo "Threads    Inserts    SeqReads    RandReads    Deletes    MaxRdLatency"
	print_row 1 ${LOGDIR}/t1
	print_row 2 ${LOGDIR}/t2
	print_row 4 ${LOGDIR}/t4
	print_row 8 ${LOGDIR}/t8
	print_row 12 ${LOGDIR}/t12
	print_row 16 ${LOGDIR}/t16
	print_row 20 ${LOGDIR}/t20
	print_row 24 ${LOGDIR}/t24
	print_row 28 ${LOGDIR}/t28
	print_row 32 ${LOGDIR}/t32

	rm -rf ${LOGDIR}/t*
}

sighandler() {
	./log.sh stop $LOGDIR
	exit -1
}

main() {
	rm -rf $LOGDIR
	mkdir -p $LOGDIR
	trap sighandler SIGINT SIGTERM
	for i in `seq 1 $RUNS`
	do
		run_perf $i
	done

	average
}

main
