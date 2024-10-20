#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
msg_ok "Installed Dependencies"

msg_info "Installing Omegabrr"
wget -q $(curl -s https://api.github.com/repos/autobrr/omegabrr/releases/latest | grep download | grep linux_amd64 | cut -d\" -f4)
tar -C /usr/local/bin -xzf omegabrr*.tar.gz
rm -rf omegabrr*.tar.gz
mkdir -p /root/.config/omegabrr
cat <<EOF >>/root/.config/omegabrr/config.yaml
# https://autobrr.com/filters/omegabrr#configuration-sample
server:
  host: 0.0.0.0
  port: 7441
  apiToken: $(openssl rand -base64 24)
schedule: "0 */6 * * *"
clients:
  autobrr:
    host: http://localhost:7474
    apikey: YOUR_API_KEY
  arr:
    - name: Radarr
      type: radarr
      host: https://yourdomain.com/radarr
      apikey: YOUR_API_KEY
      filters:
        - 15 # Change me
      #matchRelease: false / true

    - name: Radarr-4K
      type: radarr
      host: https://yourdomain.com/radarr4k
      apikey: YOUR_API_KEY
      filters:
        - 16 # Change me
      #matchRelease: false / true

    - name: Sonarr
      type: sonarr
      host: https://yourdomain.com/sonarr
      apikey: YOUR_API_KEY
      basicAuth:
        user: username
        pass: password
      filters:
        - 14 # Change me
      #matchRelease: false / true
      #excludeAlternateTitles: false / true

    - name: lidarr
      type: lidarr
      host: https://yourdomain.com/lidarr
      apikey: YOUR_API_KEY
      filters:
        - 13 # Change me
      #matchRelease: false / true

    - name: readarr
      type: readarr
      host: https://yourdomain.com/readarr
      apikey: YOUR_API_KEY
      filters:
        - 12 # Change me

    - name: whisparr
      type: whisparr
      host: https://yourdomain.com/whisparr
      apikey: YOUR_API_KEY
      filters:
        - 69 # Change me
      #matchRelease: false / true

lists:
  - name: Latest TV Shows
    type: mdblist
    url: https://mdblist.com/lists/garycrawfordgc/latest-tv-shows/json
    filters:
      - 1 # Change me

  - name: Anticipated TV
    type: trakt
    url: https://api.autobrr.com/lists/trakt/anticipated-tv
    filters:
      - 22 # Change me

  - name: Upcoming Movies
    type: trakt
    url: https://api.autobrr.com/lists/trakt/upcoming-movies
    filters:
      - 21 # Change me

  - name: Upcoming Bluray
    type: trakt
    url: https://api.autobrr.com/lists/trakt/upcoming-bluray
    filters:
      - 24 # Change me

  - name: Popular TV
    type: trakt
    url: https://api.autobrr.com/lists/trakt/popular-tv
    filters:
      - 25 # Change me

  - name: StevenLu
    type: trakt
    url: https://api.autobrr.com/lists/stevenlu
    filters:
      - 23 # Change me

  - name: New Albums
    type: metacritic
    url: https://api.autobrr.com/lists/metacritic/new-albums
    filters:
      - 9 # Change me

  - name: Upcoming Albums
    type: metacritic
    url: https://api.autobrr.com/lists/metacritic/upcoming-albums
    filters:
      - 20 # Change me

  - name: Personal list
    type: plaintext
    url: https://gist.githubusercontent.com/autobrr/somegist/raw
    filters:
      - 27 # change me
    album: true # album or matchRelease can be optionally set to use these fields in your autobrr filter. If not set, it will use the Movies / Shows field.

  - name: Steam Wishlist
    type: steam
    url: https://store.steampowered.com/wishlist/id/USERNAME/wishlistdata
    filters:
      - 20 # Change me
EOF
msg_ok "Installed Omegabrr"

msg_info "Creating Service"
service_path="/etc/systemd/system/omegabrr.service"
echo "[Unit]
Description=omegabrr service
After=syslog.target network-online.target
[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/omegabrr run --config=/root/.config/omegabrr/config.yaml
[Install]
WantedBy=multi-user.target" >$service_path
systemctl enable --now -q omegabrr.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
