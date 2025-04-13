@"
# High Availability Web App with Internal ALB, API Gateway, and SSH Host

## Objective

Deploy a highly available and secure web application on AWS that:

- Runs on **private EC2 instances** behind an **internal Application Load Balancer (ALB)**
- Is publicly accessible through **API Gateway (HTTPS)**
- Uses a **publicly accessible SSH Host** to securely access private instances
- Is built entirely using the **AWS CLI (no console access or root account)**

## Project Structure

- **VPC** with private and public subnets
- **Route tables** pre-configured for proper traffic routing
- **NAT Gateway** for outbound internet access from private subnets
- **EC2 Instances** (2 private for app, 1 public for SSH access)
- **NGINX** installed on private instances
- **Internal ALB** routing traffic to EC2s
- **API Gateway** exposing the ALB over HTTPS
- **VPC Link** for secure connectivity between API Gateway and ALB

## Key AWS Services Used

- VPC, Subnets, Route Tables
- EC2, Security Groups, Key Pairs
- Internet Gateway, NAT Gateway
- Application Load Balancer
- API Gateway with VPC Link
- Session Manager for SSH alternative

## Commands Summary

> All infrastructure is provisioned using `aws cli` on a RHEL shell in WSL.

- `aws ec2 create-vpc` – Set up isolated networking
- `aws ec2 create-subnet` – Public and private subnets
- `aws ec2 create-nat-gateway` – NAT for private EC2 outbound access
- `aws ec2 run-instances` – Deploy EC2s with and without public IPs
- `aws elbv2 create-load-balancer` – Internal ALB
- `aws apigatewayv2 create-api` – Public endpoint via API Gateway
- `scp` & `ssh` – Secure key transfer and instance access

## Final Outcome

✅ Private EC2s  
✅ NGINX Serving Content  
✅ Internal ALB  
✅ API Gateway (HTTPS Access)  
✅ Full CLI-based Infrastructure  

---

> Created by **Prashant Khatri**  
> Based on hands-on AWS architecture for High Availability Web Applications
"@ | Out-File -Encoding utf8 -FilePath .\README.md
