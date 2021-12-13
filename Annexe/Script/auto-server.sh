#!/bin/bash
# A simple script to set automatically your server
# Tamashi ~ 13/11/21

    here=$(pwd)
    woHome=${here##/home/}
    User=${woHome%/*}

    echo -e "Hello ${User} ! I'm gonna do my job\n"
    sleep 2

    # Setup
    echo -e "Setup in progress \n"
    echo "Add back.tp3.linux to your hosts"
    {
        echo "10.103.0.3	backup	back	back.tp3.linux" >> /etc/hostname
    }&> /dev/null
    echo "1/8 => Update ..."
    {
        dnf update -y
    } &> /dev/null
    echo "2/8 => Unzip Forum ..."
    {
        unzip Forum.zip
    } &> /dev/null
    echo "3/8 => wget install ..."
    {
        dnf install -y wget
    } &> /dev/null
    echo "4/8 => Go configuration ..."
    {
        echo 'export GOROOT=/usr/local/go' | tee -a /etc/profil
        echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /etc/profile
        source /etc/profile
    } &> /dev/null
    echo "5/8 => Sqlite ..."
    {
        dnf install -y /usr/bin/sqlite3
    } &> /dev/null
    echo "6/8 => GCC ..."
    {
        dnf install -y gcc-8.4.1-1.el8.x86_64
    } &> /dev/null
    echo "7/8 => Setup database ..."
    {
        chmod 777 Forum/src/database/
        chmod 666 Forum/src/database/database.db
        chown ${User} Forum/src/database/database.db
    } &> /dev/null
    echo "8/8 => Firewall ..."
    {
        firewall-cmd --add-port=4444/tcp --permanent
        firewall-cmd --reload
    } &> /dev/null
    echo -e "Basic setup is end \n"

    # Docker
    echo -e "Setup for Docker is starting...\n"
    echo "1/4 => Move app_forum2 and rename it to DockerFile to use it ..."
    {
        mv /home/${User}/Script/app_forum2 /home/${User}/
        mv /home/${User}/app_forum2 Dockerfile
    } &> /dev/null
    echo "2/4 => Docker install ..."
    {
        dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
        dnf install -y docker-ce docker-ce-cli containerd.io
    } &> /dev/null
    echo "3/4 => Docker start & enable ..."
    {
        systemctl enable docker
        systemctl start docker
    } &> /dev/null
    echo "4/4 => Build image forum ..."
    {
        docker image build . -t app_forum
    } &> /dev/null
    echo -e "Docker OK! \n"

    # Backup
    echo -e "Setup for the backup is starting... \n"
    echo "1/4 => Install and Start nfs ...!"
    {
        dnf install -y nfs-utils
        systemctl enable --now rpcbind nfs-server
    } &> /dev/null
    echo "2/4 => Firewall ...!"
    {
        firewall-cmd --permanent --add-service=nfs
        firewall-cmd --reload
    } &> /dev/null
    echo "3/4 => Directorie create & Partition created and monted ...!"
    {
        mkdir /srv/backup
        mount -t nfs back:/srv/backup /srv/backup
        echo "back:/srv/backup        /srv/backup             nfs     defaults        0 0" >> /etc/fstab
    } &> /dev/null
    echo "4/4 => Move backup.sh/service/timer ...!"
    {
        mv /home/${User}/Script/backup.sh /srv/backup/
        mv /home/${User}/Script/backup.service /etc/systemd/system/backup.service
        mv /home/${User}/Script/backup.timer /etc/systemd/system/backup.timer
    } &> /dev/null

    echo -e "Backup server side OK!  \n"

    # Run backup.timer?
    echo -e "Do you want to run the timer backup now? You can run it later manually" 
    echo "Yes/No: "
    read -r Answer
    while [[ "${Answer}" != "Yes" &&  "${Answer}" != "yes" &&  "${Answer}" != "No" &&  "${Answer}" != "no" ]] 
        do
            echo -e "I don't understand what you want ^^'\n"
            echo "Yes/No:"
            read -r Answer
        done
    if [[ "${Answer}" == "Yes" ]] || [[ "${Answer}" == "yes" ]] 
    then
        systemctl daemon-reload
        systemctl start backup.timer
        systemctl enable backup.timer
    elif [[ "${Answer}" == "No" ]] || [[ "${Answer}" == "no" ]]; 
    then
        systemctl daemon-reload
        echo "You can use this for run it:"
        echo "systemctl enable --now backup.timer"
    fi    

    # Run the container?
    echo -e "\nDo you want to run the server (the container Docker) now? You can run it later manually" 
    echo "Yes/No:"
    read -r Answer
    while [[ "${Answer}" != "Yes" && "${Answer}" != "yes" && "${Answer}" != "No" && "${Answer}" != "no" ]] 
        do
            echo "I don't understand what you want ^^'"
            echo "Yes/No:"
            read -r Answer
        done
    if [[ "${Answer}" == "Yes" ]] || [[ "${Answer}" == "yes" ]]
    then
         sudo docker run -p 4444:4444 -v /home/${User}/Forum/:/share -it app_forum bash
    elif [[ "${Answer}" == "No" ]] || [[ "${Answer}" == "no" ]]
    then
        echo -e "You can use this for run it:\n"
        echo "docker run -p 4444:4444 -v /home/$User/Forum/:/share -it app_forum bash"
    fi