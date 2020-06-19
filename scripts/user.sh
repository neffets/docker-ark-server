#!/bin/sh

# Change the STEAM_UID if needed
if [ ! "$(id -u steam)" -eq "${STEAM_UID}" ]; then 
	echo "Changing steam STEAM_UID to ${STEAM_UID}."
	usermod -o -u "${STEAM_UID}" steam ; 
fi
# Change STEAM_GID if needed
if [ ! "$(id -g steam)" -eq "$STEAM_GID" ]; then 
	echo "Changing steam STEAM_GID to $STEAM_GID."
	groupmod -o -g "$STEAM_GID" steam ; 
fi

# Put steam owner of directories (if the STEAM_UID changed, then it's needed)
chown -R steam:steam ${DATA_DIR} /home/steam

# avoid error message when su -p (we need to read the /root/.bash_rc )
chmod -R +r /root

# Launch run.sh with user steam (-p allow to keep env variables)
sudo -E -u steam HOME=/home/steam bash -c /home/steam/run.sh
