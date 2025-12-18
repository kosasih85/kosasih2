#!/bin/bash
set -e

echo "========================================"
echo " INSTALL & CONFIG OPENSSH (ROOT ACCESS)"
echo "========================================"

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Jalankan script ini sebagai root!"
  exit 1
fi

echo "[1/5] Update sistem..."
apt update -y

echo "[2/5] Install openssh-server..."
apt install -y openssh-server

echo "[3/5] Backup konfigurasi sshd..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%F_%T)

echo "[4/5] Konfigurasi SSH agar root bisa login..."

# Aktifkan PermitRootLogin
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# Pastikan PasswordAuthentication aktif
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Nonaktifkan PAM agar password root stabil
sed -i 's/^#\?UsePAM.*/UsePAM no/' /etc/ssh/sshd_config

echo "[5/5] Restart SSH service..."
systemctl restart ssh
systemctl enable ssh

echo "========================================"
echo " SELESAI"
echo " SSH aktif dengan login root"
echo " Port default : 22"
echo "========================================"

echo
echo "⚠️ KEAMANAN:"
echo "- Pastikan root punya password:  passwd root"
echo "- Disarankan ganti port SSH & pakai firewall"
