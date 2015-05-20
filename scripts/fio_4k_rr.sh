#!/bin/bash
#
# Copyright (C) 2013-2015, Levyx, Inc.
#

#
# Note that for high thread count, --norandommap option
# should be used. For Helium GCP tests, this scrip twas
# run with numjobs {16, 32, 64, 128, 256, and 512}.
#
# A stripe'd raid /dev/md0 was created out of /dev/nvme0n{1..4}
# 
sudo fio --time_based --name=benchmark --size=20G --runtime=30 \
     --filename=/dev/md0 --ioengine=psync --randrepeat=0 \
     --direct=1 --invalidate=1 --verify=0 --verify_fatal=0 \
     --numjobs=16 --threads=1 --rw=randread --blocksize=4k --group_reporting
