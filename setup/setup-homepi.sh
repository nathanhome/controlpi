#!/bin/bash

# generate ssh keys with:
# ssh-keygen -t ecdsa -b 521 -C "<Name of key owner>" -N "" -f <name des keyfiles>.key
# the easiest way is to do it directly in ~/.ssh directory

# this script is (as far as possible) idempotent. This means you can rerun it
# if you programmed an error and it will most probably work!

pi_hostname=$1
pi_new_user=$2
pi_keyfile=$3

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# this trick avoids additional scp logins
pi_authorized_keys=$(cat ${SCRIPT_DIR}/authorized_keys)
pi_sshd_config=$(cat ${SCRIPT_DIR}/sshd_config)        

function create_user {
    echo -n "
    if [ -z '\$(getent passwd $pi_new_user)' ]; then
        set -x
        echo '+++ New user: $pi_new_user +++'
        set +x
        useradd --uid 1114 --comment 'Doorpi system user' \
--create-home $pi_new_user &&
        usermod -a -G pi,adm,dialout,cdrom,sudo,audio,video,plugdev,\
games,users,input,netdev,gpio,i2c,spi $pi_new_user &&
        # move accesses from pi to new user
        mkdir -p ~$pi_new_user/.ssh &&
        chown $pi_new_user:$pi_new_user ~$pi_new_user/.ssh &&
        chmod 700 ~$pi_new_user/.ssh &&
        echo '$pi_authorized_keys' | tee ~$pi_new_user/.ssh/authorized_keys >/dev/null &&
        chown $pi_new_user:$pi_new_user ~$pi_new_user/.ssh/authorized_keys &&
        chmod 600 ~$pi_new_user/.ssh/authorized_keys
    else
        echo '--- Exist user: $pi_new_user ---'
    fi
    "
}


function setup_sshd_sudoers {
    echo -n "
    set -x
    echo '+++ Adapt sshd settings +++'
    set +x
    echo '$pi_sshd_config' | tee /etc/ssh/sshd_config >/dev/null
    sed -i -E 's/%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
    systemctl restart sshd
    "
}


function remove_pi_user {
    echo -n "
    if [ -n '\$(getent passwd pi)' ]; then
        set -x
        echo '+++ Remove user pi +++'
        set +x
        deluser --force --remove-home pi
    else
        set -x
        echo '--- pi user already removed ---'
        set +x
    fi
    "
}


function setup_localisation {
    echo -n "
    set -x
    echo '+++ UTC, en and UTF-8 as default +++'
    set +x
    sed -ri -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
    echo '$pi_hostname' | tee /etc/hostname >/dev/null
    echo 'LANG=en_GB.UTF-8' | sudo tee '/etc/default/locale' >/dev/null 
    timedatectl set-timezone Europe/Berlin
    dpkg-reconfigure -f noninteractive tzdata locales
    "
}


function setup_updates {
    echo -n "
    set -x
    echo '+++ Patching and unattended upgrades (best for distributed pis) +++' 
    set +x
    apt-get -y install unattended-upgrades
    sed -ri 's/^.*Unattended-Upgrade::Automatic-Reboot.*;/Unattended-Upgrade::Automatic-Reboot \"true\";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    dpkg-reconfigure -plow -f noninteractive unattended-upgrades
    apt-get -y update && apt-get -y upgrade
    "
}


function create_volumes {
    echo -n "
    set -x
    echo '+++ Create directory structure for different images of Nathan +++'    
    set +x
    mkdir -p ~$pi_new_user/.nathan/homeassistant/.sec
    mkdir -p ~$pi_new_user/.nathan/logs
    mkdir -p ~$pi_new_user/.nathan/.sec/mosquitto
    mkdir -p ~$pi_new_user/.nathan/.sec/zwave
    mkdir -p ~$pi_new_user/.nathan/.sec/homeassistant
    mkdir -p ~$pi_new_user/.nathan/config/mosquitto
    mkdir -p ~$pi_new_user/.nathan/config/zwave
    mkdir -p ~$pi_new_user/.nathan/config/homeassistant
    mkdir -p ~$pi_new_user/.nathan/data/mosquitto
    mkdir -p ~$pi_new_user/.nathan/data/zwave
    mkdir -p ~$pi_new_user/.nathan/data/homeassistant
    "
}


function install_docker {
    echo -n "
    set -x
    echo '+++ Docker installation with apt to set it under update +++'    
    set +x
    rm -f /etc/apt/sources.list.d/docker.list
    apt-get install -y -qq --no-install-recommends apt-transport-https ca-certificates curl git
    curl -fsSL 'https://download.docker.com/linux/raspbian/gpg' | sudo apt-key add -
    apt-key finger 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
    echo -n 'deb [arch=armhf] https://download.docker.com/linux/\$ID \$VERSION_CODENAME stable' |\
        tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y --no-install-recommends docker-ce python3 python3-pip
    apt-get -y update && apt-get -y upgrade
    pip3 install -q docker-compose
    usermod -a -G docker $pi_new_user
    "
}


###
# As pi user, create a replacement user with
# - given, different name
# - only accessible by ssh key
# - and sudoing without password
#   (which now only prevents stupid root usage for commands)
# - and hardened ssh config (only with string ciphers)
#
# -o StrictHostKeyChecking=no      
ssh -T pi@$pi_hostname "
sudo --prompt='' -S -- /bin/bash -c \"
    $(create_user)
    $(setup_sshd_sudoers)
    pkill -u pi
    \"
"

###
# copy files and directory to tmp position for move later
#scp -i $pi_keyfile -r ...

###
# with the replacement user, do different
# installations and hardenings
ssh -i $pi_keyfile $pi_new_user@$pi_hostname "
source /etc/os-release &&
sudo --prompt='' -S -- /bin/bash -c \"
    $(setup_localisation)
    $(setup_updates)
    ### start individual configuration
    $(create_volumes)
    $(install_docker)
     ### end individual configuration
    $(remove_pi_user)
    reboot
    \"
"
