#!/usr/bin/env bash
echo "###########################################################################"
echo "# Ark Server - " `date`
echo "# STEAM_UID $STEAM_UID - STEAM_GID $STEAM_GID"
echo "# DATA_DIR $DATA_DIR - HOME $HOME"
echo "###########################################################################"\

# Change working directory to ${DATA_DIR} to allow relative path
mkdir -p ${DATA_DIR}
cd ${DATA_DIR}

# Directory Definitions
LOG_DIR="${DATA_DIR}/log"
BACKUP_DIR="${DATA_DIR}/backup"
STAGING_DIR="${DATA_DIR}/staging"
SERVER_DIR="${DATA_DIR}/server"
CONFIG_DIR="${DATA_DIR}/config"
TEMPLATE_DIR="${DATA_DIR}/template"
SAVES_DIR="${DATA_DIR}/saves"


# Create Directories
directories=( ${LOG_DIR} ${BACKUP_DIR} ${STAGING_DIR} ${SERVER_DIR} ${CONFIG_DIR} ${SAVES_DIR} )
for i in "${directories[@]}"
do
	mkdir -p $i
done

# Ark Manager Configs
ARK_MANAGER_CFG_FILE="${CONFIG_DIR}/arkmanager.cfg"

# Game Configs 
GAME_INI_FILE="${CONFIG_DIR}/Game.ini"
GAME_USER_SETTINGS_INIT_FILE="${CONFIG_DIR}/GameUserSettings.ini"

# Steam Crontab
CRONTAB_FILE="${CONFIG_DIR}/crontab"

[ -p /tmp/FIFO ] && rm /tmp/FIFO
mkfifo /tmp/FIFO

export TERM=linux

function stop {
	if [ ${BACKUP_ON_STOP} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks)" ]; then
		echo "[Backup on stop]"
		arkmanager backup
	fi
	if [ ${WARN_ON_STOP} -eq 1 ];then 
	    arkmanager stop --warn
	else
	    arkmanager stop
	fi
	exit
}


# Add a template directory to store the last version of config file
[ ! -d ${TEMPLATE_DIR} ] && mkdir -p ${TEMPLATE_DIR}

# We overwrite the template file each time
cp /home/steam/.arkmanager.cfg ${TEMPLATE_DIR}/arkmanager.cfg
cp /home/steam/crontab ${TEMPLATE_DIR}/crontab


# Create arkmanager config if it doesnt exist
[ ! -f ${ARK_MANAGER_CFG_FILE} ] && cp /home/steam/.arkmanager.cfg ${ARK_MANAGER_CFG_FILE}

if [ ! $(cmp -s "/home/steam/.arkmanager.cfg" "${ARK_MANAGER_CFG_FILE}") ]; then
	cp /home/steam/.arkmanager.cfg "${ARK_MANAGER_CFG_FILE}.readme"
fi

# Creating symbolic links
[ ! -L ${GAME_INI_FILE} ] && ln -s ${SERVER_DIR}/ShooterGame/Saved/Config/LinuxServer/Game.ini ${GAME_INI_FILE}
[ ! -L ${GAME_USER_SETTINGS_INIT_FILE} ] && ln -s ${SERVER_DIR}/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini ${GAME_USER_SETTINGS_INIT_FILE}
[ ! -f ${CRONTAB_FILE} ] && cp ${TEMPLATE_DIR}/crontab ${CRONTAB_FILE}



if [ ! -d ${SERVER_DIR}  ] || [ ! -f ${SERVER_DIR}/version.txt ];then 
	echo "No game files found. Installing..."
	mkdir -p ${SERVER_DIR}/ShooterGame/Saved/SavedArks
	mkdir -p ${SERVER_DIR}/ShooterGame/Content/Mods
	mkdir -p ${SERVER_DIR}/ShooterGame/Binaries/Linux/
	touch ${SERVER_DIR}/ShooterGame/Binaries/Linux/ShooterGameServer
	arkmanager install
	# Create mod dir
else
	if [ ${BACKUP_ON_START} -eq 1 ] && [ "$(ls -A ${SERVER_DIR}/ShooterGame/Saved/SavedArks/)" ]; then 
		echo "[Backup]"
		arkmanager backup
	fi
fi

# If there is uncommented line in the file
CRON_NUMBER=`grep -v "^#" ${CRONTAB_FILE} | wc -l`
if [ $CRON_NUMBER -gt 0 ]; then
	echo "Loading crontab..."
	# We load the crontab file if it exist.
	crontab ${CRONTAB_FILE}
	# Cron is attached to this process
	sudo cron -f &
else
	echo "No crontab set."
fi

# Launching ark server
if [ $UPDATE_ON_START -eq 0 ]; then
	arkmanager start --noautoupdate
else
	arkmanager start
fi


# Stop server in case of signal INT or TERM
echo "Waiting..."
trap stop INT
trap stop TERM

read < /tmp/FIFO &
tail -f ${LOG_DIR}/*.log
wait
