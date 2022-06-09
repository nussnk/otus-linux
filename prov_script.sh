#!/bin/bash
echo "=========== mkdir -p ~root/.ssh"
mkdir -p ~root/.ssh
echo "=========== cp ~vagrant/.ssh/auth* ~root/.ssh"
cp ~vagrant/.ssh/auth* ~root/.ssh
echo "=========== sudo yum install -y mdadm smartmontools hdparm gdisk"
sudo yum install -y mdadm smartmontools hdparm gdisk
echo "=========== sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}"
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
echo "=========== sudo mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}"
sudo mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
echo "=========== sudo mdadm /dev/md0 --add-spare /dev/sdf"
sudo mdadm /dev/md0 --add-spare /dev/sdf
echo "=========== sudo mkdir /etc/mdadm"
sudo mkdir /etc/mdadm
echo "=========== echo 'DEVICE partitions' | sudo tee -a /etc/mdadm/mdadm.conf"
echo "DEVICE partitions" | sudo tee -a /etc/mdadm/mdadm.conf
echo "=========== sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf" 
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf 
