# Cybersecurity Home Lab: Wazuh SIEM + Linux Endpoint + Kali Attacker
# Requires: VirtualBox + Vagrant On An x86_64 Host.
#
#   vagrant up wazuh endpoint   # Core Lab (About 7 GB RAM)
#   vagrant up kali             # Start The Attacker Only When Needed
#   vagrant halt                # Stop Everything
#   vagrant destroy -f          # Delete The Lab Entirely

WAZUH_VERSION = "4.14"          # Pinned So The Lab Stays Reproducible
WAZUH_IP      = "192.168.56.10"
ENDPOINT_IP   = "192.168.56.11"
KALI_IP       = "192.168.56.12"

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false

  # --- SIEM Server (Manager + Indexer + Dashboard, All-in-One) ---
  config.vm.define "wazuh" do |m|
    m.vm.box = "bento/ubuntu-22.04"
    m.vm.hostname = "wazuh"
    m.vm.network "private_network", ip: WAZUH_IP
    m.vm.provider "virtualbox" do |vb|
      vb.name   = "lab-wazuh"
      vb.memory = 6144
      vb.cpus   = 2
    end
    m.vm.provision "shell", path: "provision/wazuh-server.sh",
      env: { "WAZUH_VERSION" => WAZUH_VERSION }
  end

  # --- Monitored Linux Endpoint (Victim) ---
  config.vm.define "endpoint" do |m|
    m.vm.box = "bento/ubuntu-22.04"
    m.vm.hostname = "endpoint"
    m.vm.network "private_network", ip: ENDPOINT_IP
    m.vm.provider "virtualbox" do |vb|
      vb.name   = "lab-endpoint"
      vb.memory = 1024
      vb.cpus   = 1
    end
    m.vm.provision "shell", path: "provision/agent.sh",
      env: { "WAZUH_VERSION" => WAZUH_VERSION, "WAZUH_MANAGER" => WAZUH_IP }
  end

  # --- Attacker (Not Started By A Plain `vagrant up`) ---
  config.vm.define "kali", autostart: false do |m|
    m.vm.box = "kalilinux/rolling"
    m.vm.hostname = "kali"
    m.vm.network "private_network", ip: KALI_IP
    m.vm.provider "virtualbox" do |vb|
      vb.name   = "lab-kali"
      vb.memory = 2048
      vb.cpus   = 2
    end
  end
end