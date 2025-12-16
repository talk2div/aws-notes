# Elastic Compute Cloud (EC2)

## Overview
- **Regional Service**
- EC2 (Elastic Compute Cloud) is an **Infrastructure as a Service (IaaS)**
- Stopping & starting an instance may change its **public IP** but not its **private IP**
- **AWS Compute Optimizer** recommends optimal AWS Compute resources for workloads
- There is a **vCPU-based On-Demand Instance soft limit per region**

---

## User Data
- Commands that run when the instance is launched for the **first time only**
- Does **not** execute for subsequent runs
- Used to automate dynamic boot tasks that cannot be done using AMIs
- Examples:
  - Installing updates
  - Installing software
  - Downloading common files from the internet
- Runs with **root user** privileges

---

## Instance Classes

### General Purpose
- Great for a diversity of workloads (web servers, code repositories)
- Balanced compute, memory, and networking

### Compute Optimized
- Great for compute-intensive tasks
- Examples:
  - Batch processing
  - Media transcoding
  - HPC
  - Gaming servers

### Memory Optimized
- Great for in-memory databases or distributed web caches

### Storage Optimized
- Great for storage-intensive tasks
- Examples:
  - OLTP systems
  - Distributed File Systems (DFS)

---

## Security Groups
- Only contain **Allow** rules
- Act as an **external firewall** for EC2 instances
- Blocked requests result in a **timeout**
- Rules can reference:
  - IP addresses
  - Other Security Groups
- A Security Group can be attached to **multiple instances** and vice versa
- Bound to a **VPC** (and hence a region)
- Recommended to maintain a **separate SG for SSH**

### Default Security Group
- Inbound traffic from the same SG is allowed
- All outbound traffic is allowed

### New Security Group
- All inbound traffic is blocked
- All outbound traffic is allowed

---

## IAM Roles for EC2 Instances
- Never store AWS credentials on an EC2 instance
- Use **IAM Roles** instead

---

## Purchasing Options

### On-Demand Instances
- Pay per use (no upfront payment)
- Highest cost
- No long-term commitment
- Best for short-term, uninterrupted, unpredictable workloads

### Standard Reserved Instances
- Reservation period: **1 year or 3 years**
- Best for steady-state applications (e.g., databases)
- Unused instances can be sold on the **Reserved Instance Marketplace**

### Convertible Reserved Instances
- Instance type can be changed
- Lower discount
- Cannot be sold on the marketplace

### Scheduled Reserved Instances
- Reserved for a specific time window (e.g., daily 9 AM – 5 PM)

### Spot Instances
- Bid-based pricing
- Instance may terminate if spot price increases
- Spot blocks are designed not to be interrupted
- Best for fault-tolerant workloads:
  - Distributed jobs
  - Batch jobs

### Dedicated Hosts
- Physical server dedicated to one customer
- 3-year reservation
- Billed per host
- Useful for BYOL and compliance requirements

### Dedicated Instances
- Dedicated hardware
- Billed per instance
- No control over instance placement

### On-Demand Capacity Reservations
- Guarantees capacity in a specific AZ
- Can be reserved on a recurring schedule
- No 1- or 3-year commitment required
- Requires:
  - Availability Zone
  - Number of instances
  - Instance attributes

---

## Spot Instances – Advanced Concepts

### Spot Requests
- **One-time**: Launches instances once and closes
- **Persistent**:
  - Remains disabled while instances are running
  - Becomes active after interruption
  - Reactivates after stopped instance is started
- Can cancel only open, active, or disabled requests
- Cancelling a request does **not** terminate instances

### Spot Fleets
- Combination of Spot and On-Demand instances
- Uses **Launch Templates**
- Can include multiple instance types

#### Allocation Strategies
- `lowestPrice` – lowest cost
- `diversified` – higher availability
- `capacityOptimized` – optimal capacity

---

## Elastic IP (EIP)
- Static public IP owned by you
- Can be attached to a stopped instance
- Soft limit: **5 EIPs per account**
- No charges if:
  - Associated with a running EC2 instance
  - Only one EIP is attached to the instance

---

## Placement Groups

### Cluster Placement Group
- Instances on the same rack
- High performance (up to 10 Gbps)
- Single point of failure
- Used for HPC workloads

### Spread Placement Group
- Each instance on separate hardware
- Supports Multi-AZ
- Max 7 instances per AZ
- Used for critical applications

### Partition Placement Group
- Instances divided into partitions
- Rack failure affects only one partition
- Up to 7 partitions per AZ
- Used in big data workloads (Hadoop, Cassandra, Kafka)

**Tip:** If you get a capacity error, stop and start all instances in the placement group and retry.

---

## Elastic Network Interface (ENI)
- Virtual network card for EC2
- Provides private IP addresses
- Primary ENI is auto-created and deleted on termination
- Additional ENIs can be attached/detached
- ENIs are tied to a **subnet and AZ**

---

## Instance States

### Stop
- EBS root volume is preserved

### Terminate
- EBS root volume is destroyed

### Hibernate
- RAM contents saved to EBS root volume
- Faster startup
- Retains instance ID
- Max duration: **60 days**
- Not supported for Spot Instances

### Standby
- Instance remains in ASG but out of service
- Used for updates or troubleshooting

---

## EC2 Nitro
- Modern virtualization platform
- Enhanced networking & security
- Higher EBS performance (up to 64,000 IOPS)

---

## vCPU & Threads
- vCPU = number of concurrent threads
- Typically 2 threads per CPU core

---

## Storage Options
- Instance Store
- Elastic Block Store (EBS)
- Elastic File System (EFS)

---

## Monitoring
- **CloudWatch → EC2 Monitoring**

---

## Amazon Machine Image (AMI)
- Preconfigured OS and software image
- Faster boot times
- Region-specific (can be copied)
- AMI copy creates a snapshot in the target region

---

## Instance Metadata
- Metadata URL: `http://169.254.169.254/latest/meta-data`
- Accessible only from within the instance

---

## EC2 Classic & ClassicLink
- Legacy shared network model
- ClassicLink connects EC2-Classic to VPC

---

## Billing
- Reserved Instances billed regardless of state
- On-Demand billed when running
- Stopping during hibernation preparation is billed
- No billing in other stopped states

---

## Run Command
- Part of AWS Systems Manager
- Secure remote management
- Automates administrative tasks at scale
- No additional cost

---

## Instance Tenancy
- **Default**: Shared hardware
- **Dedicated**: Single-tenant hardware
- **Host**: Dedicated physical host
- Tenancy changes allowed only between host and dedicated
- Dedicated takes precedence over default

---

## Troubleshooting
Common reasons for immediate termination:
- EBS volume limit exceeded
- Corrupt EBS snapshot
- Missing KMS permissions for encrypted root volume
- Incomplete instance store-backed AMI
