# AWS Lambda

## Overview
- **Function as a Service (FaaS)**
- **Serverless**
- **Auto-scaling**
- Pay per request (number of invocations) and compute time
- Integrated with **Amazon CloudWatch** for monitoring
- Not ideal for long-running or traditional containerized applications
- Supports packaging and deploying Lambda functions as **container images**

---

## Performance
- Increasing **RAM** also improves **CPU and network performance**
- Memory range: **128 MB – 10 GB**
- Maximum execution time: **15 minutes**
- Disk space in function container (`/tmp`): **512 MB**
- Environment variables limit: **4 KB**

---

## Deployment

### Deployment Package Size
- Compressed: **50 MB**
- Uncompressed: **250 MB**

### Lambda Layers
- Used to share reusable libraries and code across functions
- Layers are ZIP archives containing dependencies
- Keeps deployment packages small and manageable
- A single Lambda function can use **up to 5 layers** simultaneously

---

## Networking
- By default, Lambda runs in an **AWS-managed VPC**
  - Has access to the public internet and public AWS APIs
  - Example: Interacting with DynamoDB using AWS APIs
- When **VPC-enabled**:
  - All traffic follows your VPC and subnet routing rules
  - A **NAT Gateway** is required to access public resources
  - Should only be enabled when accessing **private resources**
    - Example: RDS in a private subnet
- To access private VPC resources, you must provide:
  - Subnet IDs
  - Security Group IDs
- AWS Lambda creates **Elastic Network Interfaces (ENIs)** in your VPC

---

## Supported Languages
- Node.js (JavaScript)
- Python
- Java
- C#
- Go (Golang)
- Ruby
- Any language via **Custom Runtime API**
  - Community-supported (e.g., Rust)

---

## Common Use Cases
- Serverless thumbnail generation using **S3 + Lambda**
- Serverless scheduled jobs using **EventBridge + Lambda**
- Event-driven data processing
- API backends with **API Gateway + Lambda**

---

## Lambda@Edge
- Deploy Lambda functions at **CloudFront edge locations**
- Customize content delivery at the edge (low latency)
- No server management; deployed **globally**
- Pay only for usage (no provisioning)
- Can modify:
  - CloudFront viewer requests
  - Origin requests
  - Origin responses
  - Viewer responses

### Example Architecture
- S3 hosts a static website
- Client-side JavaScript sends requests to **CloudFront**
- CloudFront invokes **Lambda@Edge**
- Lambda@Edge performs operations such as:
  - Fetching data from DynamoDB
  - Modifying headers or responses
- Results are returned from the **nearest edge location**

---
