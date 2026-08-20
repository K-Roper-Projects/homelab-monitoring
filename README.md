# HomeLab Monitoring Stack

## Overview

This project was created to gain hands-on experience with infrastructure monitoring, Linux administration, containerisation, cloud deployment and observability tooling.

The project began as a locally hosted monitoring platform running on an Ubuntu virtual machine and was later extended into a cloud-hosted deployment on AWS EC2.

The monitoring stack is deployed using Docker Compose and consists of:

* Prometheus
* Grafana
* Node Exporter
* Blackbox Exporter

Prometheus is used to collect and store metrics, Grafana provides dashboards and visualisation, Node Exporter collects host-level infrastructure metrics, and Blackbox Exporter is used to monitor service availability and network connectivity.

The same Docker Compose deployment is used across both the HomeLab and AWS environments. Environment-specific Prometheus configuration files are used to define the appropriate monitoring targets for each platform.

Grafana Alerting and SMTP email notifications were also implemented to provide proactive monitoring and automated incident notification.

The primary goal of the project was to design, deploy, troubleshoot and document a complete monitoring solution while gaining practical experience with technologies commonly used within cloud, infrastructure, platform engineering and DevOps environments.

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
docker ps
```

Access the services:

| Service | Default Port |
|----------|--------------|
| Grafana | 3000 |
| Prometheus | 9090 |
| Node Exporter | 9100 |
| Blackbox Exporter | 9115 |

In the local HomeLab environment, Grafana and Prometheus can be accessed using:

```text
http://localhost:3000
http://localhost:9090
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

---

## Environment

### Phase 1 Environment

#### Host Environment

* Windows 11
* Oracle VirtualBox

#### Virtual Machine

* Ubuntu Desktop

### Phase 2 Environment

#### Cloud Environment

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

### HomeLab Network Equipment

* Zyxel NR5103E 5G Router

---

## Architecture

### HomeLab

```text
Windows Host
    │
Ubuntu VM
    │
Docker Compose
├── Prometheus
├── Grafana
├── Node Exporter
└── Blackbox Exporter
    │
Local Network / Router
    │
Internet
```

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

Metrics include:

* Router availability
* Internet availability
* Router response time
* Internet response time
* Historical latency trends
* Service reachability

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

Grafana Alerting was configured to provide automated email notifications when predefined monitoring thresholds are exceeded.

Alert notifications are delivered via SMTP using a dedicated project email account.

Configured HomeLab alert rules include:

### Network Alerts

* Internet Connectivity Lost
* Router Unreachable
* High Internet Latency
* High Router Latency

Alerts are evaluated periodically and generate email notifications when alert conditions remain active beyond the configured pending period.

This provides proactive monitoring rather than relying solely on dashboard visualisation.

---

## Monitoring Targets

### HomeLab Infrastructure

| Target | Purpose |
|--------|---------|
| Ubuntu VM | Host performance and resource utilisation |
| Docker Containers | Monitoring services running within the VM |

### HomeLab Network

| Target | Purpose |
|--------|---------|
| Local Router | Availability and latency monitoring |
| Cloudflare DNS (1.1.1.1) | Internet connectivity monitoring |
| Google DNS (8.8.8.8) | Internet connectivity monitoring |

### AWS Deployment

| Target | Purpose |
|--------|---------|
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

---

## Security

Several security controls are used within the project:

* SSH key-based authentication
* AWS IAM user administration
* AWS Security Groups
* Restricted inbound access
* Environment variables for application credentials
* `.env` excluded from Git source control
* Google App Password used for Grafana SMTP authentication
* No application secrets stored directly in `docker-compose.yml`

AWS Security Group rules restrict administrative and monitoring access rather than exposing management services unnecessarily to the public internet.

---

## Key Skills Demonstrated

This project provided practical experience with:

* Linux administration
* Docker container management
* Docker Compose deployment
* Prometheus configuration
* Grafana dashboard creation
* Metrics collection and analysis
* Network monitoring concepts
* Git version control
* GitHub repository management
* SSH authentication and key management
* Troubleshooting containerised applications
* Grafana alerting configuration
* Email notification integration
* Docker persistent storage management
* Infrastructure monitoring and alerting
* AWS EC2 deployment
* Amazon EBS storage
* IAM administration
* Security Group configuration
* Cloud infrastructure monitoring
* Cloud-hosted observability platforms
* Service availability monitoring
* EC2 troubleshooting
* Docker deployment in AWS
* Environment-specific configuration
* Secret management using environment variables

---

## Challenges Encountered

During the build and migration process several issues were encountered and resolved, including:

* Docker repository configuration issues
* Docker daemon and socket troubleshooting
* Container networking conflicts
* Docker permission management
* Prometheus target configuration
* Grafana datasource connectivity issues
* GitHub SSH authentication setup
* Grafana persistent storage configuration
* Recovery from container recreation without persistent volumes
* SMTP integration and email alert configuration
* EC2 SSH connectivity troubleshooting
* Security Group configuration and validation
* GitHub authentication from AWS EC2
* Dynamic public IP management
* Docker deployment in cloud environments
* Prometheus target migration from HomeLab to AWS
* Grafana dashboard recreation following migration
* Node Exporter host filesystem configuration
* Separating HomeLab and AWS monitoring targets
* Restoring SSH access following replacement of the original SSH key
* Recovering and validating the AWS monitoring environment after an extended shutdown
* Updating the EC2 operating system and AWS kernel
* Preserving Grafana dashboards using persistent Docker storage

Resolving these issues provided practical experience with troubleshooting Linux, container-based and cloud-hosted environments.

---

## Screenshots

### Infrastructure Dashboard

<img width="1834" height="852" alt="Infrastructure Dash" src="https://github.com/user-attachments/assets/e98c0848-613c-4e0d-9460-7aa1b4b838d5" />

### Network Health Dashboard

<img width="1920" height="955" alt="Network Dash" src="https://github.com/user-attachments/assets/28ca5893-4a17-41c0-abed-c07fe6a9469b" />

### EC2 Monitoring Dashboard

<img width="1590" height="546" alt="EC2 Dash" src="https://github.com/K-Roper-Projects/homelab-monitoring/blob/main/Screenshots/AWS-Stack/EC2%20Overview%20Dashboard.png" />

### AWS Website Monitoring Dashboard

<img width="1650" height="545" alt="AWS Web Dash" src="https://github.com/K-Roper-Projects/homelab-monitoring/blob/main/Screenshots/AWS-Stack/AWS%20Website%20Dashboard.png" />

### Docker Container Monitoring Dashboard

<img width="1602" height="679" alt="Docker Dash" src="https://github.com/K-Roper-Projects/homelab-monitoring/blob/main/Screenshots/AWS-Stack/Docker%20Container%20Monitoring%20Dashboard.png" />

---

## Lessons Learned

This project highlighted the importance of persistent storage when deploying stateful applications within containers.

During development, Grafana dashboards were lost following container recreation due to the absence of a persistent Docker volume. The issue was diagnosed and resolved by configuring a dedicated Docker volume mapped to `/var/lib/grafana`.

The migration from a local HomeLab environment to AWS also highlighted the importance of separating environment-specific configuration from the application deployment itself.

The HomeLab environment requires monitoring targets such as the local router and external DNS services, whereas the AWS environment monitors cloud-hosted services and external HTTP endpoints.

Separating these into dedicated Prometheus configuration files allows the same Docker Compose stack to be reused without manually modifying monitoring targets for each environment.

Additional experience was gained configuring SMTP integration, automated alert notifications, SSH access, AWS Security Groups, persistent storage and cloud-hosted Docker services.

These challenges provided practical experience with troubleshooting, data persistence, configuration management and operational monitoring concepts.

---

## Future Improvements

Planned enhancements include:

* Infrastructure as Code using Terraform
* Automated EC2 provisioning
* Automated operating system bootstrap and initial patching
* Automated Docker installation and configuration
* Automated deployment of the monitoring stack
* Improved secrets management
* Automated Grafana dashboard provisioning
* cAdvisor container monitoring
* Monitoring additional Linux hosts
* AWS CloudWatch integration
* CI/CD deployment pipelines
* Further Grafana alerting and reporting
* Infrastructure recovery and repeatable deployment testing

---

## Repository Structure

```text
homelab-monitoring/
├── docker-compose.yml
├── prometheus/
│   ├── homelab.yml
│   └── aws.yml
├── Screenshots/
├── README.md
├── .gitignore
└── .env                 # Local only - excluded from Git
```

The repository contains the common Docker Compose deployment and environment-specific Prometheus configurations.

Secrets and deployment-specific values are maintained locally through `.env` and are not committed to source control.

---

## Current Development Phase

The project has now entered **Phase 3 - Infrastructure as Code using Terraform**.

The aim of this phase is to move from infrastructure that was originally created manually through the AWS Management Console toward a repeatable, version-controlled deployment.

The existing working AWS deployment will be used as the reference architecture while the Terraform configuration is developed and tested.

### Terraform Milestone 1 - Project Initialisation

The initial Terraform development environment has been established.

Completed work includes:

* Terraform installed and configured on the local development machine
* AWS CLI installed
* Short-lived AWS authentication configured using browser-based AWS login
* Existing IAM user and MFA authentication retained
* Initial Terraform project structure created
* Terraform version requirements defined
* HashiCorp AWS provider configured
* AWS region configured for `us-east-1`
* AWS provider dependency constrained to the 6.x release family
* Provider dependency lock file generated
* Local Terraform working files excluded from Git source control
* Terraform state files excluded from Git source control
* Terraform formatting established using `terraform fmt`
* Terraform configuration successfully validated using `terraform validate`

Current Terraform project structure:

```text
Terraform/
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
└── .terraform.lock.hcl
---

## Author

This project was developed as part of a personal learning programme focused on infrastructure, cloud technologies and observability tooling.
