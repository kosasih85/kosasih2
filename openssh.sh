#!/bin/bash

# Script instalasi dengan menu pilihan
# Dijalankan dengan sudo/root

echo "=================================="
echo "     Menu Instalasi Server      "
echo "=================================="
echo "1. Install OpenSSH-Server (dengan akses root via SSH)"
echo "2. Install CasaOS"
echo "3. Install Webmin"
echo "4. Install Jellyfin"
echo "5. Install PiJARR (suite *arr apps)"
echo "0. Keluar"
echo "=================================="

read -p "Pilih nomor (1-5 atau 0): " pilihan

case $pilihan in
    1)
        echo "Menginstall OpenSSH-Server..."
        apt update
        apt install -y openssh-server
        # Aktifkan login root via SSH (hati-hati, kurang aman jika tidak pakai key)
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
        systemctl restart ssh
        echo "OpenSSH-Server terinstall. Akses root via SSH diaktifkan (ubah password root jika perlu)."
        ;;
    2)
        echo "Menginstall CasaOS..."
        apt update
        apt install -y curl wget zip unzip
        wget -qO- https://get.casaos.io | bash
        echo "CasaOS terinstall. Akses via http://IP-ANDA:80"
        ;;
    3)
        echo "Menginstall Webmin..."
        apt update
        apt install -y curl
        curl -o setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
        sh setup-repo.sh
        apt update
        apt install -y webmin
        rm setup-repo.sh
        echo "Webmin terinstall. Akses via https://IP-ANDA:10000"
        ;;
    4)
        echo "Menginstall Jellyfin..."
        apt update
        apt install -y curl gnupg
        curl -fsSL https://repo.jellyfin.org/install-debuntu.sh | bash
        echo "Jellyfin terinstall. Akses via http://IP-ANDA:8096"
        ;;
    5)
        echo "Menginstall PiJARR (Jackett, Sonarr, Radarr, dll)..."
        apt update
        sh -c "$(wget -qO- https://raw.githubusercontent.com/pijarr/pijarr/main/setup.sh)"
        echo "PiJARR terinstall. Ikuti petunjuk di script untuk konfigurasi lebih lanjut."
        ;;
    0)
        echo "Keluar."
        exit 0
        ;;
    *)
        echo "Pilihan tidak valid!"
        exit 1
        ;;
esac

echo "Instalasi selesai!"
