# Auto Scaling Group (ASG)

## Overview
- **Regional service**
- Supports **Multi-AZ**
- Automatically scales EC2 instances **horizontally** based on load
- **Free service** (you pay only for the underlying EC2 resources)
- IAM roles attached to an ASG are automatically assigned to launched EC2 instances
- ASG can terminate instances marked **unhealthy by an ELB** and replace them
- Even when deployed across 3 AZs, a minimum of **2 instances** is required for high availability

> ⚠️ If you delete an ASG with running instances, **all instances are terminated** and the ASG is deleted.

---

## Scaling Policies

### Scheduled Scaling
- Scale based on a fixed schedule
- Best for **predictable load patterns**

### Simple Scaling
- Scale to a specific size based on a CloudWatch alarm
- Example:
  - If CPU > 90%, scale to 10 instances

### Step Scaling
- Scale incrementally using CloudWatch alarms
- Example:
  - CPU > 70% → add 2 instances
  - CPU < 30% → remove 1 instance
- Configure **instance warm-up time** for faster scaling

### Target Tracking Scaling
- ASG automatically maintains a target CloudWatch metric
- Automatically creates and manages alarms
- Example:
  - Maintain average CPU utilization at 40%

### Predictive Scaling
- Uses historical data and ML to predict traffic
- Automatically scales ahead of expected demand

---

## Launch Configuration & Launch Template

Defines the configuration used to launch instances in an ASG:

- AMI and Instance Type
- EC2 User Data
- EBS Volumes
- Security Groups
- SSH Key Pair
- Minimum / Maximum / Desired capacity
- Subnets (where instances are launched)
- Load Balancer attachment
- Scaling policies

### Launch Configuration (Legacy)
- Cannot be modified (must be recreated)
- Does **not** support Spot Instances

### Launch Template (Recommended)
- Versioned
- Can be updated
- Supports **On-Demand and Spot Instances**
- Recommended by AWS

---

## Scaling Cooldown
- After a scaling event, ASG enters a **cooldown period**
- Default cooldown: **300 seconds**
- During cooldown, ASG ignores further scaling requests
- Use **pre-baked AMIs** to launch instances faster and reduce cooldown time

---

## Health Checks
- By default, ASG uses **EC2 status checks**
- ELB health checks are **not used unless explicitly enabled**
- Instances marked unhealthy by ELB may not be immediately terminated
- To stop ASG from replacing unhealthy instances:
  - Suspend the `ReplaceUnhealthy` process
- ASG behavior:
  - Creates a scaling activity to terminate the unhealthy instance
  - Creates another scaling activity to launch a replacement

---

## Termination Policy
ASG follows this order when terminating instances:
1. Select the AZ with the **most instances**
2. Terminate the instance with the **oldest launch configuration**
3. Terminate the instance **closest to the next billing hour**

> ASG waits briefly before terminating instances with **Impaired** status to allow recovery.  
> ASG does not terminate instances until the **health check grace period** expires.

---

## Rebalancing Availability Zones
- ASG ensures it never drops below **minimum capacity**
- Changes such as:
  - AZ updates
  - Manual instance termination or detachment  
  may cause imbalance
- ASG rebalances by:
  - Launching new instances first
  - Then terminating old ones
- Ensures **availability and performance** are preserved

---

## Lifecycle Hooks
- Used to perform custom actions during instance lifecycle transitions

### Examples
- **Pending state**
  - Install additional software
  - Run validation checks before marking instance as *InService*
- **Terminating state**
  - Extract or upload log files
  - Gracefully shut down services

> Without lifecycle hooks, pending and terminating states are skipped.

---

## Attaching Running Instances to an ASG
A running EC2 instance can be attached to an ASG if:
- The AMI used to launch the instance **still exists**
- The instance is **not part of another ASG**
- The instance is launched in one of the **AZs defined in the ASG**

---
