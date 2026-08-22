variable "aws_region" {
  description = "AWS region used to deploy the monitoring infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the monitoring server"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "AWS EC2 key pair used for SSH access to the monitoring server"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the monitoring server"
  type        = string
}

variable "allowed_monitoring_cidr" {
  description = "CIDR block allowed to access the monitoring web services"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the EC2 root EBS volume in GiB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "EBS volume type used for the EC2 root volume"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Whether the EC2 root EBS volume is encrypted"
  type        = bool
  default     = true
}

variable "root_volume_delete_on_termination" {
  description = "Whether the EC2 root EBS volume is deleted when the instance is terminated"
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "AMI ID used for the monitoring EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name tag applied to the monitoring EC2 instance"
  type        = string
  default     = "Monitoring-Server"
}

variable "vpc_cidr" {
  description = "CIDR block used by the monitoring VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block used by the public monitoring subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone used by the monitoring public subnet"
  type        = string
  default     = "us-east-1a"
}