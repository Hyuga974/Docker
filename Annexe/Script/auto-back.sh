#!/bin/bash
# A simple script to set automatically your backup
# Tamashi ~ 11/11/21

    here=$(pwd)
    woHome=${here##/home/}
    User=${woHome%/*}

    echo -e "Hello ${User} ! I'm gonna do my job\n"
    sleep 2

    echo "1/6 => Adding server to your hosts ..."
    {
        echo "10.103.0.2	server	serve	server.tp3.linux" >> /etc/hostname

    } &> /dev/null
    echo "2/6 => Update ..."
    {
        dnf update -y
    } &> /dev/null
    echo "3/6 => NFS installing ..."
    {
        dnf install -y nfs-utils
    } &> /dev/null
    echo "4/6 => Directorie creating and sharing ..."
    {            
        mkdir /srv/backup
        echo "/srv/backup server(rw,no_root_squash)">/etc/exports
    } &> /dev/null
    echo "5/6 => NFS Starting ..."
    {
        systemctl start nfs-server 
        systemctl enable nfs-server
    } &> /dev/null
    echo "6/6 => Setup the firewall ..."
    {
        firewall-cmd --add-service=nfs --permanent

        firewall-cmd --set-default-zone=drop
        firewall-cmd --zone=drop --add-interface=enp0s8 --permanent
        firewall-cmd --new-zone=ssh --permanent

        firewall-cmd --zone=ssh --add-source=10.103.0.1/32 --permanent
        firewall-cmd --zone=ssh --add-port=22/tcp --permanent
        firewall-cmd --new-zone=nfs --permanent

        firewall-cmd --zone=nfs --add-source=10.103.0.2/32 --permanent
        firewall-cmd --zone=nfs --add-port=19999/tcp --permanent
        firewall-cmd --zone=nfs --add-service=nfs --permanent

        firewall-cmd --reload
    } &> /dev/null
    
    echo -e "All is good, you can use this \n"