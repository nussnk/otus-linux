# Инструкции

* [Как начать Git](git_quick_start.md)
* [Как начать Vagrant](vagrant_quick_start.md)

## otus-linux

Используйте этот [Vagrantfile](Vagrantfile) - для тестового стенда.

Мои действия 
Добавляем диск 5 в Vagrantfile
меняем ip адрес на 192.168.56.101

запускаем vagrant up
подключаемся vagrant ssh
ставим mdadm
sudo yum install mdadm -y
выведем список дисков
sudo fdisk -l
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
создаем массив
sudo mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e} 
добавим пятый диск как hot spare
sudo mdadm /dev/md0 --add-spare /dev/sdf
Смотрим информацию по массиву
sudo mdadm -D /dev/md0 

======== conf
будет собирать конфиг
sudo mkdir /etc/mdadm
sudo mdadm --detail --scan --verbose
sudo echo "DEVICE partitions" | sudo tee -a /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf

======== ломаем/чиним раид
sudo mdadm /dev/md0 --fail /dev/sdb
cat /proc/mdstat

Personalities : [raid10]                                             
md0 : active raid10 sde[4] sdc[2] sdd[3] sdb[1](F) sda[0]            
      507904 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU] 

видим один диск F - failed
раид в порядке - вступил в работу hot spare disk

выводим из строя еще один дис
sudo mdadm /dev/md0 --fail /dev/sdc           
mdadm: set /dev/sdc faulty in /dev/md0                               
cat /proc/mdstat                              
Personalities : [raid10]                                             
md0 : active raid10 sde[4] sdc[2](F) sdd[3] sdb[1](F) sda[0]         
      507904 blocks super 1.2 512K chunks 2 near-copies [4/3] [UU_U] 
                                                                     
unused devices: <none>                                               
видим два диска (F)ailed), одного диска не хватает UU_U

удаляем диск из раида
sudo mdadm /dev/md0 --remove /dev/sdb
добавляем "замененный" диск
sudo mdadm /dev/md0 --add /dev/sdb

[vagrant@localhost ~]$ cat /proc/mdstat                                                         
Personalities : [raid10]                                                                        
md0 : active raid10 sdb[5] sde[4] sdc[2](F) sdd[3] sda[0]                                       
      507904 blocks super 1.2 512K chunks 2 near-copies [4/3] [UU_U]                            
      [================>....]  recovery = 82.6% (210560/253952) finish=0.0min speed=42112K/sec  
                                                                                                
unused devices: <none>                                                                          
поймали момент ребилда

=========== создаем таблицу и разделы
sudo parted -s /dev/md0 mklabel gpt

sudo parted /dev/md0 mkpart primary ext4 0% 20%                   
sudo parted /dev/md0 mkpart primary ext4 20% 40%                  
sudo parted /dev/md0 mkpart primary ext4 40% 60%                  
sudo parted /dev/md0 mkpart primary ext4 60% 80%                  
sudo parted /dev/md0 mkpart primary ext4 80% 100%                 

for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done          
sudo mkdir -p /raid/part{1,2,3,4,5}                               
for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done 

====================================================================
пробуем сделать все на уровне провиженинга вагрантом
выходим из ВМ
удаляем вм
vagrant destroy

Добавляем в провиженинг выполнение скрипта
создаем скрипт рядом с Vagrantfile с названием prov_scripts.sh
дадим правда на исполнение
chmod +x prov_scripts.sh

добавил 
box.vbguest.installer_options = { allow_kernel_upgrade: true }
в Vagrantfile. Без этого выходила ошибка и до провиженинга дело не доходило

