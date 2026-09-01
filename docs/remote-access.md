# HomeLab Secure Remote Access

## Overview

The HomeLab monitoring environment was originally designed to run locally on an Ubuntu virtual machine hosted by a Windows 11 laptop.

During the early stages of the project, the Ubuntu VM was only started when development or testing work was being carried out. Administration therefore depended on direct access to the Windows laptop and its local VirtualBox environment.

As the HomeLab developed into a more permanent monitoring platform, this became limiting.

The environment was therefore extended to support secure remote administration from a mobile device without exposing management services directly to the public Internet.

The completed solution provides:

* Remote graphical access to the Windows 11 host
* Direct SSH administration of the Ubuntu HomeLab VM
* Direct access to Grafana
* Direct access to Prometheus
* Private connectivity between the laptop, VM and mobile device
* Remote recovery following an Ubuntu VM reboot
* Access over both Wi-Fi and mobile networks
* No router port forwarding for management services

Tailscale was selected as the underlying private network technology.

RustDesk was used for graphical Windows administration, while OpenSSH provides direct command-line access to the Ubuntu VM.

---

## Design Goals

The remote-access solution was designed around several requirements.

### Secure Remote Connectivity

Remote management needed to work when away from the HomeLab network without exposing services such as:

```text
SSH        :22
Grafana    :3000
Prometheus :9090
RustDesk
```

directly to the Internet.

### Minimal Router Configuration

The solution should not require:

* Static public IP addressing
* Dynamic DNS
* NAT port forwarding
* Publicly exposed management ports

### Multiple Administration Paths

Two separate administration methods were required:

```text
Remote Device
     │
     ├── Graphical administration of Windows
     │
     └── Direct administration of Ubuntu
```

This avoids making the Windows graphical desktop a dependency for routine Linux administration.

### Remote Monitoring

Grafana dashboards should be available directly from the mobile device without requiring:

```text
Mobile
  │
  ▼
RustDesk
  │
  ▼
Windows
  │
  ▼
Browser
  │
  ▼
Grafana
```

Instead, the target architecture was:

```text
Mobile
  │
  ▼
Tailscale
  │
  ▼
HomeLab VM
  │
  ▼
Grafana
```

### Recovery After Reboot

The HomeLab VM needed to recover remote connectivity automatically after reboot.

The critical services were therefore:

```text
tailscaled
ssh
```

Both needed to start automatically with Ubuntu.

---

## Final Architecture

The implemented architecture provides two independent remote administration paths.

```text
                         Remote Administration Device
                                  Galaxy S25 FE
                                       │
                          Wi-Fi / 4G / 5G Internet
                                       │
                                   Tailscale
                                       │
                    ┌──────────────────┴──────────────────┐
                    │                                     │
                    ▼                                     ▼
             Windows 11 Laptop                    Ubuntu HomeLab VM
                    │                                     │
                 RustDesk                    ┌────────────┼────────────┐
                                             │            │            │
                                            SSH        Grafana     Prometheus
                                            :22         :3000        :9090
                                                            │
                                                       Docker Compose
                                               ┌────────────┼────────────┐
                                               │            │            │
                                          Prometheus     Grafana     Exporters
                                               │
                                          Local Network
                                               │
                                         Virgin Gateway
                                               │
                                            Internet
```

Tailscale provides private connectivity between:

* Windows 11 host
* Ubuntu HomeLab VM
* Samsung Galaxy S25 FE

No management services are exposed using Internet router port forwarding.

---

# Phase 1 - Remote Windows Access

## Objective

The first phase focused on gaining remote graphical access to the Windows laptop hosting the HomeLab VM.

The Windows system runs:

```text
Windows 11 Home
```

Windows 11 Home cannot act as a Microsoft Remote Desktop host, so an alternative remote desktop solution was required.

RustDesk was selected.

Tailscale was used as the private network path so that RustDesk did not need to be exposed directly to the Internet.

---

## Windows Host

### Hardware

The HomeLab laptop is:

```text
ASUS Vivobook
Model: Vivobook_AsusLaptop K3502ZA
```

The laptop normally connects to the HomeLab network using Wi-Fi.

The wireless adapter is:

```text
Intel(R) Wi-Fi 6E AX211 160MHz
```

---

## Tailscale Installation on Windows

Tailscale was installed on the Windows 11 laptop.

The device was authenticated using the same identity used for the wider private Tailscale network.

Additional account protection was already present through MFA on the identity provider.

Tailscale device approval was also enabled.

This means newly authenticated devices must be approved before becoming trusted members of the private network.

---

## Mobile Tailscale Installation

Tailscale was also installed on the Samsung Galaxy S25 FE.

The phone was authenticated into the same private network as the Windows laptop.

Once connected, the laptop received a stable private Tailscale address from the:

```text
100.x.x.x
```

address range.

The phone could therefore reach the laptop without requiring public addressing or router port forwarding.

---

## Windows Power Behaviour Investigation

For remote access to remain available, the laptop must remain reachable.

This required investigating whether the laptop could be woken remotely over Wi-Fi.

The system supports Modern Standby rather than traditional ACPI S3 sleep.

The command:

```powershell
powercfg /a
```

showed support for:

```text
Standby (S0 Low Power Idle) Network Connected
Hibernate
Fast Startup
```

Traditional sleep states were unavailable:

```text
S1
S2
S3
Hybrid Sleep
```

---

## Wake-Capable Devices

The following command was used:

```powershell
powercfg /devicequery wake_armed
```

The Wi-Fi adapter was not listed as an armed wake device.

Wake-capable devices included devices such as:

* USB4 root routers
* Fingerprint reader
* HID keyboard
* HID mouse

The Intel Wi-Fi adapter therefore could not be relied upon to wake the laptop remotely.

---

## Intel AX211 WoWLAN Settings

The Intel AX211 adapter exposed several Wake-on-Wireless-LAN related options, including:

* ARP offload
* NS offload
* GTK rekeying
* Sleep on WoWLAN Disconnect
* Wake on Magic Packet
* Wake on Pattern Match

Power-management state was checked using:

```powershell
Get-NetAdapterPowerManagement -Name "WiFi"
```

The adapter reported:

```text
ArpOffload                Enabled
NSOffload                 Enabled
RsnRekeyOffload           Enabled
D0PacketCoalescing        Enabled
SelectiveSuspend          Unsupported
DeviceSleepOnDisconnect   Disabled
WakeOnMagicPacket         Enabled
WakeOnPattern             Enabled
```

Despite these settings, the adapter did not appear under:

```powershell
powercfg /devicequery wake_armed
```

and the laptop disconnected from Tailscale when placed into sleep.

This showed that Wake-on-WLAN could not be considered reliable for this configuration.

---

## BIOS Investigation

The ASUS BIOS was reviewed for any additional wake-related options.

Available configuration areas included:

* VMD setup
* Thunderbolt Configuration
* Graphics Configuration
* USB Configuration
* Network Stack Configuration
* Intel Rapid Storage Technology
* ASUS Firmware Update
* Intel Virtualization Technology
* VT-d
* Hyper-Threading
* Intel AES-NI

The Network Stack configuration only exposed a network boot option.

No explicit Wake-on-LAN, Wake-on-WLAN or equivalent power-management setting was found.

---

## Resulting Power Strategy

Because the laptop cannot be reliably woken remotely over Wi-Fi, the design does not depend on sleep recovery.

For reliable remote access, the laptop should remain powered and connected while acting as the HomeLab host.

The preferred behaviour while plugged in is therefore:

* Allow the display to turn off
* Prevent the laptop from entering sleep
* Keep Windows and Tailscale running
* Keep the VirtualBox HomeLab VM available

This approach prioritises remote availability over aggressive power saving.

---

## RustDesk Installation

RustDesk was installed on the Windows laptop.

The x86-64 Windows build was used.

RustDesk security settings were unlocked and configured for unattended access.

A strong permanent RustDesk password was configured.

RustDesk was configured to accept sessions using the permanent password.

Permissions available to the remote session included functionality such as:

* Keyboard and mouse control
* Clipboard
* File transfer
* Audio
* Remote restart
* Terminal
* TCP tunnelling
* Privacy mode

The exact permission set can be adjusted depending on administration requirements.

---

## RustDesk on Android

RustDesk was also installed on the Samsung Galaxy S25 FE.

At the time of configuration, the required Android application was installed manually rather than through Google Play.

The correct mobile architecture was:

```text
AArch64 / ARM64
```

This matched the Galaxy S25 FE hardware.

---

## RustDesk Direct IP Access

RustDesk direct IP access was enabled on the Windows host.

Rather than connecting using the public Internet or relying on RustDesk relay addressing, the mobile application connects using the laptop's private Tailscale IP.

Example:

```text
100.x.x.x
```

This creates the effective connection path:

```text
Galaxy S25 FE
     │
     ▼
4G / 5G / Wi-Fi
     │
     ▼
Tailscale
     │
     ▼
Windows Tailscale IP
     │
     ▼
RustDesk
```

No RustDesk port forwarding is configured on the Virgin router.

---

## Phase 1 Validation

The remote graphical connection was tested from:

* Home Wi-Fi
* Mobile network connectivity

Both successfully established RustDesk access to the Windows desktop through the private Tailscale network.

This confirmed that remote Windows administration did not depend on being connected to the local HomeLab LAN.

### Phase 1 Result

```text
Remote Windows GUI Access: COMPLETE
```

---

# Phase 2 - Direct Ubuntu HomeLab Access

## Objective

After Windows remote access was working, the next objective was to remove the Windows desktop from routine HomeLab administration.

The original path was:

```text
Mobile
  │
  ▼
Tailscale
  │
  ▼
Windows
  │
  ▼
RustDesk
  │
  ▼
VirtualBox
  │
  ▼
Ubuntu HomeLab VM
```

This worked but was unnecessarily indirect.

The preferred path was:

```text
Mobile
  │
  ▼
Tailscale
  │
  ▼
Ubuntu HomeLab VM
  │
  ▼
SSH
```

---

## Tailscale Installation on Ubuntu

Tailscale was installed directly onto the Ubuntu HomeLab VM.

The standard Linux installation method was used and the VM was authenticated into the existing Tailscale network.

Once authenticated, the tailnet contained three active systems:

```text
Windows laptop
Ubuntu HomeLab VM
Galaxy S25 FE
```

The Ubuntu VM received its own private:

```text
100.x.x.x
```

Tailscale address.

This address is independent from the VM's normal VirtualBox or local LAN address.

---

## Tailscale Connectivity Testing

Connectivity was tested using:

```bash
tailscale status
```

and:

```bash
tailscale ping <device>
```

---

## Ubuntu to Mobile Test

Initial connectivity from the HomeLab VM to the mobile device used a Tailscale relay path:

```text
DERP(lhr)
```

The first observed latency was higher, followed by lower values as the connection stabilised.

A direct peer-to-peer path was then successfully established to the mobile device using its reachable network endpoint.

This demonstrated Tailscale's normal connection behaviour:

1. Establish encrypted connectivity immediately
2. Use DERP relay if necessary
3. Attempt to establish a direct peer-to-peer connection
4. Move to the direct path when available

---

## Ubuntu to Windows Test

A Tailscale ping from the VM to the Windows laptop established a direct local path.

The result showed traffic using the laptop's private local network address on Tailscale's UDP port.

Example path:

```text
via 192.168.0.x:41641
```

with very low local latency.

This demonstrated that when both devices are on the same network, Tailscale can establish an efficient direct path without routing the connection across the wider Internet.

---

## SSH Service Verification

OpenSSH Server was already installed on the Ubuntu HomeLab VM.

The service was checked using:

```bash
systemctl status ssh
```

The service reported:

```text
active (running)
```

The SSH server was also configured to start automatically.

Port listening state was verified using:

```bash
sudo ss -tlnp | grep ':22'
```

The system showed SSH listening on:

```text
0.0.0.0:22
[::]:22
```

This confirmed that the SSH daemon was available to the VM's network interfaces, including the Tailscale interface.

---

## Mobile SSH Client

A mobile SSH client was configured on the Galaxy S25 FE.

The connection used:

```text
Host: HomeLab Tailscale IP
Port: 22
Username: kevin
Authentication: Ubuntu user credentials
```

The connection was established directly through Tailscale.

A successful login showed the connection originating from the phone's own private Tailscale address.

This verified the complete path:

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
OpenSSH
```

No Windows or RustDesk session was required.

---

## Automatic Service Startup

The two critical services were checked using:

```bash
systemctl is-enabled tailscaled
systemctl is-enabled ssh
```

Both returned:

```text
enabled
```

This indicated that the HomeLab should recover remote-management capability following a normal operating-system reboot.

---

## Remote Reboot Validation

The Ubuntu VM was rebooted remotely through the SSH session.

An initial attempt using:

```bash
reboot
```

as the normal user failed because the operation required interactive authorization.

The system returned an error indicating that the requested reboot required interactive authentication.

The correct remote command was:

```bash
sudo reboot
```

The SSH session disconnected immediately as expected while the VM restarted.

---

## Post-Reboot Recovery

Following the reboot:

1. Ubuntu started successfully
2. Networking initialized
3. `tailscaled` started automatically
4. The HomeLab VM rejoined the Tailscale network
5. `ssh` started automatically
6. The mobile SSH client successfully reconnected

System uptime was checked using:

```bash
uptime
```

and confirmed that the VM had only recently restarted.

The running kernel was checked using:

```bash
uname -r
```

which confirmed the updated kernel after the Ubuntu package upgrade.

This demonstrated successful end-to-end recovery without local interaction.

### Phase 2 Result

```text
Direct Remote Ubuntu Administration: COMPLETE
```

---

# Phase 3 - Remote Monitoring Access

## Objective

With Tailscale running directly on the Ubuntu VM, the monitoring services could also be reached through the private network.

The objective was to access Grafana and Prometheus directly from the mobile device.

---

## Docker Monitoring Stack

The HomeLab monitoring stack runs using Docker Compose.

The expected containers are:

```text
grafana
prometheus
node-exporter
blackbox-exporter
```

Because the HomeLab VM had previously only been run when required, the monitoring containers were not configured as permanently running services.

After bringing the VM back online, the stack was manually started.

The stack can be started using:

```bash
docker compose up -d
```

Container state can be checked using:

```bash
docker compose ps
```

and:

```bash
docker ps
```

---

## Service Bindings

The running containers showed Grafana exposed on:

```text
0.0.0.0:3000
```

and Prometheus exposed on:

```text
0.0.0.0:9090
```

This meant both services were reachable through the Ubuntu VM's Tailscale interface.

---

## Grafana Remote Access

Grafana was opened directly from Chrome on the Galaxy S25 FE using:

```text
http://<HOMELAB_TAILSCALE_IP>:3000
```

The Grafana login page loaded successfully over the mobile network.

This confirmed:

```text
Galaxy
  │
  ▼
Tailscale
  │
  ▼
HomeLab VM
  │
  ▼
Grafana :3000
```

No RustDesk connection or SSH tunnel was required.

---

## Grafana Credential Recovery

The original Grafana administrator password was no longer known.

Grafana password-reset email was attempted, but no email was received.

The likely reason was that Grafana's standard email-based password recovery path was not configured for this local administrative scenario.

Because direct SSH administration of the Grafana Docker host was available, the password was reset using the Grafana CLI inside the running container.

CLI capability was first confirmed with:

```bash
docker exec -it grafana grafana cli --help
```

The administrator password was then reset using:

```bash
docker exec -it grafana grafana cli admin reset-admin-password 'NEW-PASSWORD'
```

The password was successfully changed.

Grafana login from the Galaxy was then successful.

Existing dashboards were still present, confirming that persistent Grafana storage remained intact.

---

## Prometheus Remote Access

Prometheus was accessed directly through:

```text
http://<HOMELAB_TAILSCALE_IP>:9090
```

The Prometheus Targets page was available at:

```text
http://<HOMELAB_TAILSCALE_IP>:9090/targets
```

This provides remote access to scrape status and monitoring-target health.

---

# HomeLab Network Change

## Background

The HomeLab Internet connection had changed since the original monitoring configuration was created.

The previous broadband connection used a router with the address:

```text
192.168.1.1
```

The current Virgin gateway uses:

```text
192.168.0.1
```

The Network Health dashboard therefore initially contained incorrect router-monitoring data.

---

## Prometheus Configuration

The HomeLab-specific Prometheus configuration is stored in:

```text
prometheus/homelab.yml
```

The router target was changed from:

```text
192.168.1.1
```

to:

```text
192.168.0.1
```

Prometheus was restarted using:

```bash
docker compose restart prometheus
```

The Prometheus Targets page was then checked remotely.

The router target showed:

```text
UP
```

with:

```text
instance="192.168.0.1"
```

This confirmed that Blackbox Exporter was successfully monitoring the Virgin gateway.

---

## Grafana Dashboard Validation

The Grafana Network Health dashboard contained six panels:

* Internet Status
* Router Status
* Internet Latency
* Router Latency
* Internet History
* Router History

After correcting the Prometheus target, the dashboard refreshed and displayed the correct gateway address and current monitoring data.

---

# Grafana Alert Validation

## Real Router Failure Alert

The router-address change created an unexpected but useful real-world test of Grafana alerting.

Grafana detected that the previously configured router target:

```text
192.168.1.1
```

was unreachable.

An email notification was generated indicating the router failure.

After correcting the monitoring target, Grafana later generated a resolved notification.

This provided end-to-end confirmation that:

```text
Prometheus
    │
    ▼
Blackbox Exporter
    │
    ▼
Grafana Alert Rule
    │
    ▼
SMTP
    │
    ▼
Project Email Account
```

was operating correctly.

---

## DatasourceNoData Alerts

Further email notifications were received with the alert state:

```text
DatasourceNoData
```

Prometheus was healthy and the Network Health dashboard was displaying the correct gateway, so the monitoring target itself was not the problem.

The Grafana alert rule was inspected.

The rule still referenced the previous router IP:

```text
192.168.1.1
```

The rule was updated to:

```text
192.168.0.1
```

Following the change, Grafana reported:

```text
Health = OK
```

This demonstrated an important configuration distinction:

```text
Prometheus Target
      │
      ├── Grafana Dashboard Query
      │
      └── Grafana Alert Query
```

Changing a Prometheus target does not automatically rewrite Grafana alert-rule queries.

Each layer must therefore be reviewed when monitoring targets change.

---

# Security Model

## No Public Port Forwarding

The HomeLab Internet router does not expose management services through inbound port forwarding.

The following ports are not deliberately forwarded from the Internet:

```text
22    SSH
3000  Grafana
9090  Prometheus
RustDesk management traffic
```

Remote connectivity is instead provided through Tailscale.

---

## Tailscale

Tailscale provides the private network linking:

* Windows host
* Ubuntu HomeLab VM
* Galaxy S25 FE

The design benefits from:

* WireGuard-based encrypted transport
* Device authentication
* Stable private device addressing
* Direct peer-to-peer connections where available
* Encrypted DERP relay fallback when direct connectivity is unavailable
* No requirement for static public IP addresses
* No requirement for inbound NAT rules

---

## Device Approval

Tailscale device approval is enabled.

This adds an additional trust step for newly authenticated devices before they are allowed to participate normally in the private network.

---

## Identity Security

The identity account used to authenticate Tailscale is protected using MFA.

This provides protection at the identity layer in addition to device-level Tailscale authentication.

---

## RustDesk Security

RustDesk unattended access is protected using a strong permanent password.

Direct IP access is used across the private Tailscale network rather than exposing the Windows host directly to the public Internet.

---

## Grafana Security

Grafana authentication remains enabled even though the service is only accessed through the private Tailscale network.

This means access requires both:

1. Tailscale network access
2. Grafana application authentication

---

# Operational Behaviour

## Windows Host Availability

The Windows laptop must remain powered and awake for remote access to remain available.

Wake-on-WLAN testing showed that the Wi-Fi adapter could not be relied upon to wake the system remotely.

The HomeLab host should therefore remain awake while plugged in when persistent remote availability is required.

---

## Ubuntu VM Availability

The Ubuntu VM must be running for:

* SSH
* Grafana
* Prometheus
* Node Exporter
* Blackbox Exporter

to remain remotely available.

Tailscale and SSH automatically recover following an Ubuntu reboot.

---

## Docker Monitoring Stack

At the time of this implementation, the Docker monitoring stack is started manually using:

```bash
docker compose up -d
```

Automatic Docker Compose recovery following VM reboot has not yet been fully implemented and validated.

This remains a future improvement.

---

# Troubleshooting

## Tailscale Device Not Visible

Check service state:

```bash
systemctl status tailscaled
```

Check tailnet status:

```bash
tailscale status
```

Test another device:

```bash
tailscale ping <device>
```

---

## SSH Not Available

Check SSH:

```bash
systemctl status ssh
```

Confirm port 22 is listening:

```bash
sudo ss -tlnp | grep ':22'
```

Confirm both required services are enabled:

```bash
systemctl is-enabled tailscaled
systemctl is-enabled ssh
```

---

## Cannot Reboot Ubuntu Remotely

Running:

```bash
reboot
```

as a standard SSH user may fail because interactive authorization is unavailable.

Use:

```bash
sudo reboot
```

instead.

---

## Grafana Unavailable

Check the Docker stack:

```bash
docker compose ps
```

Check running containers:

```bash
docker ps
```

Check Grafana logs:

```bash
docker logs grafana --tail 50
```

Expected remote address:

```text
http://<HOMELAB_TAILSCALE_IP>:3000
```

---

## Forgotten Grafana Administrator Password

Confirm the Grafana CLI:

```bash
docker exec -it grafana grafana cli --help
```

Reset the administrator password:

```bash
docker exec -it grafana grafana cli admin reset-admin-password 'NEW-PASSWORD'
```

A password containing `!` can be safely passed when surrounded by single quotes, provided the password itself does not contain a single quote.

---

## Prometheus Unavailable

Check:

```bash
docker compose ps
```

Then open:

```text
http://<HOMELAB_TAILSCALE_IP>:9090
```

For scrape-target state:

```text
http://<HOMELAB_TAILSCALE_IP>:9090/targets
```

---

## Router Target Down

Check:

```text
prometheus/homelab.yml
```

Confirm the configured gateway matches the current HomeLab network.

After changing the target:

```bash
docker compose restart prometheus
```

Then confirm the target reports:

```text
UP
```

---

## DatasourceNoData Alert

If Grafana generates:

```text
DatasourceNoData
```

while the dashboard appears healthy, check each layer separately.

1. Confirm the Prometheus target is UP.
2. Confirm the dashboard is querying the correct target.
3. Open the Grafana alert rule.
4. Confirm the alert query references the current target.

A stale hard-coded address in an alert query can cause `DatasourceNoData` even when the monitoring dashboard itself is correct.

---

# Validation Summary

## Phase 1

```text
Galaxy S25 FE
     │
     ▼
Tailscale
     │
     ▼
Windows Laptop
     │
     ▼
RustDesk

Status: COMPLETE
```

Validated over:

* Wi-Fi
* Mobile network

---

## Phase 2

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
SSH

Status: COMPLETE
```

Validated through:

* Direct SSH login
* Tailscale peer connectivity
* VM reboot
* Automatic Tailscale restart
* Automatic SSH restart
* Successful post-reboot reconnection

---

## Phase 3

```text
Galaxy S25 FE
     │
     ▼
Tailscale
     │
     ▼
Ubuntu HomeLab VM
     │
     ├── Grafana :3000
     └── Prometheus :9090

Status: COMPLETE
```

Validated through:

* Grafana mobile access
* Grafana authentication
* Persistent dashboard recovery
* Prometheus mobile access
* Prometheus target inspection
* Router target correction
* Network Health dashboard recovery
* Grafana alert and resolved email notifications

---

# Current Status

The HomeLab now supports secure remote administration without requiring publicly exposed management services.

The completed access paths are:

```text
Galaxy
   │
   ├── Tailscale ──► Windows ──► RustDesk
   │
   └── Tailscale ──► HomeLab
                         │
                         ├── SSH
                         ├── Grafana
                         └── Prometheus
```

Remote Access Phases 1, 2 and 3 are complete.

---

# Future Improvements

Potential improvements include:

* Configure Docker Compose restart policies
* Validate automatic Grafana and Prometheus recovery after VM reboot
* Move mobile SSH authentication from password to SSH keys
* Review whether SSH should be restricted specifically to the Tailscale interface
* Review whether Grafana and Prometheus should bind only to required interfaces
* Introduce Tailscale ACLs if the tailnet expands to additional users or devices
* Add monitoring of Tailscale service health
* Add monitoring of Docker container availability
* Add monitoring of the Windows HomeLab host
* Add a remote operations dashboard
* Document HomeLab disaster-recovery procedures