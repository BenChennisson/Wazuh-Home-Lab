# Cybersecurity Home Lab: Wazuh SIEM On VirtualBox

A small, reproducible detection lab built to learn SIEM fundamentals. One command builds a
Wazuh SIEM, a monitored Linux endpoint, and an optional Kali attacker, all on a private
host-only network. Made to run on 16 GB RAM.

## Architecture

```
              Host-Only Network 192.168.56.0/24
  ┌────────────┐       ┌──────────────┐       ┌─────────────┐
  │ wazuh  .10 │ ◄──── │ endpoint .11 │ ◄──── │ kali    .12 │
  │ SIEM, 6 GB │       │ Victim, 1 GB │       │ 2 GB (Opt.) │
  └────────────┘       └──────────────┘       └─────────────┘
```

| VM | Role | RAM |
|---|---|---|
| wazuh | Wazuh Manager, Indexer And Dashboard | 6 GB |
| endpoint | Ubuntu With SSH And Apache, Runs The Wazuh Agent | 1 GB |
| kali | Attacker, Started On Demand | 2 GB |

## Prerequisites

- VirtualBox 7.x
- [Vagrant](https://developer.hashicorp.com/vagrant/install)
- x86_64 Host, About 12 GB Free RAM And 40 GB Free Disk

## Quick Start

```
git clone <This Repo>
cd cyber-home-lab
vagrant up wazuh endpoint # First Run Takes About 15-25 Min
```

Then browse to https://192.168.56.10 (accept the warning).
Credentials are saved to `wazuh-credentials.txt` (gitignored).

Start the attacker when you need it with `vagrant up kali`.

## Exercises

1. [SSH Brute Force](exercises/ssh-brute.md)
2. [Port Scan And FIM](exercises/port-scan.md)

Both write-ups include what actually went wrong along the way as this lab was tested.

## Safety

This lab intentionally contains weak credentials. It runs only on a host-only network.
Never expose these VMs to a real network.

## Roadmap

- Windows Endpoint With Sysmon
- Custom Detection Rules
- Active Response (Auto Block Attacker IP)