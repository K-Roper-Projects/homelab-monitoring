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
- Automatic recovery of remote-access and monitoring services following a VM reboot.

The implementation was divided into three remote-access phases, followed by additional reliability validation:

1. Remote access to the Windows host.
2. Direct remote administration of the Ubuntu HomeLab VM.
3. Direct access to the monitoring platform.
4. Automatic monitoring-stack recovery following VM reboot.

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
             ├──── HTTP ──────────────────> Grafana
             │
             └──── HTTP ──────────────────> Prometheus
```

Tailscale handles connectivity between the devices without requiring inbound connections to be exposed through the HomeLab Internet router.

---

# Remote Access Phase 1 - Windows Host

## Requirement

The first phase provided remote graphical access to the Windows 11 laptop hosting the HomeLab environment.

The laptop runs Windows 11 Home, which cannot act as a Microsoft Remote Desktop host.

RustDesk was therefore selected to provide graphical remote administration.

## Tailscale Installation

Tailscale was installed on:

- Windows 11 HomeLab host.
- Samsung Galaxy S25 FE mobile device.

Both devices were authenticated using the same MFA-protected identity.

Tailscale device approval was enabled to provide an additional layer of control over devices joining the private network.

Once connected, each device received a private Tailscale IP address within the `100.x.x.x` address range.

## RustDesk

RustDesk was installed on both the Windows host and Android mobile device.

The Windows RustDesk configuration was secured using:

- A strong permanent password.
- Permanent-password authentication.
- Direct IP connectivity.
- Tailscale as the underlying network path.

Rather than connecting using the public RustDesk ID infrastructure, the mobile client connects directly to the Windows host using its private Tailscale IP address.

```text
Galaxy S25 FE
      │
      ▼
Tailscale
      │
      ▼
Windows Host
      │
      ▼
RustDesk
```

This allows graphical remote administration without forwarding RustDesk ports through the Virgin Media router.

---

# Windows Power Management

Remote access to the Windows host depends on the laptop remaining powered and reachable.

The host supports Modern Standby rather than traditional S3 sleep.

Investigation using:

```powershell
powercfg /a
```

confirmed support for:

```text
Standby (S0 Low Power Idle) Network Connected
Hibernate
Fast Startup
```

Traditional S1, S2 and S3 sleep states were unavailable.

Wake-capable devices were also investigated using:

```powershell
powercfg /devicequery wake_armed
```

The Intel Wi-Fi adapter was not presented as a conventional wake-capable device.

Additional investigation of the Intel Wi-Fi 6E AX211 adapter confirmed support for several Wake-on-WLAN related features, including:

- Wake on Magic Packet.
- Wake on Pattern Match.
- ARP offload.
- NS offload.
- GTK rekeying.

However, testing showed that placing the laptop into Modern Standby caused Tailscale connectivity to disappear.

Reliable remote Wake-on-WLAN could therefore not be established.

## Decision

When the HomeLab is intended to remain remotely accessible, the Windows host is configured to remain awake while connected to mains power.

The display may turn off independently without affecting remote connectivity.

This provides a predictable remote-access path rather than relying on unsupported or unreliable Wake-on-WLAN behaviour.

---

# Remote Access Phase 1 Validation

Remote Windows access was tested successfully using:

- Local Wi-Fi.
- Mobile data.
- Tailscale private addressing.
- RustDesk direct IP connectivity.

No public Internet port forwarding was required.

The validated connection path is:

```text
Galaxy S25 FE
      │
      ▼
Mobile Data / Wi-Fi
      │
      ▼
Tailscale
      │
      ▼
Windows 11 Host
      │
      ▼
RustDesk
```

---

# Remote Access Phase 2 - Ubuntu HomeLab VM

The second phase removed the requirement to access the Windows desktop before administering the Ubuntu VM.

Tailscale was installed directly on the Ubuntu HomeLab VM.

The VM then became an independent member of the private Tailscale network.

The resulting Tailscale network contains:

```text
Windows Host
Ubuntu HomeLab VM
Galaxy S25 FE
```

Tailscale connectivity testing demonstrated both relay and direct connectivity.

Initial communication could use a Tailscale DERP relay while direct connectivity was being established.

Subsequent testing demonstrated direct peer-to-peer communication where network conditions allowed it.

Tailscale automatically selects the most appropriate available path.

---

# SSH Access

OpenSSH was enabled on the Ubuntu VM.

Validation confirmed that SSH was listening on:

```text
0.0.0.0:22
[::]:22
```

The mobile device can therefore connect directly to the VM using:

```text
Host: <HOMELAB_TAILSCALE_IP>
Port: 22
User: kevin
```

The connection path is:

```text
Galaxy S25 FE
      │
      ▼
Tailscale
      │
      ▼
Ubuntu HomeLab VM
      │
      ▼
OpenSSH :22
```

No TCP port 22 forwarding is configured on the Internet router.

This allows command-line administration of the VM without first connecting to the Windows desktop.

---

# Reboot Recovery

For remote administration to be reliable, both Tailscale and OpenSSH need to recover automatically after an Ubuntu reboot.

Validation confirmed:

```bash
systemctl is-enabled tailscaled
systemctl is-enabled ssh
```

Both services were enabled.

The Ubuntu VM was then rebooted remotely.

A standard reboot request was initially blocked by the active GNOME graphical session inhibitor. The reboot was subsequently performed deliberately using systemd while ignoring the desktop inhibitor.

Following the reboot:

- Ubuntu restarted successfully.
- Tailscale started automatically.
- OpenSSH started automatically.
- The VM reappeared on the Tailscale network.
- SSH access was restored without local intervention.

This demonstrated that remote command-line administration can recover following a full VM restart.

---

# Remote Access Phase 3 - Monitoring Platform

The third phase extended Tailscale access directly to the monitoring services running on the Ubuntu VM.

The monitoring stack consists of:

```text
Grafana
Prometheus
Node Exporter
Blackbox Exporter
```

The services are deployed using Docker Compose.

---

# Grafana Remote Access

Grafana publishes TCP port `3000` from the Ubuntu VM.

When connected to Tailscale, Grafana can be accessed using:

```text
http://<HOMELAB_TAILSCALE_IP>:3000
```

The Grafana interface was successfully accessed from the Galaxy S25 FE using Chrome while connected through Tailscale.

The connection path is:

```text
Galaxy S25 FE
      │
      ▼
Tailscale
      │
      ▼
Ubuntu HomeLab VM
      │
      ▼
Grafana :3000
```

This does not require:

- Windows desktop access.
- RustDesk.
- SSH tunnelling.
- Public port forwarding.

Grafana authentication remains enabled, providing application-level authentication in addition to Tailscale network access.

---

# Prometheus Remote Access

Prometheus publishes TCP port `9090`.

The Prometheus interface can therefore be accessed through Tailscale using:

```text
http://<HOMELAB_TAILSCALE_IP>:9090
```

The `/targets` page was successfully accessed remotely from the mobile device.

This provides a useful diagnostic interface when troubleshooting monitoring targets remotely.

The validated targets included:

- Prometheus.
- Node Exporter.
- Router ICMP monitoring.
- Internet ICMP monitoring.

Prometheus remains primarily an administrative and troubleshooting interface rather than a general user-facing service.

---

# Docker Monitoring Stack Recovery

Following implementation of remote access, recovery of the complete monitoring platform after a VM restart was tested.

The Docker Compose configuration was updated so that all monitoring services use:

```yaml
restart: unless-stopped
```

The policy is configured for:

- Prometheus.
- Grafana.
- Node Exporter.
- Blackbox Exporter.

The monitoring stack was started and verified using:

```bash
docker compose up -d
docker compose ps
```

The Ubuntu VM was then fully rebooted.

After the VM returned, remote SSH access was restored through Tailscale and the Docker environment was checked without manually starting the monitoring stack.

Validation using:

```bash
docker ps
```

confirmed that all four containers had recovered automatically:

```text
prometheus          Up
grafana             Up
blackbox-exporter   Up
node-exporter       Up
```

No manual `docker compose up -d` command was required following the reboot.

This validated the complete recovery path:

```text
Ubuntu VM Boot
      │
      ├── Tailscale
      │      └── Remote network access restored
      │
      ├── OpenSSH
      │      └── Remote administration restored
      │
      └── Docker
             │
             └── Container restart policies
                    │
                    ├── Prometheus
                    ├── Grafana
                    ├── Node Exporter
                    └── Blackbox Exporter
```

The HomeLab monitoring platform can therefore recover automatically following a normal Ubuntu VM restart without requiring manual intervention inside the VM.

---

# Network Migration

During development of the remote-access functionality, the HomeLab Internet connection was migrated from Three UK broadband to Virgin Fibre Broadband.

The previous network gateway was:

```text
192.168.1.1
```

The Virgin Media network introduced a new gateway:

```text
192.168.0.1
```

The HomeLab Prometheus configuration was updated accordingly.

The router monitoring target in:

```text
prometheus/homelab.yml
```

was changed to:

```text
192.168.0.1
```

Prometheus was then restarted and the `/targets` page confirmed that the new gateway was successfully being monitored through Blackbox Exporter.

---

# Alerting Issue Following Gateway Migration

Following the gateway change, the Grafana Network Health dashboard correctly showed the new router as available.

However, the existing `Router Unreachable` alert reported:

```text
DatasourceNoData
```

Investigation confirmed that:

- Prometheus was correctly monitoring `192.168.0.1`.
- The Grafana dashboard was correctly displaying router availability.
- The Prometheus target was `UP`.

The issue was isolated to the Grafana alert rule.

The alert contained its own Prometheus query which still referenced:

```text
instance="192.168.1.1"
```

The alert query was updated to:

```text
instance="192.168.0.1"
```

Following the change, the alert returned to:

```text
Health = ok
```

## Future Improvement

The alert could later be changed to use the Prometheus job label:

```promql
job="router-ping"
```

rather than referencing a specific gateway IP address.

This would reduce configuration changes if the HomeLab gateway changes again.

---

# Grafana Administrative Recovery

During remote-access testing, the Grafana administrator password was unavailable.

Email-based password recovery was investigated but no reset email was received.

Because administrative access to the Ubuntu VM was available through SSH, Grafana's command-line administration interface was used instead.

The available Grafana CLI commands were confirmed using:

```bash
docker exec -it grafana grafana cli --help
```

The administrator password was then reset using the Grafana CLI.

The reset preserved:

- Existing dashboards.
- Grafana configuration.
- Monitoring data sources.
- Alerting configuration.

No Grafana data needed to be recreated.

Credentials are not stored in the project documentation or Git repository.

---

# VirtualBox Clipboard Recovery

Following an Ubuntu VM reboot, bidirectional clipboard functionality between the Windows host and Ubuntu guest stopped working.

VirtualBox Guest Additions processes were investigated using:

```bash
ps aux | grep -E 'VBoxClient|VBoxService' | grep -v grep
```

`VBoxService` and the VirtualBox graphical session process were running, but the clipboard client was absent.

The installed Guest Additions version was confirmed using:

```bash
VBoxClient --version
```

Clipboard integration was restored manually using:

```bash
VBoxClient --clipboard
```

Bidirectional clipboard functionality immediately returned.

This demonstrated that Guest Additions remained operational and that the problem was limited to the clipboard client failing to start automatically with the desktop session.

Automatic startup of the clipboard client remains a possible future improvement.

---

# Security Model

The remote-access design avoids exposing administrative services directly to the public Internet.

No inbound router port forwarding is configured for:

```text
SSH        :22
Grafana    :3000
Prometheus :9090
RustDesk
```

Remote access instead requires the connecting device to be an authorised member of the private Tailscale network.

---

# Security Layers

The remote-access architecture uses multiple security layers:

| Layer | Protection |
|---|---|
| Identity | MFA-protected account authentication |
| Device | Tailscale device approval |
| Network | Tailscale private encrypted network |
| Transport | WireGuard encryption |
| Windows Remote Access | RustDesk authentication |
| Ubuntu Administration | SSH authentication |
| Grafana | Grafana user authentication |
| Internet Router | No management-service port forwarding |

A device therefore requires both authorised Tailscale access and the appropriate service-level credentials.

---

# Problems Encountered

## Windows Sleep Behaviour

Modern Standby caused Tailscale connectivity to disappear while the Windows host was sleeping.

Wake-on-WLAN could not be made sufficiently reliable for unattended remote access.

### Resolution

The Windows host remains awake while the HomeLab is expected to be remotely available.

---

## Ubuntu Reboot Inhibitor

A remote reboot request was blocked because the active GNOME desktop session had registered a systemd inhibitor.

### Resolution

The inhibitor was identified and the planned reboot test was completed using systemd's option to ignore active inhibitors.

The reboot itself completed successfully and all required remote-access services recovered.

---

## Monitoring Containers Did Not Originally Share a Restart Policy

The initial Docker Compose configuration did not apply a restart policy consistently across all monitoring containers.

This meant recovery of the complete monitoring stack after a VM restart had not been guaranteed.

### Resolution

`restart: unless-stopped` was applied to:

- Prometheus.
- Grafana.
- Node Exporter.
- Blackbox Exporter.

A complete VM reboot was performed and all four monitoring containers recovered automatically without running `docker compose up -d` manually.

---

## VirtualBox Clipboard

The VirtualBox clipboard client did not automatically restart following an Ubuntu reboot.

### Resolution

Clipboard functionality was restored using:

```bash
VBoxClient --clipboard
```

---

## Grafana Password

The Grafana administrator password was unavailable and email password recovery was not operational.

### Resolution

The password was reset using the Grafana CLI from within the running container.

---

## Router Monitoring

The HomeLab router address changed following migration to Virgin Fibre Broadband.

### Resolution

The Prometheus router target was updated from:

```text
192.168.1.1
```

to:

```text
192.168.0.1
```

---

## Grafana Router Alert

The Grafana alert continued querying the previous router IP after the Prometheus configuration had been updated.

### Resolution

The independent alert query was corrected to use the new gateway address.

---

# Validation

The completed remote-access and recovery solution has been tested across the following scenarios:

| Test | Result |
|---|---|
| Windows remote access over local Wi-Fi | Pass |
| Windows remote access over mobile data | Pass |
| RustDesk direct connection through Tailscale | Pass |
| Ubuntu SSH access through Tailscale | Pass |
| Tailscale direct peer connectivity | Pass |
| Tailscale DERP fallback | Pass |
| SSH recovery after Ubuntu reboot | Pass |
| Tailscale recovery after Ubuntu reboot | Pass |
| Docker service recovery after Ubuntu reboot | Pass |
| Prometheus recovery after Ubuntu reboot | Pass |
| Grafana recovery after Ubuntu reboot | Pass |
| Node Exporter recovery after Ubuntu reboot | Pass |
| Blackbox Exporter recovery after Ubuntu reboot | Pass |
| Grafana access through Tailscale | Pass |
| Prometheus access through Tailscale | Pass |
| Prometheus target validation | Pass |
| Router monitoring after gateway migration | Pass |
| Grafana router alert after gateway migration | Pass |
| Public router port forwarding required | No |

---

# Final Access Paths

## Windows Administration

```text
Galaxy S25 FE
      │
      ▼
Tailscale
      │
      ▼
Windows Host
      │
      ▼
RustDesk
```

## Ubuntu Administration

```text
Galaxy S25 FE
      │
      ▼
Tailscale
      │
      ▼
Ubuntu HomeLab VM
      │
      ▼
SSH :22
```

## Grafana

```text
Galaxy S25 FE
      │
      ▼
Tailscale
      │
      ▼
Ubuntu HomeLab VM
      │
      ▼
Grafana :3000
```

## Prometheus

```text
Galaxy S25 FE
      │
      ▼
Tailscale
      │
      ▼
Ubuntu HomeLab VM
      │
      ▼
Prometheus :9090
```

---

# Current State

The secure remote-access implementation is operational.

The HomeLab can currently be administered remotely through:

- RustDesk for Windows graphical administration.
- SSH for Ubuntu command-line administration.
- Grafana through a mobile web browser.
- Prometheus through a mobile web browser.

Tailscale and OpenSSH have been validated to recover automatically following an Ubuntu VM reboot.

Docker Compose restart policies are configured for all monitoring services. Following a full Ubuntu VM reboot, Docker, Prometheus, Grafana, Node Exporter and Blackbox Exporter recovered automatically without manual intervention.

The monitoring platform therefore recovers automatically after an Ubuntu VM reboot once the VM itself has started.

No management ports are forwarded through the HomeLab Internet router.

---

# Known Limitations

## Windows Host Availability

The Windows host must remain powered on and awake for the HomeLab VM to remain available.

Reliable Wake-on-WLAN has not been established.

## VirtualBox Host Dependency

The Ubuntu HomeLab environment remains dependent on the Windows laptop and VirtualBox.

If the physical host is powered off, the VM and monitoring platform are unavailable.

Automatic startup of the VirtualBox VM following a Windows host restart has not yet been implemented or validated.

## Prometheus Exposure

Prometheus currently publishes port `9090` on all VM interfaces.

Although the port is not forwarded through the Internet router, Prometheus is therefore reachable from networks capable of reaching the VM.

Prometheus could later be restricted further if direct browser troubleshooting access is no longer required.

## SSH Authentication

SSH password authentication is currently used for remote administration.

SSH key authentication could later be introduced and password authentication disabled after successful validation.

## VirtualBox Clipboard

The VirtualBox clipboard client has previously failed to start automatically following an Ubuntu reboot.

Manual recovery has been validated, but persistent automatic startup has not yet been implemented.

---

# Future Improvements

Potential future improvements include:

- Configure SSH key-based authentication.
- Disable SSH password authentication after key authentication has been validated.
- Introduce more restrictive Tailscale ACLs if additional devices or users are added.
- Restrict Grafana and Prometheus network bindings where appropriate.
- Replace the hard-coded router IP in the Grafana alert rule with the `router-ping` job label.
- Configure persistent VirtualBox clipboard-client startup.
- Investigate automatic startup of the HomeLab VM following a Windows host reboot.
- Review Windows host power-management options as the HomeLab evolves.
- Introduce automated Ubuntu security-update management.
- Monitor pending operating-system reboot requirements.
- Consider monitoring Docker container health and restart behaviour through Prometheus/Grafana.

---

# Technologies Used

| Technology | Purpose |
|---|---|
| Tailscale | Private encrypted remote-access network |
| WireGuard | Underlying encrypted Tailscale transport |
| RustDesk | Windows graphical remote administration |
| OpenSSH | Ubuntu remote command-line administration |
| Docker | Container runtime |
| Docker Compose | Monitoring stack deployment and restart policy |
| Prometheus | Metrics collection and monitoring |
| Grafana | Dashboards and alerting |
| Node Exporter | Linux host metrics |
| Blackbox Exporter | Network and service availability monitoring |
| VirtualBox | HomeLab VM platform |
| Git | Version control |
| GitHub | Remote repository and project documentation |

---

# Outcome

The HomeLab Monitoring Platform can now be securely administered remotely without exposing management services directly to the public Internet.

Tailscale provides private encrypted connectivity between the authorised devices, RustDesk provides graphical Windows administration, and OpenSSH provides direct Ubuntu administration.

Grafana and Prometheus are directly accessible through the private Tailscale network, allowing monitoring and troubleshooting from a mobile device without requiring access to the Windows desktop.

The reliability of the platform has also been improved by applying Docker Compose restart policies to all monitoring containers.

A complete Ubuntu VM reboot test demonstrated automatic recovery of:

```text
Tailscale
OpenSSH
Docker
Prometheus
Grafana
Node Exporter
Blackbox Exporter
```

This provides a secure and increasingly resilient remote-management architecture while maintaining the project's principle of avoiding unnecessary public exposure of administrative services.