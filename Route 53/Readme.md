Route 53 Terraform Resources
│
├── Hosted Zones
│   ├── aws_route53_zone
│   ├── aws_route53_zone_association
│   └── aws_route53_vpc_association_authorization
│
├── DNS Records
│   └── aws_route53_record
│
├── Health Checks
│   └── aws_route53_health_check
│
├── Query Logging
│   └── aws_route53_query_log
│
├── DNSSEC
│   ├── aws_route53_key_signing_key
│   └── aws_route53_hosted_zone_dnssec
│
├── Traffic Policies
│   ├── aws_route53_traffic_policy
│   └── aws_route53_traffic_policy_instance
│
├── Resolver
│   ├── aws_route53_resolver_endpoint
│   ├── aws_route53_resolver_rule
│   ├── aws_route53_resolver_rule_association
│   ├── aws_route53_resolver_query_log_config
│   └── aws_route53_resolver_query_log_config_association
│
├── DNS Firewall
│   ├── aws_route53_resolver_dns_firewall_domain_list
│   ├── aws_route53_resolver_dns_firewall_rule_group
│   └── aws_route53_resolver_firewall_rule_group_association
│
└── Profiles
    ├── aws_route53_profile
    ├── aws_route53_profile_association
    └── aws_route53_profile_resource_association
