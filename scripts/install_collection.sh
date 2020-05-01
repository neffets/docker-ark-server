#!/usr/bin/env bash

install_mods() {
    MOD_IDS=$(curl -s https://steamcommunity.com/sharedfiles/filedetails/\?id=$1 | grep "a href=" | grep "workshopItemTitle" | grep -oE "[0-9]{8,}" | tr '\n' ',' | sed 's/\,$//g')

    IFS=',' read -ra mod_id_array <<< "${MOD_IDS}"
    
    #Print the split string
    for i in "${mod_id_array[@]}"
    do
        echo "Installing: $i...."
        arkmanager installmod $i
        echo "Enabling: $i...."
        arkmanager enablemod $i
    done
}


if [ "$1" != "" ]; then
    echo "Positional parameter 1 contains something"
    install_mods $1

else
    echo "Positional parameter 1 is empty"
fi
