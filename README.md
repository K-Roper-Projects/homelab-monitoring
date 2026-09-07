# HomeLab Monitoring Platform

**AWS · Terraform · Docker · Linux · Prometheus · Grafana · Infrastructure as Code · Automation · Observability**

A multi-environment infrastructure monitoring and automation platform built across a local Linux HomeLab and AWS.

The project combines containerised monitoring, Infrastructure as Code, automated cloud provisioning, secure remote administration, operating-system maintenance monitoring and alerting to provide visibility into infrastructure and service health.

Originally developed as a locally hosted monitoring stack on an Ubuntu virtual machine, the platform has evolved into an AWS-deployable environment using Terraform and `cloud-init`, while retaining a common Docker-based monitoring architecture across both environments.

### Current Capabilities

* Containerised monitoring using Docker Compose
* Infrastructure and service monitoring with Prometheus
* Grafana dashboards and automated alerting
* AWS infrastructure provisioning using Terraform
* Automated EC2 bootstrap using `cloud-init`
* Environment-specific HomeLab and AWS monitoring configurations
* Secure remote administration using Tailscale and SSH
* Automatic monitoring-stack recovery following system reboot
* Custom Prometheus operating-system maintenance metrics
* Grafana alerting for infrastructure and maintenance conditions
* Version-controlled infrastructure and configuration

---

## Architecture

The platform uses a common Docker-based monitoring stack across both local and AWS environments.

The local HomeLab provides a persistent infrastructure environment for development, monitoring and operational testing, while Terraform can provision a separate AWS environment with the required networking, compute, storage and security configuration.

![HomeLab Monitoring Platform Architecture](docs/images/homelab-monitoring-architecture.png)

---

## Core Monitoring Stack

The monitoring platform is deployed using Docker Compose and consists of:

### Prometheus

Collects and stores infrastructure, operating-system, network and service metrics.

### Grafana

Provides dashboards, visualisation and alerting across monitored infrastructure and services.

### Node Exporter

Exposes Linux host metrics including:

* CPU utilisation
* memory utilisation
* disk utilisation
* network activity
* system load
* uptime

The Node Exporter textfile collector is also used to expose custom HomeLab maintenance metrics.

### Blackbox Exporter

Provides active availability and response-time monitoring for network and HTTP endpoints.

The same Docker Compose deployment is used across the HomeLab and AWS environments, with environment-specific Prometheus configuration defining the appropriate monitoring targets.

---

## Infrastructure as Code — AWS & Terraform

Following the original manual AWS deployment, the cloud infrastructure was rebuilt using Terraform to provide a repeatable and version-controlled deployment process.

Terraform provisions:

* Dedicated AWS VPC
* Public subnet
* Internet Gateway
* Route table and subnet association
* Security Groups
* Individual ingress and egress rules
* EC2 compute instance
* Encrypted gp3 EBS root storage
* Configurable SSH and monitoring access
* Deployment outputs including resource identifiers and public IP information

Reusable infrastructure configuration is separated from deployment-specific values using Terraform variables.

Local deployment values are stored in:

```text
terraform.tfvars
```

which is excluded from source control.

A sanitised:

```text
terraform.tfvars.example
```

documents the required configuration without exposing local values.

Terraform state and saved plan files are also excluded from Git.

### Deployment Lifecycle

The infrastructure has been successfully tested through the complete Terraform lifecycle:

```text
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

The AWS environment was successfully created, validated and subsequently destroyed using Terraform, demonstrating that the cloud infrastructure can be treated as reproducible and disposable rather than manually maintained.

---

## Automated EC2 Bootstrap

Terraform-provisioned EC2 instances use EC2 User Data and `cloud-init` to automate initial operating-system configuration.

The version-controlled bootstrap process:

* Updates Ubuntu package repositories
* Applies available operating-system package updates
* Configures Docker's official Ubuntu repository
* Installs Docker Engine
* Installs Docker Compose
* Enables and starts Docker
* Adds the Ubuntu user to the Docker group

The process was validated against a clean Ubuntu 24.04 LTS EC2 instance.

Validation confirmed:

```text
cloud-init status : done
Docker Engine     : installed
Docker Compose    : installed
Docker service    : active
Ubuntu user       : member of docker group
```

A test container was successfully launched without `sudo`, confirming that a newly provisioned EC2 instance could automatically become a Docker-ready host without manual package installation.

---

## Multi-Environment Configuration

The project supports both the original HomeLab and AWS deployments using the same Docker Compose configuration.

Environment-specific Prometheus configurations are stored separately:

```text
prometheus/
├── homelab.yml
└── aws.yml
```

The required configuration is selected using:

```text
PROMETHEUS_CONFIG
```

### HomeLab

```text
PROMETHEUS_CONFIG=./prometheus/homelab.yml
```

The HomeLab environment monitors:

* Prometheus
* Node Exporter
* local router availability
* Cloudflare DNS
* Google DNS
* Internet connectivity
* network latency
* custom operating-system maintenance metrics

### AWS

```text
PROMETHEUS_CONFIG=./prometheus/aws.yml
```

The AWS environment monitors:

* Prometheus
* Node Exporter
* Grafana availability
* Prometheus availability
* external HTTP availability
* HTTP response times

Docker Compose dynamically selects the required configuration:

```yaml
- ${PROMETHEUS_CONFIG:-./prometheus/homelab.yml}:/etc/prometheus/prometheus.yml
```

This allows a common container deployment to operate across multiple environments without manually modifying the Compose file.

---

## Reliability & Maintenance Monitoring

The platform has been extended beyond basic infrastructure monitoring to include service recovery and operating-system maintenance visibility.

### Automatic Monitoring-Stack Recovery

All monitoring containers use:

```yaml
restart: unless-stopped
```

A complete Ubuntu VM reboot was performed to validate recovery.

Following restart:

* Docker started automatically
* Prometheus recovered automatically
* Grafana recovered automatically
* Node Exporter recovered automatically
* Blackbox Exporter recovered automatically
* existing Grafana dashboards remained available
* Prometheus targets returned to a healthy state

No manual `docker compose up -d` command was required.

### Operating-System Maintenance Metrics

A custom Bash script:

```text
check-updates.sh
```

collects:

* number of pending APT package upgrades
* whether the operating system requires a reboot

The script produces custom Prometheus metrics:

```text
homelab_pending_updates
homelab_reboot_required
```

through the Node Exporter textfile collector.

A dedicated systemd service and timer:

```text
homelab-update-metrics.service
homelab-update-metrics.timer
```

refresh the metrics automatically.

The monitoring path is:

```text
Ubuntu APT State
       │
       ▼
check-updates.sh
       │
       ▼
Prometheus Textfile
       │
       ▼
Node Exporter
       │
       ▼
Prometheus
       │
       ▼
Grafana
       │
       ▼
Dashboard / Alert
```

### Maintenance Alerting

A dedicated Grafana dashboard exposes:

* pending operating-system updates
* reboot-required state

Grafana Alerting evaluates:

```promql
homelab_reboot_required > 0
```

The complete monitoring path was validated by simulating a reboot-required condition and confirming that:

1. the custom metric changed;
2. Node Exporter exposed the new value;
3. Prometheus collected it;
4. Grafana displayed the changed state;
5. the alert rule triggered;
6. the genuine operating-system state could then be restored.

This provided end-to-end validation from Linux system state through monitoring and alerting.

---

## Secure Remote Administration

The HomeLab environment uses Tailscale to provide private remote connectivity without exposing management services through public Internet port forwarding.

Tailscale is deployed across:

* Windows 11 host
* Ubuntu HomeLab VM
* remote administration device

This provides secure access to:

```text
Ubuntu VM
├── SSH        :22
├── Grafana    :3000
└── Prometheus :9090
```

OpenSSH provides direct command-line administration of the Ubuntu VM.

Remote recovery was validated by rebooting the VM entirely through SSH. Tailscale and OpenSSH automatically recovered following reboot, allowing administration to resume without local intervention.

RustDesk is also available across the private Tailscale network when graphical administration of the Windows host is required.

No inbound router port forwarding is configured for SSH, Grafana, Prometheus or RustDesk.

Detailed implementation and validation information is available in:

[`docs/remote-access.md`](docs/remote-access.md)

---

## Engineering Challenges & Solutions

### Reusing the Monitoring Stack Across Local and Cloud Environments

The HomeLab and AWS environments require different monitoring targets, but maintaining separate Docker deployments would introduce unnecessary duplication.

The platform therefore uses a common Docker Compose configuration with environment-specific Prometheus files selected through an environment variable.

This keeps the container architecture consistent while allowing each environment to define its own infrastructure and service targets.

### Moving from Manual AWS Deployment to Infrastructure as Code

The initial AWS environment was created manually to understand the required infrastructure.

Once validated, the environment was rebuilt using Terraform.

This shifted the AWS deployment from manually configured resources to a version-controlled definition covering networking, security, compute and storage.

The resulting infrastructure can be created, validated and destroyed through a repeatable Terraform workflow.

### Reducing Manual EC2 Configuration

Provisioning an EC2 instance with Terraform initially still left operating-system configuration as a manual activity.

`cloud-init` and EC2 User Data were therefore introduced to bootstrap the instance automatically.

This reduced the deployment process from:

```text
Provision infrastructure
        ↓
SSH to instance
        ↓
Manually install/configure Docker
        ↓
Deploy application
```

to:

```text
Terraform Apply
       ↓
EC2 Provisioned
       ↓
cloud-init
       ↓
Docker-ready Host
```

### Monitoring Operating-System State

Standard infrastructure metrics did not expose whether the Ubuntu host had pending updates or required a reboot.

A custom collection path was therefore developed using Bash, systemd and the Node Exporter textfile collector.

This allowed host maintenance state to become part of the same Prometheus/Grafana observability platform as infrastructure and network health.

---

## Dashboards & Monitoring

The project includes dashboards covering both local and AWS infrastructure.

### HomeLab Monitoring

Provides visibility into:

* CPU
* memory
* disk
* network activity
* system uptime
* router availability
* Internet availability
* latency
* operating-system maintenance state

### AWS EC2 Monitoring

Provides visibility into:

* CPU utilisation
* memory utilisation
* disk utilisation
* network throughput
* system load
* uptime

### Service Monitoring

Blackbox Exporter provides availability and response-time monitoring for HTTP and network targets.

Grafana and Prometheus can also be monitored internally across the Docker Compose network using Docker service names rather than relying on dynamically assigned external addresses.

### Alerting

Grafana Alerting and SMTP notifications provide proactive notification of detected infrastructure and maintenance conditions.

---

## Project Evolution

### Phase 1 — Local HomeLab Monitoring

Built the initial Ubuntu-based monitoring platform using Docker Compose, Prometheus, Grafana, Node Exporter and Blackbox Exporter.

Introduced infrastructure dashboards, network monitoring, alerting, persistent storage and Git-based source control.

### Phase 2 — AWS Cloud Deployment

Extended the platform into AWS using EC2, EBS, IAM and Security Groups.

Created cloud-specific monitoring dashboards and service-health monitoring while retaining the existing containerised architecture.

### Phase 3 — Infrastructure as Code

Rebuilt the AWS environment using Terraform.

Introduced version-controlled VPC, subnet, routing, security, compute and storage configuration together with reusable variables and outputs.

### Phase 4 — Automated Provisioning

Introduced `cloud-init` and EC2 User Data to convert newly provisioned Ubuntu EC2 instances into Docker-ready hosts automatically.

### Phase 5 — Secure Remote Administration

Implemented private remote HomeLab access using Tailscale, SSH and RustDesk without exposing management services through router port forwarding.

### Phase 6 — Reliability & Maintenance Monitoring

Introduced automatic Docker recovery, Ubuntu maintenance-state monitoring, custom Prometheus metrics, systemd automation and Grafana reboot-required alerting.

### Current Direction

Current development is focused on extending the platform further into infrastructure automation, deployment validation, CI/CD and increasingly resilient monitoring operations.

---

## Project Structure

```text
homelab-monitoring/
│
├── Terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   ├── versions.tf
│   └── scripts/
│       └── bootstrap.sh
│
├── prometheus/
│   ├── homelab.yml
│   └── aws.yml
│
├── systemd/
│   ├── homelab-update-metrics.service
│   └── homelab-update-metrics.timer
│
├── docs/
│   └── remote-access.md
│
├── Screenshots/
│
├── check-updates.sh
├── docker-compose.yml
├── README.md
└── .gitignore
```

---

## Security & Configuration Handling

Environment-specific settings and credentials are stored locally rather than committed to source control.

The repository excludes:

* `.env`
* Terraform state
* Terraform variable values
* Terraform saved plans
* generated Prometheus textfile metrics
* Grafana runtime data
* Prometheus runtime data
* logs and local database files

A `terraform.tfvars.example` file documents the expected Terraform configuration without exposing deployment-specific values.

Grafana SMTP authentication uses an application-specific password rather than a primary account password.

The HomeLab does not expose SSH, Grafana, Prometheus or RustDesk through inbound Internet router port forwarding.

---

## Quick Start

Clone the repository:

```bash
git clone git@github.com:K-Roper-Projects/homelab-monitoring.git
cd homelab-monitoring
```

Create a local `.env` file and select the required Prometheus configuration.

For HomeLab:

```text
PROMETHEUS_CONFIG=./prometheus/homelab.yml
```

For AWS:

```text
PROMETHEUS_CONFIG=./prometheus/aws.yml
```

Add SMTP configuration if email alerting is required.

Start the monitoring stack:

```bash
docker compose up -d
```

Check container status:

```bash
docker compose ps
```

Default service ports:

| Service           | Port |
| ----------------- | ---: |
| Grafana           | 3000 |
| Prometheus        | 9090 |
| Node Exporter     | 9100 |
| Blackbox Exporter | 9115 |

---

## Technologies

### Cloud & Infrastructure as Code

* AWS EC2
* Amazon EBS
* AWS VPC
* AWS IAM
* AWS Security Groups
* Terraform
* HashiCorp AWS Provider
* HCL
* `cloud-init`
* EC2 User Data

### Monitoring & Observability

* Prometheus
* Grafana
* Node Exporter
* Blackbox Exporter
* Grafana Alerting
* Prometheus textfile collector
* SMTP notifications

### Containers & Linux

* Docker
* Docker Compose
* Ubuntu Desktop
* Ubuntu Server
* systemd
* unattended-upgrades
* Bash

### Networking & Remote Administration

* TCP/IP
* HTTP monitoring
* Tailscale
* OpenSSH
* RustDesk

### Development & Source Control

* Git
* GitHub

---

## Current Limitations

The HomeLab remains an evolving engineering environment.

Current limitations include:

* dependency on the Windows host being powered on for the local VM
* automatic VirtualBox VM startup following Windows restart has not yet been implemented
* some HomeLab SSH administration still uses password authentication
* management-service exposure within the HomeLab can be restricted further
* Terraform currently uses local state

These provide clear opportunities for future resilience, security and automation improvements.

---

## Future Development

### Infrastructure as Code

* Introduce remote Terraform state
* Add Terraform state locking
* Continue improving reusable Terraform configuration
* Expand AWS deployment automation

### CI/CD & Validation

* Introduce automated Terraform formatting and validation
* Validate monitoring configuration through CI/CD
* Add deployment checks before infrastructure changes

### Monitoring & Reliability

* Expand Docker container health monitoring
* Add additional infrastructure and service targets
* Extend automated recovery capabilities
* Continue developing custom operational metrics
* Expand alerting and service-health monitoring

### Security & Remote Administration

* Introduce SSH key-based administration throughout the HomeLab
* Remove remaining password-based SSH access once validated
* Further restrict management-service exposure
* Introduce more restrictive Tailscale ACLs as the environment grows

### Platform Evolution

The longer-term objective is to continue developing the HomeLab into a practical environment for **infrastructure engineering, cloud operations, automation, observability and reliability engineering**.

---

## Author

**Kevin Roper**

Infrastructure Engineer | AWS Certified | Cloud & Automation

[GitHub Profile](https://github.com/K-Roper-Projects)
