# Secure Remote Access

## Overview

The HomeLab Monitoring Platform was originally designed to operate entirely within the local home network. Administration of the Ubuntu HomeLab VM and access to Grafana, Prometheus and the Windows host therefore required physical access to the laptop or connection to the local network.

As the platform developed, remote administration became increasingly useful for monitoring, maintenance and troubleshooting.

A secure remote-access solution was therefore introduced using Tailscale as the private network layer, with RustDesk providing Windows desktop access and SSH providing direct administration of the Ubuntu HomeLab VM.

The resulting architecture allows the HomeLab environment to be securely accessed from a mobile device without exposing administrative services directly to the public Internet.

---

# Objective

The objective of this enhancement was to provide secure remote access to the HomeLab Monitoring Platform while maintaining the security principles already established within the project.

The solution needed to provide:

- Remote graphical access to the Windows host.
- Direct SSH access to the Ubuntu HomeLab VM.
- Direct browser access to Grafana.
- Direct browser access to Prometheus for troubleshooting.
- Access from a mobile device over Wi-Fi or mobile data.
- Encrypted communications between devices.
- No public exposure of SSH, Grafana, Prometheus or RustDesk services.
- No requirement for port forwarding on the Virgin Media router.
- Automatic recovery of the remote-access services following a VM reboot.

The implementation was divided into three phases:

1. Remote access to the Windows host.
2. Direct remote administration of the Ubuntu HomeLab VM.
3. Direct access to the monitoring platform.

---

# Architecture

The final remote-access architecture uses Tailscale to create a private encrypted network between the authorised devices.

```text
                         Internet
                            │
                     Tailscale Network
                     (WireGuard based)
                            │
             ┌──────────────┼──────────────┐
             │              │              │
        Galaxy S25 FE    Windows Host   Ubuntu HomeLab VM
             │              │              │
             │          RustDesk           │
             │                             ├── SSH :22
             │                             ├── Grafana :3000
             │                             └── Prometheus :9090
             │
             ├──── RustDesk ──────────────> Windows Host
             │
             ├──── SSH ───────────────────> HomeLab VM
             │
             ├──── HTTPS/HTTP ────────────> Grafana
             │
             └──── HTTP ──────────────────> Prometheus