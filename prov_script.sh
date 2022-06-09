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
echo "=========== parted -s /dev/md0 mklable gpt"
parted -s /dev/md0 mklabel gpt
echo "=========== parted /dev/md0 mkpart primary ext4 0% 20%"
parted /dev/md0 mkpart primary ext4 0% 20%
echo "=========== parted /dev/md0 mkpart primary ext4 20% 40%"
parted /dev/md0 mkpart primary ext4 20% 40%
echo "=========== parted /dev/md0 mkpart primary ext4 40% 60%"
parted /dev/md0 mkpart primary ext4 40% 60%
echo "=========== parted /dev/md0 mkpart primary ext4 60% 80%"
parted /dev/md0 mkpart primary ext4 60% 80%
echo "=========== parted /dev/md0 mkpart primary ext4 80% 100%"
parted /dev/md0 mkpart primary ext4 80% 100%
echo "=========== for i in $(seq 1 5) do; sudo mkfs.ext4 /dev/md0p$i; done"
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
echo "=========== for i in $(seq 1 5) do; sudo mkdir -p /raid/part{1,2,3,4,5}"
for i in $(seq 1 5); do sudo mkdir -p /raid/part{1,2,3,4,5}
echo "=========== for i in $(seq 1 5) do; sudo mount /dev/md0p$i /raid/part$i; done"
for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done

