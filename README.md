# HeliumGCP
The howto.md file describes the high level steps used
to run Helium on GCP.

The dirs are as follows:

scripts:
```
log.sh                  Script to log iostat, vmstat, and top
precondition.sh		Script to precondition a new SSD
run_200b_100M.sh	Script to run 200b x 100M and dump numbers
run_4k_5M.sh		Script to run 4K SSD scaling perf
fio_4k_rr.sh		fio script (psync, 4k, rand) to compare
                        with run_4k_5M.sh
```

