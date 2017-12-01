#!/bin/bash

# $1 = Azure storage account name
# $2 = Azure storage account key1
# $3 = Azure storage account key2
# $4 = Azure storage account key3
# $5 = Azure file share name
# $6 = mountpoint path
# $7 - username

# update package lists
apt-get -y update

# install cifs-utils and mount file share
apt-get install cifs-utils
mkdir -p $6/share1
mount -t cifs //$1.file.core.windows.net/$5\1 $6/share1 -o vers=3.0,username=$1,password=$2,dir_mode=0755,file_mode=0664

mkdir -p $6/share2
mount -t cifs //$1.file.core.windows.net/$5\2 $6/share2 -o vers=3.0,username=$1,password=$3,dir_mode=0755,file_mode=0664

mkdir -p $6/share3
mount -t cifs //$1.file.core.windows.net/$5\3 $6/share3 -o vers=3.0,username=$1,password=$4,dir_mode=0755,file_mode=0664

