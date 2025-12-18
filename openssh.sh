#!/bin/bash

set -e

# ==============================
# CEK ROOT
# ==============================
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Jalankan sebagai root!"
  exit 1
fi

# ==============================
# FUNGSI UMUM
# ==============================
pause() {
  read -p "Tekan ENTER untuk kembali ke menu..."
}

update_sys() {
  apt update -y
  apt install -y curl wget gnupg lsb-release ca-certificates software-properties-common
}

# ==============================
# 1. OPENSSH ROOT
# ==============================
install_ssh_root() {
  echo "[+] Install OpenSSH Server + Root Access"
  update_sys
  apt install -y openssh-server

  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/^#\?UsePAM.*/UsePAM no/' /etc/ssh/sshd_config

  systemctl restart ssh
  systemctl enable ssh

  echo "[OK] SSH aktif | Root login ENABLED"
}

# ==============================
# 2. WEBMIN
# ==============================
install_webmin() {
  echo "[+] Install Webmin"
  update_sys

  wget -qO- http://www.webmin.com/jcameron-key.asc | gpg --dearmor -o /usr/share/keyrings/webmin.gpg
  echo "deb [signed-by=/usr/share/keyrings/webmin.gpg] http://download.webmin.com/download/repository sarge contrib" \
    > /etc/apt/sources.list.d/webmin.list

  apt update -y
  apt install -y webmin

  echo "[OK] Webmin: https://IP:10000"
}

# ==============================
# 3. JELLYFIN
# ==============================
install_jellyfin() {
  echo "[+] Install Jellyfin"
  update_sys

  curl -fsSL https://repo.jellyfin.org/install-debuntu.sh | bash

  echo "[OK] Jellyfin: http://IP:8096"
}

# ==============================
# 4. PIJARR
# ==============================
install_pijarr() {
  echo "[+] Install Pijarr"
  update_sys

  apt install -y git python3 python3-pip ffmpeg

  cd /opt
  if [ ! -d "pijarr" ]; then
    git clone https://github.com/pijarr/pijarr.git
  fi

  cd pijarr
  pip3 install -r requirements.txt || true

  echo "[OK] Pijarr terinstall di /opt/pijarr"
}

# ==============================
# 5. DOCKER 26.1.4 (CASAOS SAFE)
# ==============================
install_docker() {
  echo "[+] Install Docker 26.1.4 (CasaOS Compatible)"
  update_sys

  apt remove -y docker docker.io docker-engine containerd runc || true

  curl -fsSL https://get.docker.com | sh

  apt install -y docker-ce=5:26.1.4* docker-ce-cli=5:26.1.4* containerd.io

  systemctl enable docker
  systemctl start docker

  docker --version
  echo "[OK] Docker 26.1.4 siap"
}

# ==============================
# 6. CASA OS
# ==============================
install_casaos() {
  echo "[+] Install CasaOS"
  curl -fsSL https://get.casaos.io | bash

  echo "[OK] CasaOS: http://IP:80"
}

# ==============================
# MENU
# ==============================
while true; do
  clear
  echo "========================================="
  echo "   UBUNTU SERVER INSTALLER MENU"
  echo "========================================="
  echo "1. Install SSH + Enable Root"
  echo "2. Install Webmin"
  echo "3. Install Jellyfin"
  echo "4. Install Pijarr"
  echo "5. Install Docker 26.1.4 (CasaOS)"
  echo "6. Install CasaOS"
  echo "7. Exit"
  echo "========================================="
  read -p "Pilih [1-7]: " pilih

  case $pilih in
    1) install_ssh_root; pause ;;
    2) install_webmin; pause ;;
    3) install_jellyfin; pause ;;
    4) install_pijarr; pause ;;
    5) install_docker; pause ;;
    6) install_casaos; pause ;;
    7) echo "Keluar..."; exit 0 ;;
    *) echo "Pilihan tidak valid"; sleep 1 ;;
  esac
done
