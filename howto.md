## Gist describing steps for Helium benchmarking on GCP

####0. Set the project properties and authentication
```
gcloud config set project your-project-name
gcloud config set compute/zone us-central1-c
```

####1. Create a Debian based instance that has 4 local SSDs. 
There are two ways to create this instance -- (i) Create from an existing snapshot -or- (ii) Create from scratch.

* 1a. Create from snapshot:
```
gcloud alpha compute --project "your-proj-name" disks create "gcp-demo" --zone "us-central1-c" --source-snapshot "snap-he-gcp-demo-4" --type "pd-standard"

gcloud compute --project "your-project-name" instances create "gcp-demo" --zone "us-central1-c" --machine-type "n1-highcpu-32" --network "default" --maintenance-policy "MIGRATE" --scopes "https://www.googleapis.com/auth/devstorage.read_only" "https://www.googleapis.com/auth/logging.write" --disk "name=gcp-demo" "device-name=gcp-demo" "mode=rw" "boot=yes" "auto-delete=yes" --local-ssd interface="NVME" --local-ssd interface="NVME" --local-ssd interface="NVME" --local-ssd interface="NVME"
```

* 1b. Create from scratch
```
gcloud compute --project "your-project-name" instances create "gcp-demo" --zone "us-central1-c" --machine-type "n1-highcpu-32" --network "default" --maintenance-policy "MIGRATE" --scopes "https://www.googleapis.com/auth/devstorage.read_only" "https://www.googleapis.com/auth/logging.write" --local-ssd interface="NVME" --local-ssd interface="NVME" --local-ssd interface="NVME" --local-ssd interface="NVME" --image "https://www.googleapis.com/compute/v1/projects/gce-nvme/global/images/nvme-backports-debian-7-wheezy-v20141108" --boot-disk-type "pd-standard" --boot-disk-device-name "gcp-demo"
```

####2. Add ssh keys to the VM instance
From the developer's console -> SSH Keys -> Copy paste the `~/.ssh/public_key_for_gcp.pub`


####3. If created using 1a., skip this step
* 3a. Install Helium. Contact Levyx (info@levyx.com) for an evaluation copy
    of the Helium library.

```
gcloud compute copy-files install-helium-linux-2.8.1.sh username@gcp-demo:
gcloud compute copy-files uninstall-helium-linux-2.8.1.sh username@gcp-demo:
```

* 3b. Update the packages
```
gcloud compute ssh username@gcp-demo --command "sudo apt-get update"
gcloud compute ssh username@gcp-demo --command "sudo apt-get -y install build-essential"
gcloud compute ssh username@gcp-demo --command "sudo apt-get -y install sysstat"
gcloud compute ssh username@gcp-demo --command "sudo apt-get -y install git"
```

####4. Install Helium library
```
gcloud compute ssh username@gcp-demo --command "chmod +x install-helium-linux-2.8.1.sh"
gcloud compute ssh username@gcp-demo --command "sudo ./install-helium-linux-2.8.1.sh"
```

####5. Get the wrapper scripts and test program
```
gcloud compute ssh username@gcp-demo --command "git clone https://github.com/levyx/HeliumGCP"
gcloud compute ssh username@gcp-demo --command "(cd HeliumGCP/kvperf; make)"
```

####6. Sanity checks
```
gcloud compute ssh username@gcp-demo --command "helium --version"
gcloud compute ssh username@gcp-demo --command "(cd HeliumGCP/kvperf; ./kvperf)"
```
[Optional] Before running tests, make sure that the SSDs are trimm'ed and
the irqs from the SSDs are distributed evenly on all processors. Both
of these can be done by documentation from the Google Local SSD page.

https://cloud.google.com/compute/docs/disks/local-ssd

The blkdiscard command is used for trimming the drive and set-interrupts.sh
is used to distribute the irqs. Note that as per GCP documentation these
are already done by GCP when instantiating local SSDs. Therefore, this
step is optional.


####7. Run the actual benchmark program

* 7a. Run the first test (200b keys x 100M operations)
Note that you can choose to redirect the output or change the number
of runs by changing variables of the run script. The script is just a
wrapper to call kvperf program. You can also run kvperf program in
standalone mode. Running this under screen will be useful in case the
ssh disconnects.

```
gcloud compute ssh username@gcp-demo --command "(cd HeliumGCP/scripts; sudo ./run_200b_100M.sh)"
```
This will run the test 3 times and output the average. All the generated
files (stats and program output) are under logs_200b_100M dir. 


* 7b. Run the second test (4K x 5M operations)
For this run, three GCP instances are required with 1, 2, and 4 SSDs. On
each instance, run one of the following command depending on the number of SSDs:

```
gcloud compute ssh username@gcp-demo --command "(cd HeliumGCP/scripts; ./run_4k.sh 1)"
gcloud compute ssh username@gcp-demo --command "(cd HeliumGCP/scripts; ./run_4k.sh 2)"
gcloud compute ssh username@gcp-demo --command "(cd HeliumGCP/scripts; ./run_4k.sh 4)"
```

