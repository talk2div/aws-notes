# Elastic Load Balancer (ELB)

## Overview
- **Regional service**
- Supports **Multi-AZ**
- Distributes traffic across multiple EC2 instances
- Separates **public** and **private** traffic
- Performs health checks on a port and route (e.g., `/health`)
- Does **not** support weighted routing
- If no targets are registered in a target group → **503 Service Unavailable**
- With **ALB & NLB**, targets in **peered VPCs** can be registered using **IP addresses**

---

## Types of Load Balancers

### Classic Load Balancer (CLB) *(Deprecated)*
- Load balances a single application
- Supports:
  - HTTP / HTTPS (Layer 7)
  - TCP (Layer 4)
- Health checks: HTTP or TCP
- Provides a fixed hostname  
  `xxx.region.elb.amazonaws.com`

---

### Application Load Balancer (ALB)
- Routes traffic to multiple applications using **target groups**
- Operates at **Layer 7** (HTTP, HTTPS, WebSocket)
- Provides a fixed hostname  
  `xxx.region.elb.amazonaws.com`
- Performs **TCP termination**
  - Terminates client connection
  - Opens a new connection to targets
- Supports **Security Groups**
- Ideal for:
  - Microservices
  - Containerized apps (Docker, ECS)

#### Client Information via Headers
- Client IP → `X-Forwarded-For`
- Client Port → `X-Forwarded-Port`
- Protocol → `X-Forwarded-Proto`

#### Target Groups
- Health checks are configured at the **target group level**
- Supported targets:
  - EC2 instances (HTTP)
  - ECS tasks (HTTP)
  - Lambda functions (HTTP → JSON event)
  - Private IP addresses

#### Listener Rules
Traffic routing based on:
- Path (`/users`, `/posts`)
- Hostname (`one.example.com`, `other.example.com`)
- Query string (`?id=123`)
- HTTP headers
- Source IP address

---

### Network Load Balancer (NLB)
- Operates at **Layer 4** (TCP, UDP)
- Handles **millions of requests per second**
- Ultra-low latency (~100 ms vs ~400 ms for ALB)
- Provides **1 static IP per AZ**
- Elastic IPs can be attached (useful for IP whitelisting)
- Preserves the **original client connection** to the target

#### Security Considerations
- **No Security Groups** can be attached to NLBs
- Target instances must allow traffic directly from clients
- Example: EC2 must allow TCP port 80 from anywhere

#### Target Groups
- EC2 instances
  - Traffic routed via **primary private IP**
- IP addresses
  - Used for physical servers or static IP targets

#### ALB + NLB Combination
- Use NLB for **static IP**
- Forward traffic to ALB for **Layer 7 features**

---

### Gateway Load Balancer (GWLB)
- Operates at **Layer 3** (Network layer – IP protocol)
- Used for routing traffic to:
  - Firewalls
  - IDS / IPS
  - Other 3rd-party virtual appliances
- Provides:
  - **Transparent Network Gateway**
  - **Load balancing** across appliances
- Uses **GENEVE protocol**

#### Target Groups
- EC2 instances
- IP addresses

---

## Sticky Sessions (Session Affinity)
- Routes requests from the same client to the **same target**
- Implemented using **cookies**
- Supported only by **CLB & ALB**
- Helps preserve session data (login, shopping cart)
- May cause **uneven load distribution**

### Cookie Types
- Application-based (TTL defined by app)
- Load Balancer–generated (TTL defined by ELB)

### Reserved Cookie Names
- `AWSALB`
- `AWSALBAPP`
- `AWSALBTG`

---

## Cross-Zone Load Balancing
- Distributes traffic evenly across **all instances in all AZs**
- Useful when AZs have uneven instance counts

### Support Matrix
| Load Balancer | Default | Inter-AZ Data Charges |
|--------------|--------|-----------------------|
| CLB | Disabled | No |
| ALB | Always enabled | No |
| NLB | Disabled | Yes |

---

## In-flight Encryption (SSL/TLS)

### Options
- **NLB**
  - TCP listener
  - SSL terminated on EC2 instances
- **ALB**
  - HTTPS listener
  - SSL terminated at ALB
  - Backend traffic over HTTP inside VPC

---

## Server Name Indication (SNI)
- Host multiple SSL certificates on a single load balancer
- Required to serve multiple secure websites
- Supported by:
  - ALB
  - NLB
  - CloudFront
- **Not supported by CLB**
- Newer protocol (older clients may not support it)

---

## Connection Draining (De-registration Delay)
- Allows in-flight requests to complete before deregistration
- ELB stops sending new requests to the instance
- Configurable:
  - **0–3600 seconds**
  - Default: **300 seconds**
- Recommended to increase delay when used with **ASG**

---

## Access Logs
- Captures detailed request-level information
- Useful for:
  - Traffic analysis
  - Troubleshooting
- Disabled by default

---

## Security Groups – Public ELB Best Practice
- Public ELB:
  - Allow HTTP/HTTPS from **anywhere**
- EC2 instances:
  - Allow traffic **only from ELB’s security group**

---