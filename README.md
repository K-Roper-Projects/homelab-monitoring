# HomeLab Monitoring Stack

## Overview

This project was created to gain hands-on experience with infrastructure monitoring, Linux administration, containerisation, cloud deployment, Infrastructure as Code, secure remote administration and observability tooling.

The project began as a locally hosted monitoring platform running on an Ubuntu virtual machine and was later extended into a cloud-hosted deployment on AWS EC2.

The monitoring stack is deployed using Docker Compose and consists of:

* Prometheus
* Grafana
* Node Exporter
* Blackbox Exporter

Prometheus is used to collect and store metrics, Grafana provides dashboards and visualisation, Node Exporter collects host-level infrastructure metrics, and Blackbox Exporter is used to monitor service availability and network connectivity.

The same Docker Compose deployment is used across both the HomeLab and AWS environments. Environment-specific Prometheus configuration files define the appropriate monitoring targets for each platform.

Grafana Alerting and SMTP email notifications provide proactive monitoring and automated incident notification.

The project has subsequently been extended with:

* AWS cloud deployment
* Infrastructure as Code using Terraform
* Automated EC2 bootstrap using cloud-init
* Secure remote administration using Tailscale
* Remote Windows administration using RustDesk
* Direct SSH administration of the HomeLab VM
* Remote Grafana and Prometheus access

The primary goal of the project is to design, deploy, troubleshoot and document a complete monitoring solution while gaining practical experience with technologies and working practices commonly used within cloud, infrastructure, platform engineering and DevOps environments.

---

## Project Evolution

### Phase 1 - HomeLab Monitoring

The project initially focused on building a monitoring platform within a HomeLab environment using an Ubuntu virtual machine hosted on Oracle VirtualBox.

The monitoring stack was deployed using Docker Compose and configured to monitor:

* Ubuntu virtual machine health
* CPU utilisation
* Memory utilisation
* Disk utilisation
* System uptime
* Router availability
* Internet connectivity
* Network latency

Additional functionality included:

* Grafana Alerting
* SMTP email notifications
* Persistent Docker volumes
* GitHub source control
* SSH authentication

The HomeLab deployment provided practical experience with Linux administration, containerisation, observability tooling and infrastructure monitoring concepts.

### Phase 2 - AWS Cloud Deployment

Following successful completion of the HomeLab deployment, the monitoring platform was migrated to AWS EC2 to gain practical cloud deployment experience.

The AWS deployment introduced:

* Amazon EC2
* Amazon EBS persistent storage
* AWS IAM
* Security Groups
* AWS Budgets
* Cloud-hosted monitoring services
* Service availability monitoring
* Infrastructure monitoring
* Docker service monitoring
* Secure remote administration using SSH

The existing Docker-based monitoring stack was deployed onto an Ubuntu Server EC2 instance while retaining Prometheus, Grafana, Node Exporter and Blackbox Exporter as the core monitoring components.

The AWS environment uses a dedicated Prometheus configuration containing targets appropriate to the cloud deployment rather than the local HomeLab network.

Three dedicated Grafana dashboards were developed for the AWS environment.

#### EC2 Monitoring Dashboard

Provides visibility into:

* CPU utilisation
* Memory utilisation
* Disk utilisation
* Network throughput
* System load
* System uptime

#### AWS Website Monitoring Dashboard

Uses Blackbox Exporter to monitor:

* AWS website availability
* AWS website response time
* Historical service availability
* External endpoint monitoring

Target monitored:

```text
https://aws.amazon.com
```

#### Docker Container Monitoring Dashboard

Monitors:

* Grafana service availability
* Prometheus service availability
* Service response times
* Historical service uptime

The Grafana and Prometheus containers are monitored internally across the Docker Compose network using their Docker service names.

For example:

```text
http://grafana:3000
http://prometheus:9090
```

This avoids relying on the dynamically assigned EC2 public IP for internal service monitoring.

The AWS deployment demonstrates practical experience with cloud infrastructure, Linux server administration, Docker deployment, monitoring platform migration and cloud-based observability tooling.

### Phase 3 - Infrastructure as Code with Terraform

Following the manual AWS deployment, the infrastructure was recreated using Terraform to introduce Infrastructure as Code (IaC) and provide a repeatable, version-controlled deployment process.

The Terraform configuration provisions the underlying AWS infrastructure required by the monitoring platform, including:

* Dedicated VPC
* Public subnet
* Internet Gateway
* Route table and subnet association
* Security Group and individual ingress/egress rules
* EC2 instance
* Encrypted gp3 EBS root storage
* Configurable SSH and monitoring access
* Terraform outputs for deployed resource identifiers and public IP addresses

Terraform variables are used to separate reusable infrastructure definitions from deployment-specific values such as the AWS region, Availability Zone, EC2 instance type, AMI, SSH key pair and trusted CIDR ranges.

Deployment-specific values are stored in a local `terraform.tfvars` file which is excluded from Git source control. A `terraform.tfvars.example` file is included to document the values required for a deployment.

Terraform state is also excluded from Git source control. Local state is currently used while developing and learning the Terraform workflow, with remote state planned as a future enhancement.

The Terraform deployment lifecycle was successfully tested using:

```text
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

The complete AWS infrastructure was successfully created, validated and subsequently destroyed using Terraform.

#### Automated EC2 Bootstrap

EC2 User Data and `cloud-init` were introduced to automate the initial configuration of newly created instances.

A version-controlled bootstrap script automatically:

* Updates the Ubuntu package repositories
* Applies available operating system package updates
* Configures Docker's official Ubuntu package repository
* Installs Docker Engine
* Installs Docker Compose
* Enables and starts the Docker service
* Adds the Ubuntu user to the Docker group

The bootstrap process was tested against a newly created Ubuntu 24.04 LTS EC2 instance.

Following deployment, validation confirmed:

```text
cloud-init status: done
Docker Engine: installed
Docker Compose: installed
Docker service: active
Ubuntu user: member of docker group
```

A test container was successfully launched without `sudo`, confirming that the instance could be created from a clean AMI and automatically configured as a Docker-ready host without manual package installation.

The infrastructure was then successfully removed using `terraform destroy`, demonstrating that the Terraform environment can be treated as disposable and recreated when required.

### Phase 4 - Secure Remote HomeLab Access

The HomeLab environment was extended to support secure remote administration and monitoring without exposing management services directly to the public Internet.

Tailscale was deployed across the Windows host, Ubuntu HomeLab VM and mobile administration device to create a private encrypted network between trusted systems.

Remote access was implemented and validated in three stages.

#### Remote Access Phase 1 - Windows Host

RustDesk provides graphical remote administration of the Windows 11 host.

RustDesk direct IP connectivity is used across Tailscale, allowing the host to be remotely controlled without configuring public Internet port forwarding.

```text
Remote Device
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

Remote connectivity was successfully tested using both Wi-Fi and mobile network connections.

#### Remote Access Phase 2 - Ubuntu HomeLab VM

Tailscale was installed directly on the Ubuntu HomeLab VM.

OpenSSH provides direct command-line administration of the VM through its private Tailscale address.

```text
Remote Device
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

Tailscale and OpenSSH are configured to start automatically with Ubuntu.

Remote recovery was validated by rebooting the VM entirely through an SSH connection. Following reboot, Tailscale and SSH automatically restarted and remote connectivity was restored without local intervention.

#### Remote Access Phase 3 - Monitoring Platform

The private Tailscale network also provides direct remote access to the HomeLab monitoring services.

```text
Remote Device
     │
     ▼
Tailscale
     │
     ▼
Ubuntu HomeLab VM
     │
     ├── SSH        :22
     ├── Grafana    :3000
     └── Prometheus :9090
```

Grafana dashboards and the Prometheus management interface were successfully accessed remotely from a mobile device without requiring:

* Windows desktop access
* RustDesk
* SSH tunnelling
* Public Internet port forwarding

No inbound port forwarding is configured on the HomeLab Internet router for SSH, Grafana, Prometheus or RustDesk.

Detailed implementation, validation, security and troubleshooting information is documented in:

[`docs/remote-access.md`](docs/remote-access.md)

---

## Environment-Specific Configuration

The project supports both the original HomeLab deployment and the AWS EC2 deployment using the same Docker Compose configuration.

Prometheus configuration files are stored separately:

```text
prometheus/
├── homelab.yml
└── aws.yml
```

The required configuration is selected using the `PROMETHEUS_CONFIG` environment variable.

### HomeLab

The HomeLab deployment uses:

```text
PROMETHEUS_CONFIG=./prometheus/homelab.yml
```

This configuration monitors:

* Prometheus
* Node Exporter
* Local router availability
* Cloudflare DNS
* Google DNS
* Internet connectivity
* Network latency

### AWS

The AWS EC2 deployment uses:

```text
PROMETHEUS_CONFIG=./prometheus/aws.yml
```

This configuration monitors:

* Prometheus
* Node Exporter
* Grafana service availability
* Prometheus service availability
* AWS website availability
* HTTP response times

Docker Compose reads the selected Prometheus configuration using:

```yaml
- ${PROMETHEUS_CONFIG:-./prometheus/homelab.yml}:/etc/prometheus/prometheus.yml
```

If `PROMETHEUS_CONFIG` is not defined, the HomeLab configuration is used as the default.

This allows the same Docker Compose file to be used in multiple environments without manually editing the Compose configuration between deployments.

---

## Terraform Project Structure

The AWS Infrastructure as Code configuration is stored separately from the monitoring application configuration:

```text
Terraform/
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── variables.tf
├── versions.tf
└── scripts/
    └── bootstrap.sh
```

---

## Environment Variables

Environment-specific settings and credentials are stored in a local `.env` file.

Example:

```text
PROMETHEUS_CONFIG=./prometheus/aws.yml
SMTP_USER=<SMTP_USERNAME>
SMTP_PASSWORD=<SMTP_APP_PASSWORD>
```

The `.env` file is excluded from Git source control using `.gitignore`.

Credentials and secrets should never be committed to the repository.

Grafana SMTP authentication uses a Google App Password rather than the primary Google account password.

---

## Quick Start

Clone the repository:

```bash
git clone git@github.com:K-Roper-Projects/homelab-monitoring.git
cd homelab-monitoring
```

Create a local `.env` file and select the appropriate Prometheus configuration.

For HomeLab:

```text
PROMETHEUS_CONFIG=./prometheus/homelab.yml
```

For AWS:

```text
PROMETHEUS_CONFIG=./prometheus/aws.yml
```

Add the required SMTP configuration if email alerting is being used.

Start the monitoring stack:

```bash
docker compose up -d
```

Check container status:

```bash
docker compose ps
```

The expected monitoring services are:

| Service | Default Port |
|---|---:|
| Grafana | 3000 |
| Prometheus | 9090 |
| Node Exporter | 9100 |
| Blackbox Exporter | 9115 |

In the local HomeLab environment, Grafana and Prometheus can be accessed locally using:

```text
http://localhost:3000
http://localhost:9090
```

When connected to the private Tailscale network, the HomeLab services can also be accessed remotely using the VM's Tailscale address:

```text
http://<HOMELAB_TAILSCALE_IP>:3000
http://<HOMELAB_TAILSCALE_IP>:9090
```

In AWS, Grafana and Prometheus are accessed using the current EC2 public IP where permitted by the configured Security Group.

---

## Project Objectives

* Deploy a monitoring stack using Docker Compose
* Configure Prometheus to collect infrastructure and network metrics
* Build Grafana dashboards for visualisation and analysis
* Monitor Linux system health and performance
* Monitor network availability and latency
* Manage project configuration using Git and GitHub
* Gain practical experience with Linux, Docker and observability tooling
* Implement monitoring alerting and email notifications
* Configure persistent Docker storage for monitoring services
* Deploy and operate a monitoring platform on AWS EC2
* Monitor cloud infrastructure and containerised services
* Configure secure remote administration using SSH
* Implement cloud-hosted monitoring dashboards
* Support multiple deployment environments from a common codebase
* Separate environment-specific monitoring configuration from the core Docker deployment
* Implement Infrastructure as Code using Terraform
* Provision AWS networking, security, compute and storage using Terraform
* Separate reusable Terraform configuration from deployment-specific inputs
* Automate initial EC2 configuration using User Data and cloud-init
* Automatically install and configure Docker on newly provisioned EC2 instances
* Implement disposable AWS development infrastructure using Terraform lifecycle management
* Implement secure private remote access to the HomeLab
* Provide direct remote SSH administration of the Ubuntu VM
* Provide remote Grafana and Prometheus access
* Provide remote graphical administration of the Windows host
* Avoid exposing HomeLab management services through public Internet port forwarding
* Validate recovery of remote-management services following a VM reboot

---

## Environment

### HomeLab Environment

#### Host

* Windows 11
* Oracle VirtualBox

#### Virtual Machine

* Ubuntu Desktop
* OpenSSH
* Tailscale

#### Remote Access

* Tailscale
* RustDesk
* OpenSSH
* Mobile remote administration
* Tailscale device approval
* MFA-protected identity authentication

### AWS Environment

#### Cloud Infrastructure

* AWS EC2
* Amazon EBS
* AWS IAM
* AWS Security Groups
* AWS Budgets

#### Operating System

* Ubuntu Server

### Monitoring Stack

* Prometheus
* Grafana
* Node Exporter
* Blackbox Exporter
* Docker
* Docker Compose
* Grafana Alerting
* SMTP Email Notifications

### HomeLab Network

* Virgin Fibre Broadband
* Local router/gateway
* Tailscale private remote-access network

### Infrastructure as Code

* Terraform
* HashiCorp AWS Provider
* HCL
* Terraform variables and deployment-specific tfvars
* Terraform state
* EC2 User Data
* cloud-init
* Bash bootstrap scripting

### Terraform-Managed AWS Resources

* Amazon VPC
* Public subnet
* Internet Gateway
* Route table
* Security Group
* Amazon EC2
* Encrypted Amazon EBS gp3 storage

---

## Architecture

### HomeLab

```text
                      Remote Administration Device
                                  │
                              Tailscale
                                  │
                 ┌────────────────┴────────────────┐
                 │                                 │
                 ▼                                 ▼
          Windows 11 Host                  Ubuntu HomeLab VM
                 │                                 │
              RustDesk                    ┌────────┼─────────┐
                                          │        │         │
                                         SSH    Grafana  Prometheus
                                         :22     :3000     :9090
                                                    │
                                               Docker Compose
                                         ┌──────────┼──────────┐
                                         │          │          │
                                    Prometheus   Grafana    Exporters
                                         │
                                    Local Network
                                         │
                                  Internet Gateway
                                         │
                                      Internet
```

Remote management traffic is carried across the private Tailscale network.

No SSH, Grafana, Prometheus or RustDesk ports are forwarded from the Internet router.

### AWS

```text
AWS
 │
EC2 Ubuntu Server
 │
Docker Compose
├── Prometheus
├── Grafana
├── Node Exporter
└── Blackbox Exporter
 │
 ├── EC2 Host Metrics
 ├── Grafana Service Monitoring
 ├── Prometheus Service Monitoring
 └── External HTTP Monitoring
          │
          └── https://aws.amazon.com
```

Grafana data is stored using a persistent Docker volume mapped to:

```text
/var/lib/grafana
```

This allows dashboards, users and Grafana configuration to survive container recreation.

### Terraform AWS Infrastructure

```text
Terraform
    │
    ├── VPC
    │    │
    │    ├── Public Subnet
    │    ├── Internet Gateway
    │    └── Route Table
    │
    ├── Security Group
    │    ├── SSH :22
    │    ├── Grafana :3000
    │    └── Prometheus :9090
    │
    └── EC2 Ubuntu Server
             │
             ├── Encrypted gp3 EBS
             │
             └── cloud-init / User Data
                       │
                       └── bootstrap.sh
                              │
                              ├── OS updates
                              ├── Docker Engine
                              └── Docker Compose
```

---

## Dashboards

### Infrastructure Dashboard

The Infrastructure Dashboard uses Node Exporter metrics to provide visibility into the Ubuntu virtual machine.

Metrics include:

* CPU utilisation
* Memory utilisation
* Disk usage
* Network throughput
* System load
* System uptime

### Network Health Dashboard

The Network Health Dashboard uses Blackbox Exporter to monitor network availability and latency within the HomeLab environment.

The dashboard currently provides:

* Internet status
* Router status
* Internet latency
* Router latency
* Internet availability history
* Router availability history

The router and Internet targets are provided by the HomeLab-specific Prometheus configuration.

### Node Exporter Full Dashboard

The Node Exporter Full dashboard provides detailed host-level visibility using metrics collected from Node Exporter.

It provides more extensive Linux system information including CPU, memory, filesystem, networking, system load and other host metrics.

### EC2 Monitoring Dashboard

The EC2 Monitoring Dashboard provides visibility into the AWS-hosted Ubuntu server.

Metrics include:

* CPU utilisation
* Memory utilisation
* Disk utilisation
* Network throughput
* System load
* System uptime

### AWS Website Monitoring Dashboard

Blackbox Exporter performs HTTP availability checks against:

```text
https://aws.amazon.com
```

Metrics include:

* Website availability
* HTTP probe status
* Response time
* Historical availability

### Docker Container Monitoring Dashboard

Blackbox Exporter monitors the Grafana and Prometheus services across the internal Docker network.

Targets include:

```text
http://grafana:3000
http://prometheus:9090
```

Metrics include:

* Grafana availability
* Prometheus availability
* HTTP response time
* Historical service availability

---

## Alerting

Grafana Alerting provides automated email notifications when predefined monitoring thresholds are exceeded.

Alert notifications are delivered via SMTP using a dedicated project email account.

Configured HomeLab alert rules include:

### Network Alerts

* Internet Connectivity Lost
* Router Unreachable
* High Internet Latency
* High Router Latency

Alerts are evaluated periodically and generate email notifications when alert conditions remain active beyond the configured pending period.

Resolved notifications are also generated when the monitored service returns to a healthy state.

During a HomeLab network change, the alerting system detected loss of connectivity to the previously configured router and generated a real incident notification. Following correction of the Prometheus target, Grafana subsequently generated a resolved notification.

A remaining Grafana alert query was also identified as referencing the previous router address. This produced `DatasourceNoData` notifications despite the Network Health dashboard operating correctly.

Correcting the independent alert-rule query restored:

```text
Health = OK
```

This demonstrated the distinction between Prometheus target configuration, Grafana dashboard queries and Grafana alert-rule queries.

---

## Monitoring Targets

### HomeLab Infrastructure

| Target | Purpose |
|---|---|
| Ubuntu VM | Host performance and resource utilisation |
| Docker Containers | Monitoring services running within the VM |

### HomeLab Network

| Target | Purpose |
|---|---|
| Local Router | Availability and latency monitoring |
| Cloudflare DNS (1.1.1.1) | Internet connectivity monitoring |
| Google DNS (8.8.8.8) | Internet connectivity monitoring |

### AWS Deployment

| Target | Purpose |
|---|---|
| EC2 Instance | Infrastructure monitoring |
| Grafana Service | Service availability monitoring |
| Prometheus Service | Monitoring platform availability |
| AWS Website | External endpoint monitoring |

---

## Persistent Storage

Grafana uses a named Docker volume:

```text
homelab-monitoring_grafana-data
```

mounted inside the Grafana container at:

```text
/var/lib/grafana
```

This preserves:

* Grafana dashboards
* User accounts
* Datasource configuration
* Alerting configuration
* Grafana application data

The AWS EC2 instance also uses persistent EBS storage for the server filesystem.

Persistent storage became an important part of the project after an earlier container recreation resulted in the loss of Grafana dashboards before a dedicated Docker volume had been configured.

The persistence configuration was subsequently validated when the HomeLab monitoring stack was restarted after an extended period offline and the existing Grafana dashboards, users and configuration remained available.

---

## Security

Several security controls are used within the project.

### HomeLab

* Tailscale used for private remote connectivity
* WireGuard-based encrypted transport provided by Tailscale
* Tailscale device approval enabled
* MFA-protected identity authentication
* No inbound Internet port forwarding for SSH
* No inbound Internet port forwarding for Grafana
* No inbound Internet port forwarding for Prometheus
* No inbound Internet port forwarding for RustDesk
* Grafana authentication remains enabled
* RustDesk direct IP connectivity carried across Tailscale
* SSH available through the private Tailscale network
* Tailscale and SSH automatically recover following an Ubuntu VM reboot

### Application and Repository Security

* Environment variables used for application credentials
* `.env` excluded from Git source control
* Google App Password used for Grafana SMTP authentication
* No application secrets stored directly in `docker-compose.yml`
* Credentials and secrets excluded from the repository

### AWS

* SSH key-based authentication
* AWS IAM
* MFA-backed administrative authentication
* AWS Security Groups
* Restricted inbound access
* MFA-backed temporary AWS authentication used for local Terraform administration
* No AWS credentials stored within Terraform configuration
* SSH and monitoring access controlled using configurable CIDR variables
* Infrastructure security rules managed through Terraform

---

## Remote Administration

The HomeLab supports two independent remote administration methods.

### Graphical Administration

```text
Remote Device
     │
     ▼
Tailscale
     │
     ▼
Windows 11
     │
     ▼
RustDesk
```

This provides access to the complete Windows desktop and VirtualBox host environment.

### Direct HomeLab Administration

```text
Remote Device
     │
     ▼
Tailscale
     │
     ▼
Ubuntu HomeLab VM
     │
     ├── SSH :22
     ├── Grafana :3000
     └── Prometheus :9090
```

Direct access avoids the need to establish a Windows graphical session for routine HomeLab administration and monitoring.

The complete implementation is documented in:

[`docs/remote-access.md`](docs/remote-access.md)

---

## Operational Validation

The HomeLab environment has been tested through several operational scenarios.

### Remote VM Reboot

The Ubuntu VM was remotely rebooted through SSH.

Following reboot:

* Ubuntu networking recovered
* Tailscale started automatically
* The VM rejoined the private Tailscale network
* OpenSSH started automatically
* Remote SSH access was successfully restored

### Monitoring Recovery

Following startup of the Docker Compose monitoring stack:

* Grafana started successfully
* Prometheus started successfully
* Node Exporter started successfully
* Blackbox Exporter started successfully
* Persistent Grafana dashboards remained available
* Prometheus monitoring targets reported healthy

### Network Monitoring Change

Following migration to a different HomeLab Internet connection, the local gateway changed from the address used by the original monitoring configuration.

The HomeLab Prometheus target was updated and Prometheus successfully resumed router monitoring.

Grafana subsequently displayed the correct gateway data and the associated alert rule was updated to reference the current target.

### Alert Notification

Grafana SMTP alerting successfully generated:

* Router unreachable notification
* Service recovery/resolved notification

This provided a real operational validation of the monitoring and alerting pipeline.

---

## Current Status

### HomeLab

* Docker monitoring stack operational
* Prometheus operational
* Grafana operational
* Node Exporter operational
* Blackbox Exporter operational
* Network Health dashboard operational
* Node Exporter dashboard operational
* Grafana SMTP alerting operational
* Persistent Grafana storage operational
* Tailscale remote connectivity operational
* Direct SSH administration operational
* RustDesk Windows administration operational
* Direct remote Grafana access operational
* Direct remote Prometheus access operational

### AWS

* Manual AWS monitoring deployment completed
* AWS monitoring dashboards developed and tested
* Terraform infrastructure provisioning completed
* Terraform apply/destroy lifecycle validated
* EC2 bootstrap automation implemented and tested

### Remote Access

| Phase | Capability | Status |
|---|---|---|
| Phase 1 | Windows graphical administration using RustDesk over Tailscale | Complete |
| Phase 2 | Direct Ubuntu administration using SSH over Tailscale | Complete |
| Phase 3 | Direct Grafana and Prometheus access over Tailscale | Complete |

---

## Future Enhancements

Potential future improvements include:

* Configure automatic startup/restart policies for the Docker monitoring stack
* Validate full monitoring-platform recovery following a HomeLab VM reboot
* Further restrict management-service exposure to the Tailscale interface where appropriate
* Implement SSH key-based authentication for mobile HomeLab administration
* Introduce remote Terraform state
* Add Terraform state locking
* Continue improving reusable Terraform configuration
* Expand AWS deployment automation
* Introduce CI/CD validation for Terraform and monitoring configuration
* Expand alerting and service-health monitoring
* Add additional monitoring targets
* Continue developing the HomeLab as a platform for infrastructure, cloud and automation experimentation

---

## Technologies Used

### Monitoring and Observability

* Prometheus
* Grafana
* Node Exporter
* Blackbox Exporter
* Grafana Alerting
* SMTP

### Containers

* Docker
* Docker Compose

### Operating Systems

* Ubuntu Desktop
* Ubuntu Server
* Windows 11

### Cloud

* AWS EC2
* Amazon EBS
* AWS IAM
* AWS Security Groups
* AWS VPC

### Infrastructure as Code

* Terraform
* HashiCorp AWS Provider
* HCL
* cloud-init
* EC2 User Data
* Bash

### Remote Access and Administration

* Tailscale
* OpenSSH
* RustDesk

### Development and Source Control

* Git
* GitHub

---

## Repository

This repository contains the configuration and Infrastructure as Code used to build and operate the HomeLab and AWS monitoring environments.

The project is maintained as a practical learning environment and portfolio demonstration covering:

* Infrastructure monitoring
* Observability
* Linux administration
* Docker
* Networking
* AWS
* Infrastructure as Code
* Automation
* Secure remote administration
* Troubleshooting
* Operational validation
