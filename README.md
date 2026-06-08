### HomeLab Monitoring Stack

## Overview

This project was created to gain hands-on experience with infrastructure monitoring, Linux administration, containerisation, cloud deployment and observability tooling.

The project began as a locally hosted monitoring platform running on an Ubuntu virtual machine and was later extended into a cloud-hosted deployment on AWS EC2. The monitoring stack is deployed using Docker Compose and consists of Prometheus, Grafana, Node Exporter and Blackbox Exporter.

Prometheus is used to collect and store metrics, Grafana provides dashboards and visualisation, Node Exporter collects host-level infrastructure metrics, and Blackbox Exporter is used to monitor service availability and network connectivity.

The primary goal of the project was to design, deploy, troubleshoot and document a complete monitoring solution while gaining practical experience with technologies commonly used within cloud, infrastructure, platform engineering and DevOps environments.

Grafana Alerting and SMTP email notifications were also implemented to provide proactive monitoring and automated incident notification.

## Project Evolution
### Phase 1 - HomeLab Monitoring

The project initially focused on building a monitoring platform within a HomeLab environment using an Ubuntu virtual machine hosted on Oracle VirtualBox.

The monitoring stack was deployed using Docker Compose and configured to monitor:

Ubuntu virtual machine health
CPU utilisation
Memory utilisation
Disk utilisation
System uptime
Router availability
Internet connectivity
Network latency

Additional functionality included:

Grafana Alerting
SMTP email notifications
Persistent Docker volumes
GitHub source control
SSH authentication

The HomeLab deployment provided practical experience with Linux administration, containerisation, observability tooling and infrastructure monitoring concepts.

### Phase 2 - AWS Cloud Deployment

Following successful completion of the HomeLab deployment, the monitoring platform was migrated to AWS EC2 to gain practical cloud deployment experience.

The AWS deployment introduced:

Amazon EC2
AWS IAM
Security Groups
AWS Budgets
Cloud-hosted monitoring services
Service availability monitoring
Infrastructure monitoring
Docker service monitoring

Three dedicated Grafana dashboards were developed for the AWS environment:

EC2 Monitoring Dashboard

Provides visibility into:

CPU utilisation
Memory utilisation
Disk utilisation
Network throughput
System load
System uptime
AWS Website Monitoring Dashboard

Monitors:

AWS website availability
AWS website response time
Historical service availability
External endpoint monitoring

Target monitored:

https://aws.amazon.com
Docker Container Monitoring Dashboard

Monitors:

Grafana service availability
Prometheus service availability
Service response times
Historical service uptime

The AWS deployment demonstrates practical experience with cloud infrastructure, Linux server administration, Docker deployment, monitoring platform migration and cloud-based observability tooling.

## Quick Start

Clone the repository:

```bash
git clone git@github.com:YOUR-USERNAME/homelab-monitoring.git
cd homelab-monitoring
```

Start the monitoring stack:

```bash
docker compose up -d
```

Access the services:

| Service | URL |
|----------|----------|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |


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
* AWS EC2

### Network Equipment

* Zyxel NR5103E 5G Router (Three UK 5G Home Broadband)

---

## Architecture

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
Zyxel NR5103E Router
    │
Internet

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

### Alerting

Grafana Alerting was configured to provide automated email notifications when predefined monitoring thresholds are exceeded.

Alert notifications are delivered via SMTP using a dedicated project email account.

Configured alert rules include:

### Network Alerts

* Internet Connectivity Lost
* Router Unreachable
* High Internet Latency
* High Router Latency

Alerts are evaluated every minute and generate email notifications when alert conditions remain active beyond the configured pending period.

This provides proactive monitoring rather than relying solely on dashboard visualisation.

### Network Health Dashboard

The Network Health Dashboard uses Blackbox Exporter to monitor network availability and latency.

Metrics include:

* Router availability
* Internet availability
* Router response time
* Internet response time
* Historical latency trends
* Service reachability

---

## Monitoring Targets

### Infrastructure

| Target            | Purpose                                   |
| ----------------- | ----------------------------------------- |
| Ubuntu VM         | Host performance and resource utilisation |
| Docker Containers | Monitoring services running within the VM |

### Network

| Target                   | Purpose                             |
| ------------------------ | ----------------------------------- |
| Local Router             | Availability and latency monitoring |
| Cloudflare DNS (1.1.1.1) | Internet connectivity monitoring    |
| Google DNS (8.8.8.8)     | Internet connectivity monitoring    |

### AWS deployment

| Target              | Purpose
|-------------------- | -------------------------------- |
| EC2 Instance        | Infrastructure monitoring        |
| Grafana Service     | Service availability monitoring  |
| Prometheus Service  | Monitoring platform availability |
| AWS Website         | External endpoint monitoring     |

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
* IAM administration
* Security Group configuration
* Cloud infrastructure monitoring
* Cloud-hosted observability platforms
* Service availability monitoring
* EC2 troubleshooting
* Docker deployment in AWS

---

## Challenges Encountered

During the build process several issues were encountered and resolved, including:

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
* Public IP management
* Docker deployment in cloud environments
* Prometheus target migration from HomeLab to AWS
* Grafana dashboard recreation following migration
* Node Exporter host filesystem configuration

Resolving these issues provided valuable experience with troubleshooting Linux and container-based environments.

---

## Screenshots

### Infrastructure Dashboard

<img width="1834" height="852" alt="Infrastructure Dash" src="https://github.com/user-attachments/assets/e98c0848-613c-4e0d-9460-7aa1b4b838d5" />

### Network Health Dashboard

<img width="1920" height="955" alt="Network Dash" src="https://github.com/user-attachments/assets/28ca5893-4a17-41c0-abed-c07fe6a9469b" />

### EC2 Monitoring Dashboard

<img width="1590" height="546" alt="EC2 Dash" src="https://github.com/K-Roper-Projects/homelab-monitoring/blob/0ea4b11137cc1329308aa33cdbdbaba9b7ee72f4/Screenshots/AWS-Stack/EC2%20Overview%20Dashboard.png" />

### AWS Website Monitoring Dashboard

<img width="1650" height="545" alt="AWS Web Dash" src="https://github.com/K-Roper-Projects/homelab-monitoring/blob/main/Screenshots/AWS-Stack/AWS%20Website%20Dashboard.png" />

### Docker Container Monitoring Dashboard

<img width="1602" height="679" alt="Docker Dash" src="https://github.com/K-Roper-Projects/homelab-monitoring/blob/main/Screenshots/AWS-Stack/Docker%20Container%20Monitoring%20Dashboard.png" />

### Lessons Learned

This project highlighted the importance of persistent storage when deploying stateful applications within containers.

During development, Grafana dashboards were lost following container recreation due to the absence of a persistent Docker volume. The issue was diagnosed and resolved by configuring a dedicated Docker volume mapped to /var/lib/grafana.

Additional experience was gained configuring SMTP integration and automated alert notifications within Grafana.

These challenges provided practical experience with troubleshooting, data persistence and operational monitoring concepts.

---

## Future Improvements

Planned enhancements include:

* Infrastructure as Code using Terraform
* Automated Grafana dashboard provisioning
* cAdvisor container monitoring
* Monitoring additional Linux hosts
* CloudWatch integration
* CI/CD deployment pipelines

---

## Repository Structure

homelab-monitoring/
├── docker-compose.yml
├── prometheus.yml
├── aws-prometheus.yml
├── README.md
├── screenshots/
└── .gitignore

---

## Author

This project was developed as part of a personal learning programme focused on infrastructure, cloud technologies and observability tooling.

