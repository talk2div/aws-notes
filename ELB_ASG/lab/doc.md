# **Lab Guide: Highly Available Web Architecture (ALB + ASG)**

**Objective:** Deploy a fault-tolerant, scalable web architecture using AWS Auto Scaling and Application Load Balancers.
**Region:** Singapore (`ap-southeast-1`)
**Estimated Time:** 45–60 Minutes (+ 15–30 minutes for optional Phase 7-8)

---

## **Phase 1: Network Setup (VPC)**

*Build the roads before the buildings.*

1. **Create VPC:**
* Go to **VPC Console** \rightarrow **Your VPCs** \rightarrow **Create VPC**.
* **Name tag:** `lab-vpc`
* **IPv4 CIDR:** `10.0.0.0/16`
* Click **Create VPC**.


2. **Create Subnets (4 Total):**
* Go to **Subnets** \rightarrow **Create subnet** \rightarrow Select `lab-vpc`.
* **Subnet 1 (Public A):** Name: `public-subnet-a` | AZ: `ap-southeast-1a` | CIDR: `10.0.1.0/24`
* **Subnet 2 (Public B):** Name: `public-subnet-b` | AZ: `ap-southeast-1b` | CIDR: `10.0.2.0/24`
* **Subnet 3 (Private A):** Name: `private-subnet-a` | AZ: `ap-southeast-1a` | CIDR: `10.0.3.0/24`
* **Subnet 4 (Private B):** Name: `private-subnet-b` | AZ: `ap-southeast-1b` | CIDR: `10.0.4.0/24`


3. **Setup Internet Gateway (IGW):**
* Go to **Internet Gateways** \rightarrow **Create internet gateway**.
* Name: `lab-igw` \rightarrow Click **Create**.
* Select `lab-igw` \rightarrow **Actions** \rightarrow **Attach to VPC** \rightarrow Select `lab-vpc`.


4. **Setup NAT Gateways (For Private Internet Access):**
* Go to **NAT Gateways** \rightarrow **Create NAT gateway**.
* **NAT 1:** Name: `nat-gw-a` | Subnet: `public-subnet-a` | Connectivity: `Public` | **Allocate Elastic IP**.
* **NAT 2:** Name: `nat-gw-b` | Subnet: `public-subnet-b` | Connectivity: `Public` | **Allocate Elastic IP**.
* *(Note: This creates High Availability for outbound traffic).*


5. **Configure Route Tables:**
* **Public Route Table:**
* Create RT named `public-rt` \rightarrow Associate with `lab-vpc`.
* **Edit routes:** Add `0.0.0.0/0` \rightarrow Target: `Internet Gateway`.
* **Subnet associations:** Select both `public-subnet-a` and `public-subnet-b`.


* **Private Route Table A:**
* Create RT named `private-rt-a` \rightarrow Associate with `lab-vpc`.
* **Edit routes:** Add `0.0.0.0/0` \rightarrow Target: `nat-gw-a`.
* **Subnet associations:** Select `private-subnet-a`.


* **Private Route Table B:**
* Create RT named `private-rt-b` \rightarrow Associate with `lab-vpc`.
* **Edit routes:** Add `0.0.0.0/0` \rightarrow Target: `nat-gw-b`.
* **Subnet associations:** Select `private-subnet-b`.





---

## **Phase 2: Security Groups (The Firewalls)**

*Define who is allowed to talk to whom.*

1. **ALB Security Group (`alb-sg`):**
* **Inbound:** Type: `HTTP` | Source: `Anywhere-IPv4` (`0.0.0.0/0`).


2. **Bastion Security Group (`bastion-sg`):**
* **Inbound:** Type: `SSH` | Source: `My IP` (Your laptop's IP).


3. **App Instance Security Group (`app-sg`):**
* **Inbound Rule 1:** Type: `HTTP` | Source: Custom \rightarrow Select `alb-sg`.
* **Inbound Rule 2:** Type: `SSH` | Source: Custom \rightarrow Select `bastion-sg`.
* *(Crucial: This ensures only the Load Balancer and Bastion can touch the app servers).*



---

## **Phase 3: Launch Templates**

*Blueprints for your servers.*

1. **Bastion Template (Public):**
* Go to **EC2** \rightarrow **Launch Templates** \rightarrow **Create launch template**.
* Name: `bastion-template`.
* **AMI:** Amazon Linux 2023.
* **Instance Type:** `t2.micro` or `t3.micro`.
* **Key pair:** Create/Select a key pair (e.g., `lab-key`).
* **Network settings:** Select Security Group `bastion-sg`.
* **Advanced details:** "Auto-assign public IP" \rightarrow **Enable**.


2. **App Server Template (Private):**
* Create another template. Name: `app-template`.
* **AMI:** Amazon Linux 2023.
* **Instance Type:** `t2.micro`.
* **Key pair:** Select `lab-key`.
* **Network settings:** Select Security Group `app-sg`.
* **Advanced details (User Data):** Paste this script to install a web server automatically:
```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# 1. Get the IMDSv2 Security Token (Valid for 6 hours)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# 2. Use the Token to get the Availability Zone
AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

# 3. Write the HTML file
echo "<h1>Hello from Private Server in AZ: $AZ</h1>" > /var/www/html/index.html
```





---

## **Phase 4: Load Balancer & Target Groups**

1. **Create Target Group:**
* Go to **EC2** \rightarrow **Target Groups** \rightarrow **Create target group**.
* Type: **Instances**. Name: `lab-tg`. Protocol: `HTTP` : `80`.
* VPC: `lab-vpc`.
* **Health checks:** Path `/` (default).
* Click **Next**. **Do not register targets yet** (ASG will do this later). Click **Create**.


2. **Create Application Load Balancer:**
* Go to **Load Balancers** \rightarrow **Create Load Balancer** \rightarrow **ALB**.
* Name: `lab-alb`. Scheme: **Internet-facing**.
* **Network mapping:** Select `lab-vpc`. Select **both** public subnets (`public-subnet-a`, `public-subnet-b`).
* **Security groups:** Select `alb-sg` (Remove the default one).
* **Listeners:** Protocol `HTTP` \rightarrow Forward to `lab-tg`.
* Click **Create load balancer**.



---

## **Phase 5: Auto Scaling Groups (ASG)**

1. **Create Bastion ASG (Public):**
* Go to **Auto Scaling Groups** \rightarrow **Create Auto Scaling group**.
* Name: `bastion-asg`. Template: `bastion-template`.
* **Network:** VPC `lab-vpc`. Subnets: `public-subnet-a`, `public-subnet-b`.
* **Load Balancing:** No load balancer attached.
* **Group size:** Desired: `2`, Min: `2`, Max: `2` (One in each AZ).
* Click **Next** through options and **Create**.


2. **Create App ASG (Private):**
* Create another ASG. Name: `app-asg`. Template: `app-template`.
* **Network:** VPC `lab-vpc`. Subnets: `private-subnet-a`, `private-subnet-b`.
* **Load Balancing:** Attach to an existing load balancer \rightarrow Choose your Target Group `lab-tg`.
* **Group size:** Desired: `2`, Min: `2`, Max: `4`.
* Click **Create**.



---

## **Phase 6: Verification & Testing**

1. **Check Instances:**
* Go to **EC2 Instances**. You should see 4 new instances spinning up (2 Bastions, 2 App Servers).


2. **Test the Load Balancer:**
* Go to **Load Balancers** \rightarrow Select `lab-alb`.
* Copy the **DNS name** (e.g., `lab-alb-1234.ap-southeast-1.elb.amazonaws.com`).
* Paste it into your browser.
* **Result:** You should see *"Hello from Private Server..."*. Refresh multiple times; the AZ name should change as the ALB flips between servers in A and B.


3. **Test High Availability (Chaos Engineering):**
* Terminate one of the **App Instances** manually.
* Watch the Auto Scaling Group notice the failure and automatically launch a replacement.

---

## **Phase 7 (Optional): Configure Target Tracking Scaling Policies**

*Automatically scale based on real-world demand.*

Target Tracking Policies enable dynamic scaling based on CloudWatch metrics. This ensures your application automatically adjusts capacity to maintain a desired performance level.

### **7.1: Add Target Tracking Policy to App ASG**

1. Go to **Auto Scaling Groups** \rightarrow Select `app-asg`.

2. Click the **Automatic scaling** tab.

3. Click **Create scaling policy**.

4. **Policy type:** Select **Target tracking scaling policy**.

5. **Scaling policy name:** `app-cpu-target-tracking`.

6. **Metric type:** Choose **CPU Utilization** (most common).

7. **Target value:** `70` (Keeps CPU at ~70% utilization).

8. **Optional settings:**
   * **Instances need:** 300 seconds (5 minutes) to warm up before scale-in metrics count.
   * **Scale-in stabilization:** 300 seconds (prevents rapid scale-downs).

9. Click **Create**.

### **7.2: How Target Tracking Works**

| Scenario | Action |
|----------|--------|
| CPU > 70% | **Scale OUT** (add instances, up to max 4) |
| CPU < 70% | **Scale IN** (remove instances after 5 min, down to min 2) |
| Rapid fluctuations | Stabilization periods prevent thrashing |

---

## **Phase 8 (Optional): Advanced Testing with Target Tracking Scaling**

1. **Test Target Tracking Scaling (CPU-Based):**
* SSH into a Bastion instance: `ssh -i lab-key.pem ec2-user@<bastion-public-ip>`
* From the Bastion, generate load on the app servers:
```bash
# Install Apache Bench
sudo yum install -y httpd-tools

# Generate high traffic (replace with your ALB DNS)
ab -n 10000 -c 100 http://lab-alb-1234.ap-southeast-1.elb.amazonaws.com/
```
* Watch **Auto Scaling Groups** \rightarrow `app-asg` \rightarrow **Activity** tab.
* Observe: Desired capacity increases to 3 or 4 instances as CPU spikes.
* After traffic stops, wait 5 minutes; the ASG scales back down to 2 instances.


2. **Monitor Scaling Activity:**
* Go to **Auto Scaling Groups** \rightarrow `app-asg`.
* Click **Activity history** to see all scaling events.
* Click **Scaling policies** to see policy details and CloudWatch metrics.


3. **CloudWatch Monitoring (Optional but Recommended):**
* Go to **CloudWatch** \rightarrow **Dashboards** \rightarrow **Create dashboard**.
* Add widgets:
   * **EC2 Instance Count** (from `app-asg`)
   * **CPU Utilization** (from Target Tracking Policy)
   * **ALB Request Count** (from Target Group metrics)
   * **Target Unhealthy Count** (Health check failures)
* Refresh the dashboard while running load tests to see real-time scaling.

---

## **Summary: What You've Built**

✅ **VPC with Public/Private Subnets** → Network isolation  
✅ **NAT Gateways** → Outbound internet access for private instances  
✅ **Security Groups** → Layered access control  
✅ **Application Load Balancer** → Distributes traffic across instances  
✅ **Auto Scaling Groups** → Maintains desired instance count + fault tolerance  
✅ **Target Tracking Policies** → Automatic scaling based on real metrics *(optional)*  
✅ **High Availability** → Multi-AZ deployment with automatic failover  

**You now have a production-ready, self-healing, auto-scaling web architecture!**

---

## **Cleanup (When Done)**

1. Delete **Auto Scaling Groups** (terminates instances).
2. Delete **Load Balancers** and **Target Groups**.
3. Delete **Launch Templates**.
4. Delete **NAT Gateways** (and release Elastic IPs).
5. Delete **VPC** (cascades to subnets, route tables, etc.).