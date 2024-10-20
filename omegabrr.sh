#!/usr/bin/env bash
source <(curl -s https://gist.githubusercontent.com/fredrikln/1169d235a8836e973e1782175818f1e4/raw/e18f7a767133d95f44254c49cc6eda1fcb03a3cd/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   ____                             __
  / __ \____ ___  ___  ____ _____ _/ /_  __________
 / / / / __ `__ \/ _ \/ __ `/ __ `/ __ \/ ___/ ___/
/ /_/ / / / / / /  __/ /_/ / /_/ / /_/ / /  / /
\____/_/ /_/ /_/\___/\__, /\__,_/_.___/_/  /_/
                    /____/
EOF
}
header_info
echo -e "Loading..."
APP="Omegabrr"
var_disk="8"
var_cpu="2"
var_ram="2048"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
header_info
if [[ ! -f /root/.config/omegabrr/config.yaml ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Stopping ${APP} LXC"
systemctl stop omegabrr.service
msg_ok "Stopped ${APP} LXC"

msg_info "Updating ${APP} LXC"
rm -rf /usr/local/bin/*
wget -q $(curl -s https://api.github.com/repos/autobrr/omegabrr/releases/latest | grep download | grep linux_amd64 | cut -d\" -f4)
tar -C /usr/local/bin -xzf omegabrr*.tar.gz
rm -rf omegabrr*.tar.gz
msg_ok "Updated ${APP} LXC"

msg_info "Starting ${APP} LXC"
systemctl start omegabrr.service
msg_ok "Started ${APP} LXC"
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:7441${CL} \n"
