FROM cm2network/steamcmd:root

ENV DATA_DIR "/ark"

# Var for first config
# Server Name
ENV SESSION_NAME "Ark Docker"

# Map name
ENV SERVER_MAP "TheIsland"

# Server password
ENV SERVER_PASSWORD ""

# Admin password
ENV ADMIN_PASSWORD "admin"

# Nb Players
ENV MAX_PLAYERS 70

# If the server is updating when start with docker start
ENV UPDATE_ON_START 0

# if the server is backup when start with docker start
ENV BACKUP_ON_START 0

#  Tag on github for ark server tools
ENV GIT_TAG v1.6.53

# Server PORT (you can't remap with docker, it doesn't work)
ENV SERVER_PORT 27015

# Steam port (you can't remap with docker, it doesn't work)
ENV STEAM_PORT 7778

# if the server should backup after stopping
ENV BACKUP_ON_STOP 0

# If the server warn the players before stopping
ENV WARN_ON_STOP 0

# STEAM_UID of the user steam
ENV STEAM_UID 1000

# STEAM_GID of the user steam
ENV STEAM_GID 1000

ENV ARKST_CHANNEL "master"

# Install dependencies 
RUN apt-get update &&\ 
    apt-get install -y \
	sudo \
    cron \
	git \
	perl-modules \
	curl \
	lsof \
	libc6-i386 \
	lib32gcc1

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i.bkp -e \
	's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
	/etc/sudoers

RUN usermod -a -G sudo steam

# Copy & rights to folders
COPY scripts/run.sh /home/steam/run.sh
COPY scripts/user.sh /home/steam/user.sh
COPY config/crontab.cfg /home/steam/crontab
COPY config/arkmanager-user.cfg /home/steam/.arkmanager.cfg

RUN touch /root/.bash_profile
RUN chmod +rx /home/steam/run.sh
RUN chmod +rx /home/steam/user.sh

# Setup directories
RUN mkdir -p ${DATA_DIR}

# We use the git method, because api github has a limit ;)
RUN  git clone --branch $GIT_TAG https://github.com/FezVrasta/ark-server-tools.git /home/steam/ark-server-tools

# Set working dir for server tool install
WORKDIR /home/steam/ark-server-tools/
RUN  git checkout $GIT_TAG 

# Install 
WORKDIR /home/steam/ark-server-tools/tools
RUN chmod +x install.sh 
RUN ./install.sh steam 

# Allow crontab to call arkmanager
RUN ln -s /usr/local/bin/arkmanager /usr/bin/arkmanager

# Define default config file in /etc/arkmanager
COPY config/arkmanager-system.cfg /etc/arkmanager/arkmanager.cfg

# Define default config file in /etc/arkmanager
COPY config/instance.cfg /etc/arkmanager/instances/main.cfg

RUN chown steam -R ${DATA_DIR} && chmod 755 -R ${DATA_DIR}

EXPOSE ${STEAM_PORT} 32330 ${SERVER_PORT}
# Add UDP
EXPOSE ${STEAM_PORT}/udp ${SERVER_PORT}/udp

# Change the working directory to ${DATA_DIR}d
WORKDIR ${DATA_DIR}

# Update game launch the game.
ENTRYPOINT ["/home/steam/user.sh"]
