# ARK: Survival Evolved - Docker

```txt
Note: The original repo was designed to run ark in a docker container but it was failing. 
I rewrote the docker image and updated it to run in Kubernetes. There are some concepts barrowed from TuRz4m/Ark-docker but
this is completely rewritten with a new directory strucutre. 

Original repo: https://github.com/TuRz4m/Ark-docker 
```

Docker build for managing an ARK: Survival Evolved server.

This image uses [Ark Server Tools](https://github.com/FezVrasta/ark-server-tools) to manage an ark server.

## Features
 - Easy install (no steamcmd / lib32... to install)
 - Use Ark Server Tools : update/install/start/backup/rcon/mods
 - Easy crontab configuration
 - Easy access to ark config file
 - Mods handling (via Ark Server Tools)
 - `Docker stop` is a clean stop 

## Usage
Fast & Easy server setup :   
```sh
docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -e SESSION_NAME=myserver -e ADMIN_PASSWORD="mypasswordadmin" --name ark-server neffets/ark-server:1.0`
```

You can map the ark volume to access config files :  
```sh
docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -e SESSION_NAME=myserver -v /my/path/to/ark:/ark --name ark-server neffets/ark-server:1.0
```
Then you can edit */my/path/to/ark/config/arkmanager.cfg* (the values override GameUserSetting.ini) and */my/path/to/ark/config/[GameUserSetting.ini/Game.ini]*

You can manager your server with rcon if you map the rcon port (you can rebind the rcon port with docker):  
```sh
docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -p 32330:32330  -e SESSION_NAME=myserver --name ark-server neffets/ark-server:1.0`  
```

You can change server and steam port to allow multiple servers on same host:  
*(You can't just rebind the port with docker. It won't work, you need to change STEAM_PORT & SERVER_PORT variable)*
```sh
docker run -d -p 7779:7779 -p 7779:7779/udp -p 27016:27016 -p 27016:27016/udp -p 32331:32330  -e SESSION_NAME=myserver2 -e SERVER_PORT=27016 -e STEAM_PORT=7779 --name ark2-server neffets/ark-server:1.0
```


You can check your server with :  
`docker exec ark arkmanager status` 

You can manually update your mods:  
`docker exec ark arkmanager update --update-mods` 

You can manually update your server:  
`docker exec ark arkmanager update --force` 

You can force save your server :  
`docker exec ark arkmanager saveworld` 

You can backup your server :  
`docker exec ark arkmanager backup` 

You can upgrade Ark Server Tools :  
`docker exec ark arkmanager upgrade-tools` 

You can use rcon command via docker :  
`docker exec ark arkmanager rconcmd ListPlayers`  
*Full list of available command [here](http://steamcommunity.com/sharedfiles/filedetails/?id=454529617&searchtext=admin)*

__You can check all available command for arkmanager__ [here](https://github.com/FezVrasta/ark-server-tools/blob/master/README.md)

You can easily configure automatic update and backup.  
If you edit the file `/my/path/to/ark/crontab` you can add your crontab job.  
For example :  
`# Update the server every hours`  
`0 * * * * arkmanager update --warn --update-mods >> ${DATA_DIR}/log/crontab.log 2>&1`    
`# Backup the server each day at 00:00  `  
`0 0 * * * arkmanager backup >> ${DATA_DIR}/log/crontab.log 2>&1`  
*You can check [this website](http://www.unix.com/man-page/linux/5/crontab/) for more information on cron.*

To add mods, you only need to change the variable ark_GameModIds in *arkmanager.cfg* with a list of your modIds (like this  `ark_GameModIds="987654321,1234568"`). If UPDATE_ON_START is enable, just restart your docker or use `docker exec ark arkmanager update --update-mods`.

---

## Recommended Usage
- First run  
 `docker run -it -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -p 32330:32330 -e SESSION_NAME=myserver -e ADMIN_PASSWORD="mypasswordadmin" -e AUTOUPDATE=120 -e AUTOBACKUP=60 -e WARNMINUTE=30 -v /my/path/to/ark:/ark --name ark-server neffets/ark-server:1.0`  
- Wait for ark to be downloaded installed and launched, then Ctrl+C to stop the server.
- Edit */my/path/to/ark/config/GameUserSetting.ini and Game.ini*
- Edit */my/path/to/ark/config/arkserver.cfg* to add mods and configure warning time.
- Add auto update every day and autobackup by editing */my/path/to/ark/config/crontab* with this lines :  
`0 0 * * * arkmanager update --warn --update-mods >> ${DATA_DIR}/log/crontab.log 2>&1`  
`0 0 * * * arkmanager backup >> ${DATA_DIR}/log/crontab.log 2>&1`  
- `docker start ark`
- Check your server with :  
 `docker exec ark arkmanager status` 

--- 

## Variables
+ __SESSION_NAME__
Name of your ark server (default : "Ark Docker")
+ __SERVER_MAP__
Map of your ark server (default : "TheIsland")
+ __SERVER_PASSWORD__
Password of your ark server (default : "")
+ __ADMIN_PASSWORD__
Admin password of your ark server (default : "ADMIN_PASSWORD")
+ __SERVER_PORT__
Ark server port (can't rebind with docker, it doesn't work) (default : 27015)
+ __STEAM_PORT__
Steam server port (can't rebind with docker, it doesn't work) (default : 7778)
+ __BACKUP_ON_START__
1 : Backup the server when the container is started. 0: no backup (default : 1)
+ __UPDATEP_ON_START__
1 : Update the server when the container is started. 0: no update (default : 1)  
+ __BACKUP_ON_STOP__
1 : Backup the server when the container is stopped. 0: no backup (default : 0)
+ __WARN_ON_STOP__
1 : Warn the players before the container is stopped. 0: no warning (default : 0)  
+ __TZ__
Time Zone : Set the container timezone (for crontab). (You can get your timezone posix format with the command `tzselect`. For example, France is "Europe/Paris").
+ __STEAM_UID__
STEAM_UID of the user used. Owner of the volume ${DATA_DIR}
+ __STEAM_GID__
STEAM_GID of the user used. Owner of the volume ${DATA_DIR}


--- 

## Volumes
+ __/ark__ : Working directory :
    + ${DATA_DIR}/server : Server files and data.
    + ${DATA_DIR}/server : Server files and data.
    + ${DATA_DIR}/log : logs
    + ${DATA_DIR}/backup : backups
    + ${DATA_DIR}/config/arkmanager.cfg : config file for Ark Server Tools
    + ${DATA_DIR}/config/crontab : crontab config file
    + ${DATA_DIR}/config/Game.ini : ark game.ini config file
    + ${DATA_DIR}/config/GameUserSetting.ini : ark gameusersetting.ini config file
    + ${DATA_DIR}/template : Default config files
    + ${DATA_DIR}/template/arkmanager.cfg : default config file for Ark Server Tools
    + ${DATA_DIR}/template/crontab : default config file for crontab
    + ${DATA_DIR}/staging : default directory if you use the --downloadonly option when updating.

--- 

## Expose
+ Port : __STEAM_PORT__ : Steam port (default: 7778)
+ Port : __SERVER_PORT__ : server port (default: 27015)
+ Port : __32330__ : rcon port

---

## Known issues

 - Editing configs on a kubernetes cluster can be difficult. 
 - Adding mods and enabling them is a bit funky

--- 

## Example Deployment

```yaml
---
apiVersion: v1
kind: Namespace
metadata: 
  name: ark-server
  labels: 
    name: ark-server

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ark-server-pv-claim
  namespace: ark-server
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20G

---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: ark-server
  name: ark-server
  labels:
    app: ark-server

spec:
  replicas: 1
  selector:
    matchLabels:
      app: ark-server
  template:
    metadata:
      labels:
        app: ark-server
    spec:
      containers:
        - name: ark-server
          imagePullPolicy: Always
          image: neffets/ark-server:1.6
          ports:
            - name: steam
              containerPort: 7778
            - name: join
              containerPort: 27015
          volumeMounts:
            - name: ark-server-persistent-storage
              mountPath: /ark
      volumes:
      - name: ark-server-persistent-storage
        persistentVolumeClaim:
          claimName: ark-server-pv-claim
---
apiVersion: v1
kind: Service
metadata:
  name: ark-server-service
  namespace: ark-server
  labels:
    name: ark-server
spec:
  externalIPs:
    - xx.xx.xx.xx
  ports:
    - port: 7778
      name: steam-tcp
      targetPort: 7778
      protocol: TCP
    - port: 7778
      name: steam-udp
      targetPort: 7778
      protocol: UDP
    - port: 27015
      name: game-tcp
      targetPort: 27015
      protocol: TCP
    - port: 27015
      name: game-udp
      targetPort: 27015
      protocol: UDP
  selector:
    app: ark-server
```

---

## Changelog
+ 1.0 : 
  - Initial image : works with Ark Server tools 1.3
  - Add auto-update & auto-backup  
+ 1.1 :  
  - Works with Ark Server Tools 1.4 [See changelog here](https://github.com/FezVrasta/ark-server-tools/releases/tag/v1.4)
  - Handle mods && auto update mods
+ 1.2 :
  - Remove variable AUTOBACKUP & AUTOUPDATE 
  - Remove variable WARNMINUTE (can now be find in arkmanager.cfg)
  - Add crontab support
  - You can now config crontab with the file /your/ark/path/crontab
  - Add template directory with default config files.
  - Add documentation on TZ variable.
+ 1.3 :
  - Add BACKUP_ON_STOP to backup the server when you stop the server (thanks to [fkoester](https://github.com/fkoester))
  - Add WARN_ON_STOP to add warning message when you stop the server (default: 60 min)
  - Works with Ark Server Tools v1.5
    - Compressing backups so they take up less space
    - Downloading updates to a staging directory before applying
    - Added support for automatically updating on restart
    - Show a spinner when updating
  - Add STEAM_UID & STEAM_GID to set the STEAM_UID & STEAM_GID of the user used in the container (and permissions on the volume ${DATA_DIR})
+ 1.4, 1.5, 1.6 :
  - bugfix for missing configfile_main for multiple instances, use DATA_DIR/instances
+ Rewrite :
  - Added kuberntes support
  - Rewrote the directory structure
