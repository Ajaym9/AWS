# Amazon Route 53 - Complete Feature Hierarchy

```text
Amazon Route 53
│
├── 1. Hosted Zones
│   │
│   ├── Public Hosted Zone
│   │   ├── Internet-facing DNS
│   │   ├── Domain Delegation
│   │   ├── DNSSEC Support
│   │   └── Public DNS Records
│   │
│   └── Private Hosted Zone
│       ├── VPC Association
│       ├── Cross-Account VPC Association
│       ├── Hybrid DNS
│       └── Private DNS Records
│
├── 2. DNS Records
│   │
│   ├── A Record
│   ├── AAAA Record
│   ├── CNAME Record
│   ├── Alias Record
│   ├── MX Record
│   ├── TXT Record
│   ├── NS Record
│   ├── SOA Record
│   ├── SRV Record
│   ├── PTR Record
│   ├── CAA Record
│   ├── NAPTR Record
│   ├── DS Record
│   ├── SPF Record (Legacy)
│   └── TLSA Record
│
├── 3. Routing Policies
│   │
│   ├── Simple Routing
│   ├── Weighted Routing
│   ├── Latency-Based Routing
│   ├── Failover Routing
│   ├── Geolocation Routing
│   ├── Geoproximity Routing (Traffic Flow)
│   ├── Multi-Value Answer Routing
│   ├── CIDR Routing
│   └── IP-Based Routing
│
├── 4. Health Checks
│   │
│   ├── HTTP Health Check
│   ├── HTTPS Health Check
│   ├── TCP Health Check
│   ├── HTTP String Match
│   ├── HTTPS String Match
│   ├── Calculated Health Check
│   ├── CloudWatch Alarm Health Check
│   ├── Latency Measurement
│   └── Health Checker Regions
│
├── 5. Query Logging
│   │
│   ├── CloudWatch Logs
│   ├── CloudWatch Log Group
│   ├── Log Retention
│   ├── KMS Encryption
│   ├── Resource Policy
│   └── Log Analysis
│
├── 6. DNSSEC
│   │
│   ├── Key Signing Key (KSK)
│   ├── Zone Signing Key (Managed by AWS)
│   ├── Hosted Zone DNSSEC
│   ├── DS Record
│   ├── AWS KMS Integration
│   └── Registrar Configuration
│
├── 7. Traffic Flow
│   │
│   ├── Traffic Policies
│   ├── Traffic Policy Records
│   ├── Traffic Policy Versions
│   └── Traffic Policy Instances
│
├── 8. Route 53 Resolver
│   │
│   ├── Inbound Resolver Endpoint
│   ├── Outbound Resolver Endpoint
│   ├── Resolver Rules
│   │   ├── Forward Rule
│   │   ├── System Rule
│   │   ├── Recursive Rule
│   │   └── Delegation Rule
│   │
│   ├── Resolver Rule Associations
│   ├── Resolver Query Logging
│   ├── Query Log Associations
│   │
│   ├── DNS Firewall
│   │   ├── Domain Lists
│   │   ├── Rule Groups
│   │   ├── Firewall Rules
│   │   └── Rule Group Associations
│   │
│   └── Hybrid DNS
│
├── 9. Route 53 Profiles
│   │
│   ├── DNS Profiles
│   ├── Profile Associations
│   ├── Resource Associations
│   ├── Shared Private Hosted Zones
│   ├── Shared Resolver Rules
│   └── Shared DNS Firewall
│
├── 10. Domain Registration
│   │
│   ├── Register Domain
│   ├── Transfer Domain
│   ├── Renew Domain
│   ├── Auto Renewal
│   ├── Contact Information
│   ├── WHOIS Privacy Protection
│   ├── Name Servers
│   ├── DNSSEC (DS Record)
│   └── Domain Lock
│
├── 11. Monitoring & Security
│   │
│   ├── Amazon CloudWatch Metrics
│   ├── Amazon CloudWatch Alarms
│   ├── AWS CloudTrail
│   ├── AWS Config
│   ├── IAM Policies
│   ├── AWS KMS
│   ├── Resolver Query Logs
│   └── Security Auditing
│
├── 12. AWS Integrations
│   │
│   ├── Application Load Balancer (ALB)
│   ├── Network Load Balancer (NLB)
│   ├── Gateway Load Balancer (GWLB)
│   ├── Amazon CloudFront
│   ├── Amazon API Gateway
│   ├── Amazon S3 Static Website Hosting
│   ├── Amazon EC2
│   ├── Amazon ECS
│   ├── Amazon EKS
│   ├── AWS Lambda Function URLs
│   ├── AWS Global Accelerator
│   ├── AWS PrivateLink
│   ├── Amazon VPC Endpoints
│   └── On-Premises DNS Servers
│
└── 13. Terraform Resources
    │
    ├── aws_route53_zone
    ├── aws_route53_zone_association
    ├── aws_route53_vpc_association_authorization
    ├── aws_route53_record
    ├── aws_route53_health_check
    ├── aws_route53_query_log
    ├── aws_route53_key_signing_key
    ├── aws_route53_hosted_zone_dnssec
    ├── aws_route53_traffic_policy
    ├── aws_route53_traffic_policy_instance
    ├── aws_route53_resolver_endpoint
    ├── aws_route53_resolver_rule
    ├── aws_route53_resolver_rule_association
    ├── aws_route53_resolver_query_log_config
    ├── aws_route53_resolver_query_log_config_association
    ├── aws_route53_resolver_dns_firewall_domain_list
    ├── aws_route53_resolver_dns_firewall_rule_group
    ├── aws_route53_resolver_firewall_rule_group_association
    ├── aws_route53_profile
    ├── aws_route53_profile_association
    └── aws_route53_profile_resource_association
```
