#!/usr/bin/env bash
# Installs Wazuh (Manager + Indexer + Dashboard) On One Host.
set -euo pipefail

WAZUH_VERSION="${WAZUH_VERSION:-4.14}"
CREDS_FILE="/vagrant/wazuh-credentials.txt"   # Gitignored; Appears In The Repo Folder On Your Host

if systemctl is-active --quiet wazuh-dashboard 2>/dev/null; then
  echo "Wazuh Already Installed, Skipping."
  exit 0
fi

cd /tmp
curl -sO "https://packages.wazuh.com/${WAZUH_VERSION}/wazuh-install.sh"
bash ./wazuh-install.sh -a 2>&1 | tee /tmp/wazuh-install.log

# Save The Generated Admin Credentials So You Can Log In (File Is Gitignored).
grep -A3 "Summary" /tmp/wazuh-install.log > "$CREDS_FILE" || true
tar -O -xf /tmp/wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt >> "$CREDS_FILE" 2>/dev/null || true

echo "Done. Open https://192.168.56.10 In Your Host Browser."