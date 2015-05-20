#!/bin/bash
sudo fio --name=writefile --size=375G --filesize=375G \
--filename=/dev/nvme0n1 --bs=1M --nrfiles=1 \
--direct=1 --sync=0 --randrepeat=0 --rw=write --refill_buffers --end_fsync=1 \
--iodepth=200 --ioengine=libaio
