#!/usr/bin/env bash
# Installs A Vulnerable-ish Test Surface (SSH + Apache) And The Wazuh Agent.
set -euo pipefail

WAZUH_VERSION="${WAZUH_VERSION:-4.14}"
WAZUH_MANAGER="${WAZUH_MANAGER:?WAZUH_MANAGER must be set}"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y openssh-server apache2 curl gnupg

# Enable SSH Password Login So The Brute-Force Exercise Has A Target.
# LAB ONLY: Never Do This On A Real System.
cat > /etc/ssh/sshd_config.d/99-lab.conf <<'EOF'
PasswordAuthentication yes
EOF
systemctl restart ssh

# Weak Lab User (Host-Only Network, Throwaway VM)
id labuser &>/dev/null || useradd -m -s /bin/bash labuser
echo "labuser:password123" | chpasswd

# Wazuh Agent
if ! dpkg -s wazuh-agent &>/dev/null; then
  curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring \
    --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
  chmod 644 /usr/share/keyrings/wazuh.gpg
  echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
    > /etc/apt/sources.list.d/wazuh.list
  apt-get update -y
  WAZUH_MANAGER="$WAZUH_MANAGER" apt-get install -y "wazuh-agent=${WAZUH_VERSION}*"
fi

systemctl daemon-reload
systemctl enable --now wazuh-agent

# --- FIM (File Integrity Monitoring) Tuning For Lab Use ---
# The Default Config Only Watches System Dirs Like /etc, /bin, /sbin.
# Add /var/www/html (Our Defacement Target) And Shorten The Scan
# Interval So Exercises Don't Require Waiting Up To 12 Hours.
AGENT_CONF="/var/ossec/etc/ossec.conf"
if ! grep -q "/var/www/html" "$AGENT_CONF"; then
  sed -i 's#<directories>/etc,/usr/bin,/usr/sbin</directories>#<directories>/etc,/usr/bin,/usr/sbin</directories>\n    <directories realtime="yes">/var/www/html</directories>#' "$AGENT_CONF"
  sed -i 's#<frequency>43200</frequency>#<frequency>120</frequency>#' "$AGENT_CONF"
  systemctl restart wazuh-agent
fi

echo "Agent Installed And Pointed At ${WAZUH_MANAGER}."