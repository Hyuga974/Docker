# TP3 : Messagerie (with Docker)

# Sommaire
- [TP3 : Messagerie (with Docker)](#tp3--messagerie-with-docker)
- [Sommaire](#sommaire)
- [I. Setup](#i-setup)
  - [1. Prérequis](#1-prérequis)
  - [2. Machine Server](#2-machine-server)
- [II. Server Forum](#ii-server-forum)
  - [1. Récupérations du dossier Forum](#1-récupérations-du-dossier-forum)
  - [2. Mise en place du Golang](#2-mise-en-place-du-golang)
  - [3. Différents réglages](#3-différents-réglages)
    - [A. Installation](#a-installation)
    - [B. Paramètrage](#b-paramètrage)
  - [4. Lancement du Forum en manuel](#4-lancement-du-forum-en-manuel)
- [III. Client](#iii-client)
  - [1. Interface Graphique](#1-interface-graphique)
  - [2. Accès au forum](#2-accès-au-forum)
- [IV. Docker](#iv-docker)
  - [1. Installer Docker sur le `server.tp3.linux`:](#1-installer-docker-sur-le-servertp3linux)
  - [2. Rédaction du fichier DockerFile](#2-rédaction-du-fichier-dockerfile)
  - [3. Verifier le bon fonctionnement du site depuis le container](#3-verifier-le-bon-fonctionnement-du-site-depuis-le-container)
  - [4. Rendre le lancement du Forum automatique](#4-rendre-le-lancement-du-forum-automatique)
  - [5. Enregistrer ce que l'on fait dans le container.](#5-enregistrer-ce-que-lon-fait-dans-le-container)
- [V. Backup](#v-backup)
  - [1. Création de la VM](#1-création-de-la-vm)
  - [2. Mise en place du service NFS sur `back.tp3.linux`](#2-mise-en-place-du-service-nfs-sur-backtp3linux)
  - [3. Mise en place du service NFS sur `server.tp3.linux`](#3-mise-en-place-du-service-nfs-sur-servertp3linux)
  - [4. Setup du point de montage sur `server.tp3.linux`](#4-setup-du-point-de-montage-sur-servertp3linux)
  - [5. Récupération automatisé des données du Forum](#5-récupération-automatisé-des-données-du-forum)
    - [A. Création d'un script en bash](#a-création-dun-script-en-bash)
    - [B. Mise en place de l'unité de service](#b-mise-en-place-de-lunité-de-service)
    - [C. Concret](#c-concret)
  - [6. Restrictions du firewall](#6-restrictions-du-firewall)
- [VI. Automatisation](#vi-automatisation)
  - [1. Server](#1-server)
  - [2. Backup](#2-backup)

# I. Setup

## 1. Prérequis

- Récupérer le zip [Forum](Annexe/Forum.zip)
- Avoir 2 VM sous rocky-linux
    - Elles doivent avoir les configurations suivantes:
        - 2000 Mo de mémoire vive (au minimum)
        - 128 Mo de mémoire vidéo (lors de l'installation au moins)
        - Carte NAT
        - Carte Host-Only commune
    - Elles doivent se connaître via /etc/hosts
        - Elles peuvent se ping via leur nom
    - Elles doivent suivre le tableau d'adressage ci-dessous
    - On doit se connecter en ssh desssus


| Machine            | IP            | NAT   | Service                 | 
|--------------------|---------------|-------|-------------------------|
| `server.tp3.linux` | `10.103.0.2`  | Oui   | Serveur Docker          |
| `client.tp3.linux` | `10.103.0.150`  | Oui   |                         |

  
## 2. Machine Server 


- Récupérer le zip Forum sur cette machine (`server.tp3.linux`) grâce à la commande `scp` depuis votre hôte:
    
  ```
  scp path/Forum.zip user@10.103.0.2:/home/user/Forum.zip
  ```

Avec *path* comme chemin vers le Forum.zip que vous avez téléchargé. Et *user* que vous remplacerez par votre username.

```
PS C:\Users\reype> scp C:\Users\reype\Documents\YNOV\Workstation-GitLab\b2_workstation\Linux\TP3\Annexe\Forum.zip tamashi@10.103.0.2:/home/tamashi/
tamashi@10.103.0.2's password:
Forum.zip                                                                                          100% 8899KB  31.9MB/s   00:00
```

# II. Server Forum 

## 1. Récupérations du dossier Forum

- Unzip le dossier Forum sur la machine `server.tp3.linux`:
  ```
  [tamashi@server ~]$ ls
  Forum.zip
  [tamashi@server ~]$ sudo unzip Forum.zip
  Archive:  Forum.zip
    inflating: Forum/go.mod
    inflating: Forum/go.sum
    creating: Forum/src/
    creating: Forum/src/assets/
    inflating: Forum/src/assets/404.css
    creating: Forum/src/assets/images/
    inflating: Forum/src/assets/images/part1.png
    inflating: Forum/src/assets/images/part2.png
    inflating: Forum/src/assets/images/part3.png
    inflating: Forum/src/assets/main.js
    creating: Forum/src/assets/posts/
    inflating: Forum/src/assets/posts/banniere.png
    inflating: Forum/src/assets/posts/giphy.gif
    inflating: Forum/src/assets/posts/Hanami.jpg
    inflating: Forum/src/assets/posts/kaded.png
    creating: Forum/src/assets/profiles/
    inflating: Forum/src/assets/profiles/1883A4C1-9182-4B76-8F95-C5C770D74901-fi14369250x1000.jpeg
    inflating: Forum/src/assets/profiles/2d035609483aad6a14b4b7a45223b32e.jpg
    inflating: Forum/src/assets/profiles/719169231941533696.gif
    inflating: Forum/src/assets/profiles/a_a6bcee1033c31878688ff315ffd314c9.gif
    inflating: Forum/src/assets/profiles/Bang.gif
    inflating: Forum/src/assets/profiles/banniere.png
    inflating: Forum/src/assets/profiles/floflo.png
    inflating: Forum/src/assets/profiles/HOLY_FUCK.png
    inflating: Forum/src/assets/profiles/Jin-Mori.png
    inflating: Forum/src/assets/profiles/kaded.png
    inflating: Forum/src/assets/profiles/Lack_reward_2021_AVRIL.png
    inflating: Forum/src/assets/profiles/Livaille.png
    inflating: Forum/src/assets/profiles/lmt_banner_2.png
    inflating: Forum/src/assets/profiles/Screenshot_20180519-231719~2.png
    inflating: Forum/src/assets/profiles/Screenshot_20180519-233224~2.png
    inflating: Forum/src/assets/profiles/Screenshot_20180616-225259~2.png
    inflating: Forum/src/assets/stylesheet.css
    creating: Forum/src/content/
    inflating: Forum/src/content/Admin.go
    inflating: Forum/src/content/Cookie.go
    inflating: Forum/src/content/Get.go
    inflating: Forum/src/content/getPays.go
    inflating: Forum/src/content/Home.go
    inflating: Forum/src/content/Login.go
    inflating: Forum/src/content/Other.go
    inflating: Forum/src/content/Post.go
    inflating: Forum/src/content/PostCreate.go
    inflating: Forum/src/content/PostOther.go
    inflating: Forum/src/content/Posts.go
    inflating: Forum/src/content/Profil.go
    inflating: Forum/src/content/Register.go
    inflating: Forum/src/content/structure.go
    creating: Forum/src/database/
    inflating: Forum/src/database/database.db
    inflating: Forum/src/server.go
    creating: Forum/src/template/
    inflating: Forum/src/template/404.html
    inflating: Forum/src/template/Common.html
    inflating: Forum/src/template/Connexion.html
    inflating: Forum/src/template/CreatePost.html
    inflating: Forum/src/template/EditPost.html
    inflating: Forum/src/template/Home.html
    inflating: Forum/src/template/ModerationPosts.html
    inflating: Forum/src/template/ModerationUsers.html
    inflating: Forum/src/template/Post.html
    inflating: Forum/src/template/Posts.html
    inflating: Forum/src/template/Profil.html
    inflating: Forum/src/template/profile2.html
    inflating: Forum/src/template/Register.html
    inflating: Forum/src/template/test.html
  [tamashi@server ~]$
  ```

## 2. Mise en place du Golang

- Installer GoLang sur Linux:
  ```
  [tamashi@server Forum]$ sudo dnf install -y wget
  Last metadata expiration check: 1:33:20 ago on Tue 02 Nov 2021 09:36:50 PM CET.
  Dependencies resolved.
  =====================================================================================================================================
  Package                    Architecture                 Version                               Repository                       Size
  =====================================================================================================================================
  Installing:
  wget                       x86_64                       1.19.5-10.el8                         appstream                       733 k

  Transaction Summary
  =====================================================================================================================================
  Install  1 Package

  Total download size: 733 k
  Installed size: 2.8 M
  Downloading Packages:
  wget-1.19.5-10.el8.x86_64.rpm                                                                        470 kB/s | 733 kB     00:01
  -------------------------------------------------------------------------------------------------------------------------------------
  Total                                                                                                406 kB/s | 733 kB     00:01
  Running transaction check
  Transaction check succeeded.
  Running transaction test
  Transaction test succeeded.
  Running transaction
    Preparing        :                                                                                                             1/1
    Installing       : wget-1.19.5-10.el8.x86_64                                                                                   1/1
    Running scriptlet: wget-1.19.5-10.el8.x86_64                                                                                   1/1
    Verifying        : wget-1.19.5-10.el8.x86_64                                                                                   1/1

  Installed:
    wget-1.19.5-10.el8.x86_64

  Complete!
  [tamashi@se[tamashi@server Forum]$ sudo wget hhtps://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
  hhtps://dl.google.com/go/go1.13.1.linux-amd64.tar.gz: Unsupported scheme ‘hhtps’.
  [tamashi@server Forum]$ sudo wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
  --2021-11-02 23:11:04--  https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
  Resolving dl.google.com (dl.google.com)... 142.250.201.14, 2a00:1450:4006:80e::200e
  Connecting to dl.google.com (dl.google.com)|142.250.201.14|:443... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: 120040373 (114M) [application/octet-stream]
  Saving to: ‘go1.13.1.linux-amd64.tar.gz’

  go1.13.1.linux-amd64.tar.gz       100%[==========================================================>] 114.48M  2.98MB/s    in 37s

  2021-11-02 23:11:41 (3.13 MB/s) - ‘go1.13.1.linux-amd64.tar.gz’ saved [120040373/120040373]
  [tamashi@server ~]$ sudo tar -zxvf go1.13.1.linux-amd64.tar.gz -C /usr/local
  ```

- Mettre en place du golang:
  ```
  [tamashi@server Forum]$ sudo su -
  [root@server ~]# echo 'export GOROOT=/usr/local/go' | tee -a /etc/profile
  export GOROOT=/usr/local/go
  [root@server ~]# echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /etc/profile
  export PATH=$PATH:/usr/local/go/bin
  [root@server ~]# exit
  logout
  [tamashi@server Forum]$ source /etc/profile
  ```

- Tester l'utilisation du Golang: 
  ```
  [tamashi@server Forum]$ sudo nano helloWorl.go
  [tamashi@server Forum]$ sudo cat helloWorl.go
  package main
  import "fmt"
  func main() {
      fmt.Printf("Hello World, I'm Costa.\n")
  }
  [tamashi@server Forum]$ go run helloWorl.go
  Hello World, I'm Costa.
  ```

## 3. Différents réglages

Voici différents réglages à effectuer afin de pouvoir lancer et utiliser correctement le Forum:

### A. Installation

- Installer sqlite3 sur la vm serverafin de pouvoir interargir avec notre base données (ou en tout cas vérifier sa présence):
  ```
  [tamashi@server src]$ sudo dnf install -y /usr/bin/sqlite3
  Last metadata expiration check: 0:03:34 ago on Wed 03 Nov 2021 03:56:56 PM CET.
  Package sqlite-3.26.0-13.el8.x86_64 is already installed.
  Dependencies resolved.
  Nothing to do.
  Complete!
  ```
- Installer `gcc` afin de pouvoir lancer notre forum:
  ```
  [tamashi@server src]$ sudo dnf install -y gcc-8.4.1-1.el8.x86_64
  Last metadata expiration check: 2:18:21 ago on Tue 02 Nov 2021 09:36:50 PM CET.
  [...]
  Complete!
  ```

### B. Paramètrage

- Donner les droits d'écriture et de lecture au dossier database et au fichier database.db
  ```
  [tamashi@server src]$ sudo chmod 777 database/
  [tamashi@server src]$ ls -l
  total 8
  drwxr-xr-x. 5 root    root  101 May  3  2021 assets
  drwxr-xr-x. 2 root    root  246 Oct 28 15:01 content
  drwxrwxrwx. 2 root    root   25 Nov  3 15:59 database
  -rw-r--r--. 1 tamashi root  832 Oct 28 12:30 server.go
  drwxr-xr-x. 2 root    root 4096 May  3  2021 template
  [tamashi@server src]$ cd database/
  [tamashi@server database]$ ls -all
  total 44
  drwxr-xr-x. 2 root root    25 May  3  2021 .
  drwxr-xr-x. 6 root root    84 May  3  2021 ..
  -rw-r--r--. 1 root root 45056 May  3  2021 database.db
  [tamashi@server database]$ sudo chmod 666 database.db
  [tamashi@server database]$ ls -all
  total 44
  drwxr-xr-x. 2 root root    25 May  3  2021 .
  drwxr-xr-x. 6 root root    84 May  3  2021 ..
  -rw-rw-rw-. 1 root root 45056 May  3  2021 database.db
  ```

- Changer le propriétaire de database.db par le nom de votre utilisateur:
  ```
  [tamashi@server database]$ sudo chown tamashi database.db
  ```

## 4. Lancement du Forum en manuel

- Ouvrir le port 4444:
  ```
  [tamashi@server src]$ sudo firewall-cmd --add-port=4444/tcp --permanent
  success
  [tamashi@server src]$ sudo firewall-cmd --reload
  success
  [tamashi@server src]$ sudo firewall-cmd --list-all
  public (active)
    target: default
    icmp-block-inversion: no
    interfaces: enp0s3 enp0s8
    sources:
    services: cockpit dhcpv6-client ssh
    ports: 4444/tcp
    protocols:
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
  ```

- Tester le lancement du Forum:
  ```
  [tamashi@server src]$ go run server.go
  Starting local server for the website on : localhost:4444

  ```


- Se rendre sur votre navigateur et rentrer dans l'url: `10.103.0.2:4444`. Vous avez désormais accès au site.

> Afin d'arrêter le server il faut arrêter le programme par un Ctrl+C dans le terminal du server.tp3.linux


# III. Client

## 1. Interface Graphique

- Vérifier les paquets disponible sur Rocky Linux
  ```
  [tamashi@client ~]$ sudo dnf group list
  [sudo] password for tamashi:
  Last metadata expiration check: 0:39:08 ago on Wed 03 Nov 2021 04:56:20 PM CET.
  Available Environment Groups:
    Server with GUI
    Minimal Install
    Workstation
    Virtualization Host
    Custom Operating System
  Installed Environment Groups:
    Server
  Installed Groups:
    Headless Management
  Available Groups:
    Container Management
    .NET Core Development
    RPM Development Tools
    Development Tools
    Graphical Administration Tools
    Legacy UNIX Compatibility
    Network Servers
    Scientific Support
    Security Tools
    Smart Card Support
    System Tools
  ```


- Installer GNOME GUI
  ```
  [tamashi@client ~]$ sudo dnf groupinstall -y "Server with GUI"
  Last metadata expiration check: 0:42:10 ago on Wed 03 Nov 2021 04:56:20 PM CET.
  [...]
    yelp-tools-3.28.0-3.el8.noarch
    yelp-xsl-3.28.0-2.el8.noarch
    zenity-3.28.1-1.el8.x86_64

  Complete!
  [tamashi@client ~]$
  ``` 

- Activer GNOME GUI au démarrage:
  ```
  [tamashi@client ~]$ sudo systemctl set-default graphical
  [sudo] password for tamashi:
  Removed /etc/systemd/system/default.target.
  Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/graphical.target.
  [tamashi@client ~]$ reboot
  ```

Puis suivre les étapes tutoriel de GNOME lors du premier démarrage.

## 2. Accès au forum 

- Lancer le Forum depuis le server
- Ouvrir un navigateur sur notre vm `client.tp3.linux` et se connecter sur `server:4444`

- Créer un utilisateur:

| Mail              | Username                | PassWord   | Pays    | 
|-------------------|-------------------------|------------|---------|
| client1@gmail.com | Client1_Linux_TP3       | Client%1%  | France  |

(Ces données ne sont là que pour l'exmple, à vous de choisir vos informations)

- Explorer le site comme bon vous semble

# IV. Docker

## 1. Installer Docker sur le `server.tp3.linux`:

- Ajouter le repo Docker-CE
  ```
  [tamashi@server src]$ sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  [sudo] password for tamashi:
  Adding repo from: https://download.docker.com/linux/centos/docker-ce.repo
  ```

- Installer Docker CE Engine
  ```
  [tamashi@server src]$ sudo dnf install -y docker-ce docker-ce-cli containerd.io
  Docker CE Stable - x86_64                                                                             39 kB/s |  17 kB     00:00
  Last metadata expiration check: 0:00:01 ago on Wed 03 Nov 2021 09:07:25 PM CET.
  [...]
    python3-policycoreutils-2.9-14.el8.noarch                    python3-setools-4.3.0-2.el8.x86_64
    slirp4netns-1.1.8-1.module+el8.4.0+556+40122d08.x86_64

  Complete!
  [tamashi@server src]$
  ```
- Activer le service Docker
  ```
  [tamashi@server src]$ sudo systemctl enable docker
  Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /usr/lib/systemd/system/docker.service.
  [tamashi@server src]$ sudo systemctl start docker
  [tamashi@server src]$ sudo systemctl status docker
  ● docker.service - Docker Application Container Engine
    Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
    Active: active (running) since Wed 2021-11-03 21:12:17 CET; 4s ago
      Docs: https://docs.docker.com
  Main PID: 5066 (dockerd)
      Tasks: 7
    Memory: 29.3M
    CGroup: /system.slice/docker.service
            └─5066 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

  [...]

  [tamashi@server src]$
  ```

## 2. Rédaction du fichier DockerFile

- Télécharger une image de Golang pour Docker:
  ```

  [tamashi@server ~]$ sudo docker image pull golang
  Using default tag: latest
  latest: Pulling from library/golang
  bb7d5a84853b: Pull complete
  f02b617c6a8c: Pull complete
  d32e17419b7e: Pull complete
  c9d2d81226a4: Pull complete
  7bd370e02e50: Pull complete
  9ddd7280c3f5: Pull complete
  776d069e7b04: Pull complete
  Digest: sha256:0f20e08bd0d9cdadf856e857eb101d294c05fa9f01cde757590ba76f2fa762ad
  Status: Downloaded newer image for golang:latest
  docker.io/library/golang:latest
  [tamashi@server ~]$ sudo docker image ls
  REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
  golang       latest    d939cc1fb139   17 hours ago   941MB
  ```

- Ecrire le fichier DockerFile:
  ```
  [tamashi@server ~]$ cat Dockerfile
  FROM ubuntu

  RUN apt-get update -y

  # Instal Golang
  RUN apt-get install -y wget
  RUN wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
  RUN tar -zxvf go1.13.1.linux-amd64.tar.gz -C /usr/local
  # RUN wget -c https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O - | tar -xz -C /usr/local
  # RUN apt-get install -y golang

  # Setting golang
  RUN echo "export GOPATH=\$HOME/go" >> /etc/profile
  RUN echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> /etc/profile
  # RUN source ~/.bash_profile

  # Install sqlite
  RUN apt-get install -y sqlite3

  # Install gcc
  RUN apt-get install -y build-essential


  COPY ./Forum /server

  EXPOSE 4444
  ```
  Ou le récupérer [ici](Annexe/app_forum)


- Monter notre Dockerfile pour en faire une image
  ```
  [tamashi@server ~]$ sudo docker image build . -t app_forum
  Sending build context to Docker daemon  172.3MB
  Step 1/11 : FROM ubuntu
  ---> ba6acccedd29
  Step 2/11 : RUN apt-get update -y
  ---> Using cache
  ---> e132db7c05ee
  Step 3/11 : RUN apt-get install -y wget
  ---> Using cache
  ---> 25788c509589
  Step 4/11 : RUN wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
  ---> Using cache
  ---> ed035ca4b529
  Step 5/11 : RUN tar -zxvf go1.13.1.linux-amd64.tar.gz -C /usr/local
  ---> Using cache
  ---> 538195aef837
  Step 6/11 : RUN echo "export GOPATH=\$HOME/go" >> /etc/profile
  ---> Using cache
  ---> a930ec356f79
  Step 7/11 : RUN echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> /etc/profile
  ---> Using cache
  ---> 256dd8bcdca4
  Step 8/11 : RUN apt-get install -y sqlite3
  ---> Using cache
  ---> f599a248a925
  Step 9/11 : RUN apt-get install -y build-essential
  ---> Using cache
  ---> 738422ee2558
  Step 10/11 : COPY ./Forum /server
  ---> Using cache
  ---> 41bbdbd61741
  Step 11/11 : EXPOSE 4444
  ---> Using cache
  ---> ba9bc3662923
  Successfully built ba9bc3662923
  Successfully tagged app_forum:latest
  ```
*Précision*: je rajouterais que le `-t` nous permet de nommer notre image. Car oui le build va prendre le seul fichier Dockerfile présent à l'endroit où on exécute la commande.


- Tester notre container: 
  ```
  [tamashi@server ~]$ sudo docker run -p 4444:4444 -it app_forum bash
  ```
*Précisions*: 
    - `-p` permet de l'ouvrir sur certain port pour certain port de l'hote (on peut également préciser des adresses IP)
    - `-it` permet de garder la main dans le terminal qu'il nous est donné dans notre container. Ainsi on précise `bash` pour avoir un terminal bash (grâce à `-t`)

- Regardons les fichiers dans notre container:
  ```
  [tamashi@server ~]$ sudo docker run -p 4444:4444 -it app_forum bash
  root@75c328239cda:/# ls
  bin  boot  dev  etc  go1.13.1.linux-amd64.tar.gz  home  lib  lib32  lib64  libx32  media  mnt  opt  proc  root  run  sbin  server  srv  sys  tmp  usr  var
  ```
  On retrouve ici la présence de notre dossier `/server` créé à travers notre Dockerfile.


## 3. Verifier le bon fonctionnement du site depuis le container

Depuis le container
  ```
  root@75c328239cda:/# cd server/src/
  root@60e98439ea93:/server/src# /usr/local/go/bin/go run server.go
  go: downloading github.com/mattn/go-sqlite3 v1.14.6
  go: downloading golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
  go: downloading github.com/satori/go.uuid v1.2.0
  go: extracting github.com/satori/go.uuid v1.2.0
  go: extracting golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
  go: extracting github.com/mattn/go-sqlite3 v1.14.6
  go: finding github.com/satori/go.uuid v1.2.0
  go: finding golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
  go: finding github.com/mattn/go-sqlite3 v1.14.6
  Starting local server for the website on : localhost:4444
  Get Session
  [...]
  ^Csignal: interrupt
  ```

Depuis notre navigateur web, se rendre sur `10.103.0.2:4444` et tadam! On a bien accès au site web.

On peut même essayer de se connecter avec l'utilisateur qu'on a créé plus tôt ([ici](#2-accès-au-forum))

## 4. Rendre le lancement du Forum automatique 

Pour ce faire on reprend le Dockerfile dans lequel on rajoute un ENTRYPOINT qui permet d'exécuter une coommande au lancement:
  ```
  [tamashi@server ~]$ cat Dockerfile
  FROM ubuntu

  RUN apt-get update -y

  # Install Golang
  RUN apt-get install -y wget
  RUN wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
  RUN tar -zxvf go1.13.1.linux-amd64.tar.gz -C /usr/local
  # RUN wget -c https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O - | tar -xz -C /usr/local
  # RUN apt-get install -y golang

  # Setting golang
  RUN echo "export GOPATH=\$HOME/go" >> /etc/profile
  RUN echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> /etc/profile
  # RUN source ~/.bash_profile

  # Install sqlite
  RUN apt-get install -y sqlite3

  # Install gcc
  RUN apt-get install -y build-essential

  COPY ./Forum /server

  # Start server.go at the boot
  ENTRYPOINT cd server/src/ && /usr/local/go/bin/go run server.go

  EXPOSE 4444
  ```

- "re-build" le Dockerfile:
  ```
  [tamashi@server ~]$ sudo docker image build . -t app_forum
  Sending build context to Docker daemon  172.3MB
  Step 1/12 : FROM ubuntu
  ---> ba6acccedd29
  Step 2/12 : RUN apt-get update -y
  ---> Using cache
  ---> e132db7c05ee
  Step 3/12 : RUN apt-get install -y wget
  ---> Using cache
  ---> 25788c509589
  Step 4/12 : RUN wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
  ---> Using cache
  ---> ed035ca4b529
  Step 5/12 : RUN tar -zxvf go1.13.1.linux-amd64.tar.gz -C /usr/local
  ---> Using cache
  ---> 538195aef837
  Step 6/12 : RUN echo "export GOPATH=\$HOME/go" >> /etc/profile
  ---> Using cache
  ---> a930ec356f79
  Step 7/12 : RUN echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> /etc/profile
  ---> Using cache
  ---> 256dd8bcdca4
  Step 8/12 : RUN apt-get install -y sqlite3
  ---> Using cache
  ---> f599a248a925
  Step 9/12 : RUN apt-get install -y build-essential
  ---> Using cache
  ---> 738422ee2558
  Step 10/12 : COPY ./Forum /server
  ---> Using cache
  ---> 41bbdbd61741
  Step 11/12 : ENTRYPOINT cd server/src/ && /usr/local/go/bin/go run server.go
  ---> Running in bf484fa560f2
  Removing intermediate container bf484fa560f2
  ---> 927cecd88e4e
  Step 12/12 : EXPOSE 4444
  ---> Running in b9184f179fc2
  Removing intermediate container b9184f179fc2
  ---> 04d3c9f77d8e
  Successfully built 04d3c9f77d8e
  Successfully tagged app_forum:latest
  ```

- Relancer le container
  ```
  [tamashi@server ~]$ sudo docker run -p 4444:4444 -it app_forum bash
  go: downloading github.com/satori/go.uuid v1.2.0
  go: downloading golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
  go: downloading github.com/mattn/go-sqlite3 v1.14.6
  go: extracting github.com/satori/go.uuid v1.2.0
  go: extracting golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
  go: extracting github.com/mattn/go-sqlite3 v1.14.6
  go: finding github.com/satori/go.uuid v1.2.0
  go: finding golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
  go: finding github.com/mattn/go-sqlite3 v1.14.6
  Starting local server for the website on : localhost:4444
  ^Csignal: interrupt
  [tamashi@server ~]$

  ```
On remarque ici que si on interrompt le processus, le container se ferme totalement. 


## 5. Enregistrer ce que l'on fait dans le container.

Jusqu'à présent, vous pouvez remarquer que si l'on crée un post ou un utilisateur à travers le site lancé par le container, celui-ci n'est plus existant au prochain lancement du container. Cela est parfaitement normale puisque'on modifie la base de donné présente dans notre container et à son arrêt toutes sauvegardes sont perdues. 

Pour éliminer ce problème, nous allons partager un fichier de notre hôte à notre container. 

- Empêcher le lancement automatique :
  ```
  FROM ubuntu

  RUN apt-get update -y

  # Install Golang
  RUN apt-get install -y wget
  RUN wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
  RUN tar -zxvf go1.13.1.linux-amd64.tar.gz -C /usr/local
  # RUN wget -c https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O - | tar -xz -C /usr/local
  # RUN apt-get install -y golang

  # Setting golang
  RUN echo "export GOPATH=\$HOME/go" >> /etc/profile
  RUN echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> /etc/profile
  # RUN source ~/.bash_profile

  # Install sqlite
  RUN apt-get install -y sqlite3

  # Install gcc
  RUN apt-get install -y build-essential

  COPY ./Forum /server

  # Start server.go at the boot
  # ENTRYPOINT cd server/src/ && /usr/local/go/bin/go run server.go

  EXPOSE 4444
  ```

- Construire l'image sous le nom de `app_forum:2.0` :
  ```
  [tamashi@server ~]$ sudo docker image build . -t app_forum:2.0
  Sending build context to Docker daemon  172.3MB
  Step 1/11 : FROM ubuntu
  ---> ba6acccedd29
  Step 2/11 : RUN apt-get update -y
  ---> Using cache
  ---> e132db7c05ee
  Step 3/11 : RUN apt-get install -y wget
  ---> Using cache
  ---> 25788c509589
  Step 4/11 : RUN wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
  ---> Using cache
  ---> ed035ca4b529
  Step 5/11 : RUN tar -zxvf go1.13.1.linux-amd64.tar.gz -C /usr/local
  ---> Using cache
  ---> 538195aef837
  Step 6/11 : RUN echo "export GOPATH=\$HOME/go" >> /etc/profile
  ---> Using cache
  ---> a930ec356f79
  Step 7/11 : RUN echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> /etc/profile
  ---> Using cache
  ---> 256dd8bcdca4
  Step 8/11 : RUN apt-get install -y sqlite3
  ---> Using cache
  ---> f599a248a925
  Step 9/11 : RUN apt-get install -y build-essential
  ---> Using cache
  ---> 738422ee2558
  Step 10/11 : COPY ./Forum /server
  ---> 90e09016a56d
  Step 11/11 : EXPOSE 4444
  ---> Running in 2f290028f838
  Removing intermediate container 2f290028f838
  ---> a95b28dbc061
  Successfully built a95b28dbc061
  Successfully tagged app_forum:2.0
  ```

- Lancer le container avec la commande suivante:
  ```
  [tamashi@server src]$ sudo docker run -p 4444:4444 -v /home/tamashi/Forum:/share -it app_forum:2.0 bash
  root@22bfb4404772:/# ls
  bin  boot  dev  etc  go1.13.1.linux-amd64.tar.gz  home  lib  lib32  lib64  libx32  media  mnt  opt  proc  root  run  sbin  server  share  srv  sys  tmp  usr  var
  root@22bfb4404772:/# cd share/src/
  root@22bfb4404772:/share/src# ls
  assets  content  database  server.go  template
  ```
Le `-v` permet de partager un dosssier/fichier avec le container. Ici on partage le dossier `/home/tamashi/Forum/src` de l'hôte en tant que dossier `/share` dans le container. On observe bien la reprise des dossier dans le share.

- Tester de lancer le server depuis `/share` :
  ```
  root@ff9205b5995e:/# cd share/src/
  root@ff9205b5995e:/share/src# /usr/local/go/bin/go run server.go
  go: downloading github.com/satori/go.uuid v1.2.0
  go: downloading golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
  go: downloading github.com/mattn/go-sqlite3 v1.14.6
  go: extracting github.com/satori/go.uuid v1.2.0
  go: extracting golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
  go: extracting github.com/mattn/go-sqlite3 v1.14.6
  go: finding github.com/satori/go.uuid v1.2.0
  go: finding golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
  go: finding github.com/mattn/go-sqlite3 v1.14.6
  Starting local server for the website on : localhost:4444
  ```
  
  Le site se lance bien et on y a accès comme précedemment.

- Tester le partage de fichier:
    - Depuis l'hote
    ```
    [tamashi@server Forum]$ echo "Test du partage d'un fichier avec le container" > partagefichier.txt
    [tamashi@server Forum]$ ls
    go1.13.1.linux-amd64.tar.gz  go.mod  go.sum  partagefichier.txt  src
    [tamashi@server Forum]$ sudo docker run -p 4444:4444 -v /home/tamashi/Forum:/share -it app_forum:2.0 bash
    root@971d5198e8f0:/# cd share/
    root@971d5198e8f0:/share# ls
    go.mod  go.sum  go1.13.1.linux-amd64.tar.gz  partagefichier.txt  src
    root@971d5198e8f0:/share# cat partagefichier.txt
    Test du partage d'un fichier avec le container
    ```
    - Depuis le container
    ```
    root@971d5198e8f0:/share# echo "Partage depuis le container" >> partagefichier.txt
    root@971d5198e8f0:/share# exit
    exit
    [tamashi@server Forum]$ ls
    go1.13.1.linux-amd64.tar.gz  go.mod  go.sum  partagefichier.txt  src
    [tamashi@server Forum]$ cat partagefichier.txt
    Test du partage d'un fichier avec le container
    Partage depuis le container
    [tamashi@server Forum]$
    ```

- Tester la sauvegarde des changements sur le site lancé depuis le  container:

    -  Créer un post:
        - Se connecter avec notre client1
        - Appuyer sur le "+" et créez votre premier post
  
     - Créer un utilisateur

    | Mail                | Username                | PassWord      | Pays    | 
    |---------------------|-------------------------|---------------|---------|
    | container@gmail.com | Container_Linux_TP3     | Container%2%  | Canada  |

    - Liker/Commenter ... Baladez vous sur le site, maintenant tout est prit en compte. 
  
- Remettre en état le fichier Dockerfile tel que:
    ```
    [tamashi@server ~]$ cat Dockerfile
    FROM ubuntu

    RUN apt-get update -y

    # Install Golang
    RUN apt-get install -y wget
    RUN wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
    RUN tar -zxvf go1.13.1.linux-amd64.tar.gz -C /usr/local
    # RUN wget -c https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O - | tar -xz -C /usr/local
    # RUN apt-get install -y golang

    # Setting golang
    RUN echo "export GOPATH=\$HOME/go" >> /etc/profile
    RUN echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> /etc/profile
    # RUN source ~/.bash_profile

    # Install sqlite
    RUN apt-get install -y sqlite3

    # Install gcc
    RUN apt-get install -y build-essential

    # COPY ./Forum /server

    # Start server.go at the boot
    ENTRYPOINT cd share/src/ && /usr/local/go/bin/go run server.go

    EXPOSE 4444
    ```

📁 **Fichier [Dockerfile app_forum:2.0](Annexe/app_forum2)** 

# V. Backup

Jusqu'ici nous avons réussi à faire une image Docker nous permettant de faire tourner notre site sur un container. De plus les modifications faites sur le site sont enregistrée dans notre `server`. Il nous reste plus qu'a faire une backup de se ces fichiers en cas de "crach" de notre machine serveur.

## 1. Création de la VM

Suivre le tableau d'adressage suivant:
 
| Machine            | IP            | NAT   | Service         | 
|--------------------|---------------|-------|-----------------|
| `back.tp3.linux`   | `10.103.0.3`  | Oui   | Backup          |

## 2. Mise en place du service NFS sur `back.tp3.linux`

- Créer un dossier `srv/backup`
  ```
  [tamashi@back ~]$ sudo mkdir /srv/backup
  [tamashi@back ~]$ ls /srv/
  backup
  ```

- Installer `nfs-utils`
  ```
  [tamashi@back ~]$ sudo dnf install -y nfs-utils
  [...]
  Complete!
  ```

- Configurer `/etc/exports`
  ```
  [tamashi@back ~]$ sudo vim /etc/exports
  [tamashi@back ~]$ sudo cat /etc/exports
  /srv/backup server(rw,no_root_squash)
  ```

- Activer le service maintenant et au boot
  ```
  [tamashi@back ~]$ sudo systemctl start nfs-server.service
  [tamashi@back ~]$ sudo systemctl enable nfs-server.service
  Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
  [tamashi@back ~]$ sudo systemctl status nfs-server.service
  ● nfs-server.service - NFS server and services
    Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
            └─order-with-mounts.conf
    Active: active (exited) since Thu 2021-11-11 11:11:52 CET; 1min 9s ago
  Main PID: 2531 (code=exited, status=0/SUCCESS)
      Tasks: 0 (limit: 11090)
    Memory: 0B
  [...]
  ```

- Autoriser le service dans le firewall:
  ```
  [tamashi@backup ~]$ sudo firewall-cmd --add-service=nfs --permanent
  success
  [tamashi@backup ~]$ sudo firewall-cmd --reload
  success
  [tamashi@backup ~]$ sudo firewall-cmd --list-all
  public (active)
    target: default
    icmp-block-inversion: no
    interfaces: enp0s3 enp0s8
    sources:
    services: cockpit nfs ssh
    ports:
    protocols:
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
  [tamashi@backup ~]$
  ```

## 3. Mise en place du service NFS sur `server.tp3.linux`

- Installer `nfs-utils`:
  ```
  [tamashi@server ~]$ sudo dnf install -y nfs-utils
  Last metadata expiration check: 0:16:02 ago on Thu 11 Nov 2021 11:00:52 AM CET.
  [...]
  Complete!
  ```

- Activer le service maintenant et au boot:
  ```
  [tamashi@server ~]$ sudo systemctl enable --now rpcbind nfs-server
  Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
  [tamashi@server ~]$ sudo systemctl is-enabled nfs-server
  enabled
  [tamashi@server ~]$ sudo systemctl is-active nfs-server
  active
  ```

- Autoriser le service nfs sur le firewall:
  ```
  [tamashi@server ~]$ sudo firewall-cmd --permanent --add-service=nfs
  success
  [tamashi@server ~]$ sudo firewall-cmd --reload
  success
  [tamashi@server ~]$ sudo firewall-cmd --list-all
  public (active)
    target: default
    icmp-block-inversion: no
    interfaces: enp0s3 enp0s8
    sources:
    services: cockpit nfs ssh
    ports: 4444/tcp
    protocols:
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
  ```

## 4. Setup du point de montage sur `server.tp3.linux`

- Créer un dossier de backups
  ```
  [tamashi@server ~]$ sudo /vim /etc/hosts
  [tamashi@server ~]$ ls /srv
  backup
  ```

- Ajouter le point de montage:
  ```
  [tamashi@server ~]$ sudo mount -t nfs back:/srv/backup /srv/backup
  [tamashi@server ~]$ sudo df -h
  Filesystem           Size  Used Avail Use% Mounted on
  devtmpfs             867M     0  867M   0% /dev
  tmpfs                885M     0  885M   0% /dev/shm
  tmpfs                885M  8.6M  877M   1% /run
  tmpfs                885M     0  885M   0% /sys/fs/cgroup
  /dev/mapper/rl-root  6.2G  4.1G  2.2G  65% /
  /dev/sda1           1014M  241M  774M  24% /boot
  tmpfs                177M     0  177M   0% /run/user/1000
  back:/srv/backup     6.2G  2.1G  4.2G  34% /srv/backup
  [tamashi@server ~]$ sudo mount
  sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime,seclabel)
  [...]
  back:/srv/backup on /srv/backup type nfs4 (rw,relatime,vers=4.2,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.103.0.2,local_lock=none,addr=10.103.0.3)
  ```

- Monter la partition automatiquement grâce au fichier `/etc/fstab` (dernière ligne):
  ```
  [tamashi@server ~]$ sudo vim /etc/fstab
  [tamashi@server ~]$ sudo cat /etc/fstab

  #
  # /etc/fstab
  # Created by anaconda on Wed Sep 15 13:25:19 2021
  #
  # Accessible filesystems, by reference, are maintained under '/dev/disk/'.
  # See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
  #
  # After editing this file, run 'systemctl daemon-reload' to update systemd
  # units generated from this file.
  #
  /dev/mapper/rl-root     /                       xfs     defaults        0 0
  UUID=40dc4232-ea1c-4ed0-ae70-0d89d1f845fe /boot                   xfs     defaults        0 0
  /dev/mapper/rl-swap     none                    swap    defaults        0 0
  back:/srv/backup        /srv/backup             nfs     defaults        0 0
  ```

- Tester la lecture de `/etc/fstab`
  ```
    [tamashi@server ~]$ sudo umount /srv/backup
    [tamashi@server ~]$ sudo mount -a -v
    /                        : ignored
    /boot                    : already mounted
    none                     : ignored
    mount.nfs: timeout set for Thu Nov 11 12:22:31 2021
    mount.nfs: trying text-based options 'vers=4.2,addr=10.103.0.3,clientaddr=10.103.0.2'
    /srv/backup              : successfully mounted
  ```

- Tester le partage nfs
  ***server.tp3.linux***
  ```
  [tamashi@server ~]$ sudo chmod 777 /srv/backup/
  [tamashi@server ~]$ ls -l /srv/
  total 0
  drwxrw-rw-. 2 root root 6 Nov 11 10:53 backup
  [tamashi@server ~]$ cd /srv/backup/
  [tamashi@server backup]$ touch Test.txt
  [tamashi@server backup]$ vim Test.txt
  [tamashi@server backup]$ cat Test.txt
  Ceci est un test pour savoir si le partage nfs fonctionne bien
  [tamashi@server backup]$
  ``` 

  ***back.tp3.linux***
  ```
  [tamashi@backup ~]$ cd /srv/backup/
  [tamashi@backup backup]$ ls
  Test.txt
  [tamashi@backup backup]$ cat Test.txt
  Ceci est un test pour savoir si le partage nfs fonctionne bien
  [tamashi@backup backup]$ vim Test.txt
  [tamashi@backup backup]$ cat Test.txt
  Ceci est un test pour savoir si le partage nfs fonctionne bien

  Message bien reçu
  [tamashi@backup backup]$

  ``` 

  ***server.tp3.linux***
  ```
  [tamashi@server backup]$ cat Test.txt
  Ceci est un test pour savoir si le partage nfs fonctionne bien

  Message bien reçu
  [tamashi@server backup]$
  ```

## 5. Récupération automatisé des données du Forum

Maintenant que notre `server.tp3.linux` partage bien un fichier avec notre `back.tp3.linux`, il faut récupérer les informations du Forum et les enregistrer dans la backup que nous venons de créer.

### A. Création d'un script en bash

- Ecrire le script
  ```
  [tamashi@server ~]$ sudo vim /srv/backup.sh
  [tamashi@server ~]$ sudo cat /srv/backup.sh
  #!/bin/bash
  # Simple backup script
  # Tamashi ~ 11/11/21

    DATE=$(date +%y%m%d_%H%M%S)
    Destination=$1
    Target=$2
    echo ${Target}
    Here=$(pwd)/"forum_backup_${DATE}.tar.gz"
    tar cvzf "forum_backup_${DATE}.tar.gz" ${Target}
    Qty=10
    rsync -av --remove-source-files ${Here} ${Destination}
    ls -tp "${Destination}" | grep -v '/$' | tail -n +${Qty} | xargs -I {} rm -- ${Destination}/{}

  ```

  - Ou récupérer ce script [ici](Annexe/backup.sh)

- Tester
  - Créer un dossier qui servira de dossier backup
  - Créer un dossier cible avec un document qu'on veut envoyer dans notre pseudo-back
    ```
    [tamashi@server ~]$ mkdir pseudoBackup
    [tamashi@server ~]$ mkdir toto
    [tamashi@server ~]$ ls
    Dockerfile  Forum  Forum.zip  go  pseudoBackup  toto
    [tamashi@server ~]$ cd toto/
    [tamashi@server toto]$ ls
    [tamashi@server toto]$ touch TestBackScript.txt
    [tamashi@server toto]$ ls
    TestBackScript.txt
    [tamashi@server toto]$ vim TestBackScript.txt
    [tamashi@server toto]$ cat TestBackScript.txt
    TEst du script de backup
    [tamashi@server toto]$ cd ..
    ```
  
  - Executer notre script
    ```
    [tamashi@server ~]$ sudo bash -x /srv/backup.sh pseudoBackup/ toto/TestBackScript.txt
    ++ date +%y%m%d_%H%M%S
    + DATE=211111_140305
    + Destination=pseudoBackup/
    + Target=toto/TestBackScript.txt
    + echo toto/TestBackScript.txt
    toto/TestBackScript.txt
    ++ pwd
    + Here=/home/tamashi/forum_backup_211111_140305.tar.gz
    + tar cvzf forum_backup_211111_140305.tar.gz toto/TestBackScript.txt
    toto/TestBackScript.txt
    + Qty=10
    + rsync -av --remove-source-files /home/tamashi/forum_backup_211111_140305.tar.gz pseudoBackup/
    sending incremental file list
    forum_backup_211111_140305.tar.gz

    sent 279 bytes  received 43 bytes  644.00 bytes/sec
    total size is 160  speedup is 0.50
    + tail -n +10
    + xargs -I '{}' rm -- 'pseudoBackup//{}'
    + ls -tp pseudoBackup/
    + grep -v '/$'
    ```
  - Vérifier la récupération:
    ```
    [tamashi@server ~]$ cd pseudoBackup/
    [tamashi@server pseudoBackup]$ ls
    forum_backup_211111_140305.tar.gz
    [tamashi@server pseudoBackup]$ sudo tar xzvf forum_backup_211111_140305.tar.gz
    toto/TestBackScript.txt
    [tamashi@server pseudoBackup]$ ls
    forum_backup_211111_140305.tar.gz  toto
    [tamashi@server pseudoBackup]$ cd toto
    [tamashi@server toto]$ ls
    TestBackScript.txt
    [tamashi@server toto]$ cat TestBackScript.txt
    TEst du script de backup
    ```

### B. Mise en place de l'unité de service 

- Créer l'unité de service:
  ```
  [tamashi@server ~]$ sudo vim /etc/systemd/system/backup.service
  [tamashi@server ~]$ sudo cat /etc/systemd/system/backup.service
  [Unit]
  Description=Our own lil backup service

  [Service]
  ExecStart=sudo bash /srv/backup.sh /home/tamashi/pseudoBackup /home/tamashi/toto/
  Type=oneshot
  RemainAfterExit=no

  [Install]
  WantedBy=multi-user.target
  ```

>Pour le test nous aurons pour destination notre `pseudoBackup` et pour cible notre dossier `toto`

- Tester l'unité
  ```
  [tamashi@server ~]$ sudo systemctl start backup.service
  [tamashi@server ~]$ ls -l pseudoBackup/
  total 8
  -rw-r--r--. 1 root root 160 Nov 11 14:03 forum_backup_211111_140305.tar.gz
  -rw-r--r--. 1 root root 194 Nov 11 14:20 forum_backup_211111_142053.tar.gz
  drwxr-xr-x. 2 root root  32 Nov 11 14:06 toto
  [tamashi@server ~]$
  ```

- Créer le timer de notre service
  ``` 
  [tamashi@server ~]$ sudo vim /etc/systemd/system/backup.timer
  [tamashi@server ~]$ sudo cat /etc/systemd/system/backup.timer
  Description=Periodically run our backup script
  Requires=backup.service

  [Timer]
  Unit=backup.service
  OnUnitActiveSec=60
  #OnCalendar=*-*-* *:*:00

  [Install]
  WantedBy=timers.target
  ```

- Activer notre timer:
  ```
  [tamashi@server ~]$ sudo systemctl daemon-reload
  [tamashi@server ~]$ sudo systemctl start backup.timer
  [tamashi@server ~]$ sudo systemctl enable backup.timer
  Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
  [tamashi@server ~]$ sudo systemctl is-enabled backup.timer
  enabled
  [tamashi@server ~]$ sudo systemctl is-active backup.timer
  active
  [tamashi@server ~]$ sudo systemctl status backup.timer
  ● backup.timer
    Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor preset: disabled)
    Active: active (elapsed) since Thu 2021-11-11 14:28:36 CET; 27s ago
    Trigger: n/a

  Nov 11 14:28:36 server.tp3.linux systemd[1]: /etc/systemd/system/backup.timer:1: Assignment outside of section. Ignoring.
  Nov 11 14:28:36 server.tp3.linux systemd[1]: /etc/systemd/system/backup.timer:2: Assignment outside of section. Ignoring.
  Nov 11 14:28:36 server.tp3.linux systemd[1]: Started backup.timer.
  Nov 11 14:28:41 server.tp3.linux systemd[1]: /etc/systemd/system/backup.timer:1: Assignment outside of section. Ignoring.
  Nov 11 14:28:41 server.tp3.linux systemd[1]: /etc/systemd/system/backup.timer:2: Assignment outside of section. Ignoring. 
  ```

- Tester timer d'1 min:
  ```
  [tamashi@server ~]$ ls -l pseudoBackup/
  total 8
  -rw-r--r--. 1 root root 160 Nov 11 14:03 forum_backup_211111_140305.tar.gz
  -rw-r--r--. 1 root root 194 Nov 11 14:20 forum_backup_211111_142053.tar.gz
  drwxr-xr-x. 2 root root  32 Nov 11 14:06 toto
  [tamashi@server ~]$ sudo systemctl start backup.service
  [sudo] password for tamashi:
  [tamashi@server ~]$ ls -l pseudoBackup/
  total 16
  -rw-r--r--. 1 root root 160 Nov 11 14:03 forum_backup_211111_140305.tar.gz
  -rw-r--r--. 1 root root 194 Nov 11 14:20 forum_backup_211111_142053.tar.gz
  -rw-r--r--. 1 root root 194 Nov 11 14:49 forum_backup_211111_144922.tar.gz
  drwxr-xr-x. 2 root root  32 Nov 11 14:06 toto
  [tamashi@server ~]$ ls -l pseudoBackup/
  total 20
  -rw-r--r--. 1 root root 160 Nov 11 14:03 forum_backup_211111_140305.tar.gz
  -rw-r--r--. 1 root root 194 Nov 11 14:20 forum_backup_211111_142053.tar.gz
  -rw-r--r--. 1 root root 194 Nov 11 14:49 forum_backup_211111_144922.tar.gz
  -rw-r--r--. 1 root root 194 Nov 11 14:50 forum_backup_211111_145022.tar.gz
  drwxr-xr-x. 2 root root  32 Nov 11 14:06 toto
  [tamashi@server pseudoBackup]$ sudo systemctl stop backup.timer
  ```
  
### C. Concret
- Modifier le `backup.service` pour qu'il est en destination notre `/srv/backup` et en target notre `/home/tamashi/Forum`
  ```
  [tamashi@server pseudoBackup]$ sudo vim /etc/systemd/system/backup.service
  [sudo] password for tamashi:
  [tamashi@server pseudoBackup]$ sudo cat /etc/systemd/system/backup.service
  [Unit]
  Description=Our own lil backup service

  [Service]
  ExecStart=sudo bash /srv/backup.sh /srv/backup /home/tamashi/Forum/
  Type=oneshot
  RemainAfterExit=no

  [Install]
  WantedBy=multi-user.target
  ```

- Modifier le `backup.timer` pour que notre service s'exécute tout les jours à 2h25
  ```
  [tamashi@server pseudoBackup]$ sudo vim /etc/systemd/system/backup.timer
  [tamashi@server pseudoBackup]$ sudo cat /etc/systemd/system/backup.timer
  Description=Periodically run our backup script
  Requires=backup.service

  [Timer]
  Unit=backup.service
  OnCalendar=*-*-* 2:25:00

  [Install]
  WantedBy=timers.target
  [tamashi@server pseudoBackup]$ sudo systemctl daemon-reload
  [tamashi@server pseudoBackup]$ sudo systemctl start backup.timer
  [tamashi@server pseudoBackup]$
  [tamashi@server pseudoBackup]$ sudo systemctl is-active backup.timer
  active
  [tamashi@server pseudoBackup]$ sudo systemctl is-enabled backup.timer
  enabled
  ```

- Vérifier les modifications du timer
  ```
  [tamashi@server pseudoBackup]$ sudo systemctl list-timers
  NEXT                         LEFT          LAST                         PASSED       UNIT                         ACTIVATES
  Thu 2021-11-11 16:56:45 CET  1h 54min left Thu 2021-11-11 15:01:04 CET  1min 20s ago dnf-makecache.timer          dnf-makecache.service
  Fri 2021-11-12 02:25:00 CET  11h left      n/a                          n/a          backup.timer                 backup.service
  Fri 2021-11-12 10:52:42 CET  19h left      Thu 2021-11-11 10:52:42 CET  4h 9min ago  systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

  3 timers listed.
  Pass --all to see loaded but inactive timers, too.
  [tamashi@server pseudoBackup]$
  ```

📁 **Fichier [backup.timer](Annexe/backup.timer)**  
📁 **Fichier [backup.service](Annexe/backup.service)**

## 6. Restrictions du firewall

Il faut bien comprendre que notre backup ne doit être accessible qu'à notre hôte et au service nfs. Nous allons donc limiter les accées:

- Mettre en place la zone de drop par défaut:
  ```
  [tamashi@backup ~]$ sudo firewall-cmd --set-default-zone=drop
  [sudo] password for tamashi:	
  success
  [tamashi@backup ~]$ sudo firewall-cmd --zone=drop --add-interface=enp0s8 --permanent
  The interface is under control of NetworkManager, setting zone to 'drop'.
  success
  ```

- Limiter l'accés par ssh à l'hôte:
  ```
  [tamashi@backup ~]$ sudo firewall-cmd --new-zone=ssh --permanent
  success
  [tamashi@backup ~]$ sudo firewall-cmd --zone=ssh --add-source=10.103.0.1/32 --permanent
  success
  [tamashi@backup ~]$ sudo firewall-cmd --zone=ssh --add-port=22/tcp --permanent
  success
  ```

- Limiter l'accés au server utilisant le service nfs:
  ```
  [tamashi@backup ~]$ sudo firewall-cmd --new-zone=nfs --permanent
  success
  [tamashi@backup ~]$ sudo firewall-cmd --zone=nfs --add-source=10.103.0.2/32 --permanent
  success
  [tamashi@backup ~]$ sudo firewall-cmd --zone=nfs --add-port=19999/tcp --permanent
  success
  [tamashi@backup ~]$ sudo firewall-cmd --zone=nfs --add-service=nfs --permanent
  success
  ```

- Tester notre réglage:
  ```
  [tamashi@backup ~]$ sudo firewall-cmd --get-active-zones
  [sudo] password for tamashi:
  drop
    interfaces: enp0s8 enp0s3
  nfs
    sources: 10.103.0.2/32
  ssh
    sources: 10.103.0.1/32
  [tamashi@backup ~]$ sudo firewall-cmd --list-all --zone=ssh
  ssh (active)
    target: default
    icmp-block-inversion: no
    interfaces:
    sources: 10.103.0.1/32
    services:
    ports: 22/tcp
    protocols:
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
  [tamashi@backup ~]$ sudo firewall-cmd --list-all --zone=nfs
  nfs (active)
    target: default
    icmp-block-inversion: no
    interfaces:
    sources: 10.103.0.2/32
    services: nfs
    ports: 19999/tcp
    protocols:
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
  [tamashi@backup ~]$ sudo firewall-cmd --list-all --zone=drop
  drop (active)
    target: DROP
    icmp-block-inversion: no
    interfaces: enp0s3 enp0s8
    sources:
    services:
    ports:
    protocols:
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
  [tamashi@backup ~]$
  ```
# VI. Automatisation

Voici quelques scripts permettant de correctemment mettre en palce tout ce qu'on vient de voir. 

Néanmoins, il vous faudra bien modifier l'IP des machines (`client.tp3.linux` non-compris) afin de suivre le tableau d'adressage suivant:
| Machine            | IP              | NAT   | Service                 | 
|--------------------|-----------------|-------|-------------------------|
| `server.tp3.linux` | `10.103.0.2`    | Oui   | Serveur Docker          |
| `back.tp3.linux`   | `10.103.0.3`    | Oui   | Backup          |
| `client.tp3.linux` | `10.103.0.150`  | Oui   |                         |

Voici quelque informations à savoir pour bien exécuter le script:
  - il faut lancer le script en tant que root (connectez vous au compte root ou utiliser la commande sudo)
  - on peut vérifier les lignes exécuter du code pendant qu'il tourne

## 1. Server 

Afin d'automatiser la mise en place du serveur, le script comprend:
  - Une mise a jour de `dnf`
  - Une décompression du `Forum.zip` 
  - L'installation et les réglages pour utiliser golang sur la machine
  - L'installation de GCC et sqlite3
  - Le régalge du firewall pour le forum
  - La mise à jour des droits sur `database`
  - L'installation et l'activation de Docker
  - La "construction" du container avec l'image app_forum2
  - L'installation et l'activation du service NFS
  - Le réglage du firewall
  - La création du dossier à partager et le montage de sa partition liée
  - Mise en place des fichiers `backup.time` et `backup.service` dans `/etc/systemd/system/`

Afin d'ajouter une partie interactive au script, celui-ci demande si l'utilisateur veut démarrer le `backup.timer` maintenant. Il en va de même pour le démarrage du container. Dans le cas où l'utilisateur répond "No", le script lui rappelle qu'elle commande utiliser afin de lancer lui même les services.

Une sorti type doit ressemnler à cela:
```
[tamashi@localhost ~]$ sudo bash Script/auto-server.sh
Hello tamashi ! I'm gonna do my job

Setup in progress

Add back.tp3.linux to your hosts
1/8 => Update ...
2/8 => Unzip Forum ...
3/8 => wget install ...
4/8 => Go configuration ...
5/8 => Sqlite ...
6/8 => GCC ...
7/8 => Setup database ...
8/8 => Firewall ...
Basic setup is end

Setup for Docker is starting...

1/4 => Move app_forum2 and rename it to DockerFile to use it ...
2/4 => Docker install ...
3/4 => Docker start & enable ...
4/4 => Build image forum ...
Docker OK!

Setup for the backup is starting...

1/4 => Install and Start nfs ...!
2/4 => Firewall ...!
3/4 => Directorie create & Partition created and monted ...!
4/4 => Move backup.sh/service/timer ...!
Backup server side OK!

Do you want to run the timer backup now? You can run it later manually

Yes/No:
Yes
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
Do you want to run the server (the container Docker) now? You can run it later manually

Yes/No:
No
You can use this for run it:
 docker run -p 4444:4444 -v /home/tamashi/Forum/:/share -it app_forum bash

```

📁 **Fichier [Script de Setup du `server.tp3.linux`](Annexe/auto-server.sh)**


## 2. Backup 

Afin d'automatiser la mise en place du backup, le script comprend:
  - Une mise a jour de `dnf`
  - L'installation d'un service NFS
  - La création du dossier à partager et son partage
  - Le lancement du service NFS
  - Le réglage du firewall
  - L'ajout du server dans `/etc/hosts`

Ce script est nettement plus simpliste que le précédent, mais el backup n'est utilisée que lors de sa mise en place, après on y accès qu'en cas d'urgence.

Voici une sorti type du script:
```
[tamashi@backup ~]$ sudo bash -x Script/auto-back.sh
++ pwd
+ here=/home/tamashi
+ woHome=tamashi
+ User=tamashi
+ echo -e 'Hello tamashi ! I'\''m gonna do my job\n'
Hello tamashi ! I'm gonna do my job

+ sleep 2
+ echo '1/6 => Adding server to your hosts ...'
1/6 => Adding server to your hosts ...
+ echo '2/6 => Update ...'
2/6 => Update ...
+ echo '3/6 => NFS installing ...'
3/6 => NFS installing ...
+ echo '4/6 => Directorie creating and sharing ...'
4/6 => Directorie creating and sharing ...
+ echo '5/6 => NFS Starting ...'
5/6 => NFS Starting ...
+ echo '6/6 => Setup the firewall ...'
6/6 => Setup the firewall ...
+ echo -e 'All is good, you can use this \n'
All is good, you can use this

```