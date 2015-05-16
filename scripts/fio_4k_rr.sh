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
# mdadm --create --verbose /dev/md0 --level=stripe --raid-devices=4
# /dev/nvme0n1 /dev/nvme0n2 /dev/nvme0n3 /dev/nvme0n4
#
sudo fio --time_based --name=benchmark --size=20G --runtime=30 \
     --filename=/dev/md0 --ioengine=psync --randrepeat=0 \
     --direct=1 --invalidate=1 --verify=0 --verify_fatal=0 \
     --numjobs=16 --threads=1 --rw=randread --blocksize=4k --group_reporting \
     --output=logs_4k_5M/fio_16.out

sudo fio --time_based --name=benchmark --size=20G --runtime=30 \
     --filename=/dev/md0 --ioengine=psync --randrepeat=0 \
     --direct=1 --invalidate=1 --verify=0 --verify_fatal=0 \
     --numjobs=32 --threads=1 --rw=randread --blocksize=4k --group_reporting \
     --output=logs_4k_5M/fio_32.out

sudo fio --time_based --name=benchmark --size=20G --runtime=30 \
     --filename=/dev/md0 --ioengine=psync --randrepeat=0 \
     --direct=1 --invalidate=1 --verify=0 --verify_fatal=0 \
     --numjobs=64 --threads=1 --rw=randread --blocksize=4k --group_reporting \
     --output=logs_4k_5M/fio_64.out

sudo fio --time_based --name=benchmark --size=20G --runtime=30 \
     --filename=/dev/md0 --ioengine=psync --randrepeat=0 \
     --direct=1 --invalidate=1 --verify=0 --verify_fatal=0 \
     --numjobs=128 --threads=1 --rw=randread --blocksize=4k --group_reporting \
     --output=logs_4k_5M/fio_128.out

sudo fio --time_based --name=benchmark --size=20G --runtime=30 \
     --filename=/dev/md0 --ioengine=psync --randrepeat=0 \
     --direct=1 --invalidate=1 --verify=0 --verify_fatal=0 \
     --numjobs=256 --threads=1 --rw=randread --blocksize=4k --group_reporting \
     --output=logs_4k_5M/fio_256.out

sudo fio --time_based --name=benchmark --size=20G --runtime=30 \
     --filename=/dev/md0 --ioengine=psync --randrepeat=0 \
     --direct=1 --invalidate=1 --verify=0 --verify_fatal=0 \
     --numjobs=512 --threads=1 --rw=randread --blocksize=4k --group_reporting \
     --output=logs_4k_5M/fio_512.out

