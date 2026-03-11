# Secure Multi-Tier AWS Network Architecture
### Built with Terraform (Infrastructure as Code) | AWS | Cloud Security

---

## Overview

This project builds a secure network environment on AWS using Terraform — 
a tool that lets you provision and spin up infrastructure as code rather than clicking 
through the AWS Console manually.

The goal is to show how you can separate public-facing resources from 
sensitive backend systems, so that critical data is never directly exposed 
to the internet. This mirrors the kind of architecture you would need in 
environments where data security is non-negotiable, such as the public sector 
or law enforcement systems.

---

## What Problem Does This Solve?

Imagine a bank. Customers interact with the front desk — but the vault is 
locked away in a back room that only authorised staff can access. You would 
never leave the vault accesible to anyone. 

This project applies that same logic to cloud infrastructure:

- The **Public Subnet** is the front desk — it faces the internet
- The **Private Subnet** is the vault — it is completely hidden from the internet
- **Security Groups** are the security guards — they decide who is allowed in and out

---

## Architecture Diagram
```
Internet
    │
    ▼
Internet Gateway (IGW)
    │
    ▼
┌─────────────────────────────────────┐
│           VPC: 10.0.0.0/16          │
│        (Our private network)        │
│                                     │
│  ┌──────────────────────────────┐   │
│  │  Public Subnet: 10.0.1.0/24  │   │
│  │  (Faces the internet)        │   │
│  │  Only HTTPS traffic allowed  │   │
│  └──────────────┬───────────────┘   │
│                 │                   │
│        Internal traffic only        │
│                 │                   │
│  ┌──────────────▼───────────────┐   │
│  │  Private Subnet: 10.0.2.0/24 │   │
│  │  (Hidden from the internet)  │   │
│  │  Only talks to public subnet │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## What Gets Built

| Resource | What It Does |
|---|---|
| **VPC** | A private, isolated network in AWS — nothing gets in unless we allow it |
| **Public Subnet** | Where internet-facing resources live |
| **Private Subnet** | Where sensitive systems and data live — no internet access |
| **Internet Gateway** | The single controlled entry point between our network and the internet |
| **Route Tables** | Traffic rules — tells each subnet where it is and isn't allowed to send data |
| **Security Groups** | Acts like a firewall — controls exactly which ports and sources can connect |

---

## Key Security Decisions

**London region (eu-west-2)**
All infrastructure is deployed in the UK, ensuring data stays within 
UK jurisdiction.

**Private subnet has no internet route**
This is intentional. The private subnet's route table has no path to the 
internet gateway — meaning anything inside it simply cannot be reached 
from the outside world, even by accident.

**HTTPS only**
The public subnet only accepts encrypted traffic on port 443. 
No unencrypted HTTP traffic is permitted.

**Least Privilege**
Every security group only allows the minimum access required. 
The private subnet can only receive traffic from the public subnet — 
nothing else.

---

## How to Use This Project

### What you need first
- [Terraform](https://developer.hashicorp.com/terraform/install) installed on your machine
- An AWS account
- AWS CLI set up (`aws configure`)

### Steps
```bash
# 1. Clone this repository to your machine
git clone https://github.com/YOUR_USERNAME/aws-vpc-terraform.git
cd aws-vpc-terraform

# 2. Initialise Terraform (downloads the necessary AWS plugin)
terraform init

# 3. Preview what will be created — nothing is built yet
terraform plan

# 4. Build the infrastructure
terraform apply

# 5. When finished, tear everything down to avoid AWS charges
terraform destroy
```

---

## Deployment Evidence

After running `terraform apply`, the AWS Console Resource Map confirmed 
all resources were created correctly. `terraform destroy` was then run 
to remove all resources and ensure no ongoing costs.

![AWS VPC Resource Map](screenshots/vpc-resource-map.png)

---

## What I Learned

- How to write Infrastructure as Code using Terraform
- How to design a network that separates public and private resources
- How security groups and route tables work together to control traffic
- The importance of the Principle of Least Privilege in cloud security
- How to manage the full infrastructure lifecycle — build, verify, destroy

---

## Author

**Jamil Chowdhury**  
AWS Certified Cloud Practitioner  
[LinkedIn](https://linkedin.com/in/YOUR_PROFILE) | [GitHub](https://github.com/YOUR_USERNAME)


