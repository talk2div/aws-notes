# AWS Notes & Labs

A comprehensive collection of AWS architecture notes, guides, and hands-on labs demonstrating best practices for building scalable, secure, and cost-effective cloud infrastructure on Amazon Web Services.

## 📚 Contents

### ELB_ASG
High availability and auto-scaling architecture using Application Load Balancer (ALB) and Auto Scaling Groups (ASG).

**Includes:**
- Infrastructure as Code (Terraform)
- Multi-AZ VPC setup with public/private subnets
- Load balancing and auto-scaling configuration
- Detailed lab guide with step-by-step instructions

[View ELB_ASG Project →](./ELB_ASG/)

---

## 🎯 Purpose

This repository serves as a learning resource and reference for AWS cloud architecture, providing:

- **Practical Labs** - Hands-on guides to implement common AWS patterns
- **Infrastructure as Code** - Terraform examples for reproducible deployments
- **Best Practices** - Documentation of security, scalability, and cost optimization
- **Architecture Diagrams** - Visual representations of cloud infrastructure
- **Configuration Examples** - Ready-to-use configurations and templates

## 🚀 Getting Started

1. **Browse the folders** - Each directory contains a specific AWS topic or architecture pattern
2. **Read the documentation** - Start with README files in each folder
3. **Deploy locally** - Most projects include Terraform configs for testing in your own AWS account
4. **Learn & Experiment** - Modify configurations to understand different approaches

## 📋 Prerequisites

- AWS Account
- [Terraform](https://www.terraform.io/downloads.html) (for IaC projects)
- [AWS CLI](https://aws.amazon.com/cli/) configured
- Basic understanding of AWS services
- SSH key pair for EC2 access (for applicable labs)

## 🔒 Important Notes

⚠️ **Cost Awareness:** Projects in this repository create AWS resources that may incur charges. Always:
- Review [AWS Pricing](https://aws.amazon.com/pricing/)
- Run `terraform plan` before applying
- Clean up resources with `terraform destroy` when done
- Monitor your AWS bill regularly

## 📖 How to Use Each Project

1. Navigate to the project folder
2. Read the README and documentation
3. Follow the setup instructions
4. Deploy using provided scripts/Terraform
5. Experiment and learn
6. Clean up to avoid charges

## 🛠️ Technology Stack

- **Infrastructure:** AWS (EC2, VPC, ELB, ASG, etc.)
- **IaC:** Terraform
- **Documentation:** Markdown
- **Platforms:** Multi-AZ, Multi-region ready

## 📝 Topics Covered

- [x] Load Balancing & Auto Scaling
- [ ] Networking & VPC Design *(Coming soon)*
- [ ] Database & Data Storage *(Coming soon)*
- [ ] Security & Identity Management *(Coming soon)*
- [ ] Monitoring & Logging *(Coming soon)*
- [ ] Serverless Architecture *(Coming soon)*
- [ ] CI/CD Pipelines *(Coming soon)*

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Add new lab projects
- Improve documentation
- Fix issues
- Share feedback

## 📄 License

This project is provided as-is for educational purposes.

## ⚡ Quick Links

- [AWS Documentation](https://docs.aws.amazon.com/)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS Architecture Center](https://aws.amazon.com/architecture/)

---

**Last Updated:** December 2025  
**Note:** More content and labs coming soon! Check back regularly for updates.
