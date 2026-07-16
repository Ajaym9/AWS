terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # required for most Route 53 global/domain examples; use regional aliases for Resolver where needed
}

locals {
  domain_name    = "example.com"
  private_domain = "internal.example.com"
  vpc_id         = "vpc-0123456789abcdef0"
  vpc_region     = "us-east-1"
  account_id     = "123456789012"
  alarm_region   = "us-east-1"
  kms_key_arn    = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
  log_group_arn  = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/query-logs"
  sns_topic_arn  = "arn:aws:sns:us-east-1:123456789012:route53-alerts"
  resolver_sg_id = "sg-0123456789abcdef0"
  subnet_a_id    = "subnet-0123456789abcdef0"
  subnet_b_id    = "subnet-abcdef01234567890"

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Service     = "route53"
  }
}

# -----------------------------------------------------------------------------
# Hosted Zones
# -----------------------------------------------------------------------------

resource "aws_route53_delegation_set" "prod" {
  reference_name = "prod-reusable-delegation-set" # optional: human reference name for reusable name servers
}

resource "aws_route53_zone" "public" {
  name              = local.domain_name                  # required: DNS zone name
  comment           = "Production public hosted zone"    # optional: hosted zone comment
  delegation_set_id = aws_route53_delegation_set.prod.id # optional: reusable delegation set ID for public zones
  force_destroy     = false                              # optional: allow destroying non-empty zone when true

  tags = local.tags # optional: resource tags
}

resource "aws_route53_zone" "private" {
  name          = local.private_domain             # required: DNS zone name
  comment       = "Production private hosted zone" # optional: hosted zone comment
  force_destroy = false                            # optional: allow destroying non-empty zone when true

  vpc {                           # optional: required when initially creating a private hosted zone
    vpc_id     = local.vpc_id     # required in vpc block: VPC ID
    vpc_region = local.vpc_region # optional: VPC region
  }

  tags = local.tags # optional: resource tags
}

resource "aws_route53_zone_association" "private_primary_vpc" {
  zone_id    = aws_route53_zone.private.zone_id # required: private hosted zone ID
  vpc_id     = local.vpc_id                     # required: VPC ID to associate
  vpc_region = local.vpc_region                 # optional: VPC region
}

resource "aws_route53_vpc_association_authorization" "cross_account" {
  zone_id    = aws_route53_zone.private.zone_id # required: private hosted zone ID
  vpc_id     = "vpc-0fedcba9876543210"          # required: external/account VPC ID authorized to associate
  vpc_region = "us-east-1"                      # optional: VPC region
}

# -----------------------------------------------------------------------------
# DNS Records
# -----------------------------------------------------------------------------

resource "aws_route53_record" "apex_a" {
  zone_id         = aws_route53_zone.public.zone_id # required: hosted zone ID
  name            = local.domain_name               # required: record name
  type            = "A"                             # required: DNS record type
  allow_overwrite = true                            # optional: allow existing record overwrite

  alias {                                                                            # optional: use instead of ttl + records for AWS aliases
    name                   = "dualstack.example-alb-123.us-east-1.elb.amazonaws.com" # required in alias: target DNS name
    zone_id                = "Z35SXDOTRQ7X7K"                                        # required in alias: target hosted zone ID
    evaluate_target_health = true                                                    # required in alias: evaluate target health
  }

  health_check_id = aws_route53_health_check.https.id # optional: health check for routing decisions
  set_identifier  = "primary-apex"                    # optional: required for non-simple routing policies

  failover_routing_policy { # optional: PRIMARY/SECONDARY failover policy
    type = "PRIMARY"        # required in failover policy
  }
}

resource "aws_route53_record" "www_weighted" {
  zone_id = aws_route53_zone.public.zone_id      # required
  name    = "www.${local.domain_name}"           # required
  type    = "CNAME"                              # required
  ttl     = 60                                   # required when records is used
  records = ["app-primary.${local.domain_name}"] # required when not using alias

  set_identifier = "www-primary" # optional: required for weighted/latency/geolocation/failover/multivalue records

  weighted_routing_policy { # optional: weighted routing policy
    weight = 100            # required in weighted policy
  }
}

resource "aws_route53_record" "api_latency" {
  zone_id = aws_route53_zone.public.zone_id # required
  name    = "api.${local.domain_name}"      # required
  type    = "A"                             # required

  alias {                                                                        # optional
    name                   = "dualstack.api-alb-123.us-east-1.elb.amazonaws.com" # required in alias
    zone_id                = "Z35SXDOTRQ7X7K"                                    # required in alias
    evaluate_target_health = true                                                # required in alias
  }

  set_identifier = "api-us-east-1" # optional: required for latency policy

  latency_routing_policy { # optional: latency routing policy
    region = "us-east-1"   # required in latency policy
  }
}

resource "aws_route53_record" "geo_example" {
  zone_id = aws_route53_zone.public.zone_id # required
  name    = "geo.${local.domain_name}"      # required
  type    = "A"                             # required
  ttl     = 300                             # required when records is used
  records = ["203.0.113.10"]                # required when not using alias

  set_identifier = "geo-us" # optional: required for geolocation policy

  geolocation_routing_policy { # optional: geolocation routing policy
    country = "US"             # optional: continent, country, or subdivision may be used
  }
}

resource "aws_route53_record" "multi_value" {
  zone_id = aws_route53_zone.public.zone_id # required
  name    = "multi.${local.domain_name}"    # required
  type    = "A"                             # required
  ttl     = 60                              # required when records is used
  records = ["203.0.113.20"]                # required when not using alias

  set_identifier                   = "multi-1"                       # optional: required for multivalue
  multivalue_answer_routing_policy = true                            # optional: enables multivalue answer routing
  health_check_id                  = aws_route53_health_check.tcp.id # optional: health check
}

resource "aws_route53_record" "cidr_example" {
  zone_id = aws_route53_zone.public.zone_id # required
  name    = "cidr.${local.domain_name}"     # required
  type    = "A"                             # required
  ttl     = 300                             # required when records is used
  records = ["203.0.113.30"]                # required when not using alias

  set_identifier = "cidr-default" # optional: required for CIDR routing

  cidr_routing_policy {                                    # optional: CIDR routing policy
    collection_id = "00000000-0000-0000-0000-000000000000" # required in CIDR policy
    location_name = "*"                                    # required in CIDR policy; * is default location
  }
}

# -----------------------------------------------------------------------------
# Health Checks
# -----------------------------------------------------------------------------

resource "aws_route53_health_check" "https" {
  reference_name     = "prod-www-https"           # optional: caller reference/display name
  fqdn               = "www.${local.domain_name}" # optional: endpoint FQDN; use with type HTTP/HTTPS/TCP
  port               = 443                        # optional: endpoint port
  type               = "HTTPS_STR_MATCH"          # required: HTTP, HTTPS, HTTP_STR_MATCH, HTTPS_STR_MATCH, TCP, CALCULATED, CLOUDWATCH_METRIC, RECOVERY_CONTROL
  resource_path      = "/health"                  # optional: path for HTTP/HTTPS checks
  failure_threshold  = 3                          # optional: consecutive failures before unhealthy
  request_interval   = 30                         # optional: check interval, 10 or 30 seconds
  measure_latency    = true                       # optional: measure latency
  invert_healthcheck = false                      # optional: invert check status
  disabled           = false                      # optional: disable health check when true
  enable_sni         = true                       # optional: send SNI for HTTPS checks
  search_string      = "ok"                       # optional: response body string for HTTP_STR_MATCH/HTTPS_STR_MATCH

  regions = ["us-east-1", "us-west-1", "eu-west-1"] # optional: checker regions

  tags = local.tags # optional
}

resource "aws_route53_health_check" "tcp" {
  ip_address        = "203.0.113.20" # optional: endpoint IP address
  port              = 443            # optional: endpoint port
  type              = "TCP"          # required
  failure_threshold = 3              # optional
  request_interval  = 30             # optional

  tags = local.tags # optional
}

resource "aws_route53_health_check" "calculated" {
  type                   = "CALCULATED"                                                         # required
  child_healthchecks     = [aws_route53_health_check.https.id, aws_route53_health_check.tcp.id] # optional: child health check IDs
  child_health_threshold = 1                                                                    # optional: number of healthy children required
  invert_healthcheck     = false                                                                # optional
  disabled               = false                                                                # optional

  tags = local.tags # optional
}

resource "aws_route53_health_check" "cloudwatch_alarm" {
  type                            = "CLOUDWATCH_METRIC"             # required
  cloudwatch_alarm_name           = "prod-route53-origin-unhealthy" # optional/required for CLOUDWATCH_METRIC
  cloudwatch_alarm_region         = local.alarm_region              # optional/required for CLOUDWATCH_METRIC
  insufficient_data_health_status = "LastKnownStatus"               # optional: Healthy, Unhealthy, or LastKnownStatus
  invert_healthcheck              = false                           # optional
  disabled                        = false                           # optional

  triggers = { # optional: sync health check when upstream alarm inputs change
    alarm_name = "prod-route53-origin-unhealthy"
  }

  tags = local.tags # optional
}

resource "aws_route53_health_check" "arc_routing_control" {
  type                = "RECOVERY_CONTROL"                                           # required
  routing_control_arn = aws_route53recoverycontrolconfig_routing_control.primary.arn # optional/required for RECOVERY_CONTROL

  tags = local.tags # optional
}

# -----------------------------------------------------------------------------
# Query Logging
# -----------------------------------------------------------------------------

resource "aws_route53_query_log" "public" {
  zone_id                  = aws_route53_zone.public.zone_id # required: hosted zone ID
  cloudwatch_log_group_arn = local.log_group_arn             # required: CloudWatch Logs log group ARN
}

# -----------------------------------------------------------------------------
# DNSSEC For Hosted Zones And Registered Domains
# -----------------------------------------------------------------------------

resource "aws_route53_key_signing_key" "public" {
  hosted_zone_id             = aws_route53_zone.public.zone_id # required: hosted zone ID
  key_management_service_arn = local.kms_key_arn               # required: KMS asymmetric signing key ARN
  name                       = "prod-ksk"                      # required: key signing key name
  status                     = "ACTIVE"                        # optional: ACTIVE or INACTIVE
}

resource "aws_route53_hosted_zone_dnssec" "public" {
  hosted_zone_id = aws_route53_zone.public.zone_id # required: hosted zone ID

  depends_on = [aws_route53_key_signing_key.public]
}

resource "aws_route53domains_delegation_signer_record" "public" {
  domain_name = local.domain_name # required: registered domain name

  signing_attributes {                                                     # required: DS signing attributes for parent zone
    algorithm  = aws_route53_key_signing_key.public.signing_algorithm_type # required
    flags      = aws_route53_key_signing_key.public.flag                   # required
    public_key = aws_route53_key_signing_key.public.public_key             # required
  }
}

# -----------------------------------------------------------------------------
# Traffic Policies
# -----------------------------------------------------------------------------

resource "aws_route53_traffic_policy" "prod" {
  name    = "prod-policy"               # required: traffic policy name
  comment = "Production traffic policy" # optional: description
  document = jsonencode({               # required: traffic policy JSON document
    AWSPolicyFormatVersion = "2015-10-01"
    RecordType             = "A"
    StartRule              = "primary"
    Endpoints = {
      primary = {
        Type  = "value"
        Value = "203.0.113.10"
      }
    }
    Rules = {
      primary = {
        RuleType = "failover"
        Primary = {
          EndpointReference = "primary"
        }
      }
    }
  })
}

resource "aws_route53_traffic_policy_instance" "prod" {
  hosted_zone_id         = aws_route53_zone.public.zone_id         # required: hosted zone ID
  name                   = "policy.${local.domain_name}"           # required: DNS name
  ttl                    = 60                                      # required: DNS TTL
  traffic_policy_id      = aws_route53_traffic_policy.prod.id      # required: traffic policy ID
  traffic_policy_version = aws_route53_traffic_policy.prod.version # required: traffic policy version
}

# -----------------------------------------------------------------------------
# Resolver Endpoints, Rules, DNSSEC Validation, And Query Logs
# -----------------------------------------------------------------------------

resource "aws_route53_resolver_endpoint" "inbound" {
  name                         = "prod-inbound-resolver" # optional: endpoint name
  direction                    = "INBOUND"               # required: INBOUND or OUTBOUND
  security_group_ids           = [local.resolver_sg_id]  # required: security groups
  protocols                    = ["Do53"]                # optional: Do53, DoH, DoH-FIPS where supported
  resolver_endpoint_type       = "IPV4"                  # optional: IPV4, IPV6, DUALSTACK where supported
  rni_enhanced_metrics_enabled = true                    # optional: enable resolver network interface metrics

  ip_address {                    # required: at least two IP address blocks are recommended/usually required
    subnet_id = local.subnet_a_id # required in block: subnet ID
    ip        = "10.0.1.10"       # optional: static resolver IP
  }

  ip_address {                    # required/recommended second AZ
    subnet_id = local.subnet_b_id # required in block
    ip        = "10.0.2.10"       # optional
  }

  tags = local.tags # optional
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name                               = "prod-outbound-resolver" # optional
  direction                          = "OUTBOUND"               # required
  security_group_ids                 = [local.resolver_sg_id]   # required
  protocols                          = ["Do53"]                 # optional
  target_name_server_metrics_enabled = true                     # optional: outbound endpoint target nameserver metrics

  ip_address {
    subnet_id = local.subnet_a_id # required
  }

  ip_address {
    subnet_id = local.subnet_b_id # required
  }

  tags = local.tags # optional
}

resource "aws_route53_resolver_rule" "forward_corp" {
  domain_name          = "corp.example.com"                        # required: domain to resolve
  rule_type            = "FORWARD"                                 # required: FORWARD, SYSTEM, RECURSIVE
  name                 = "prod-forward-corp"                       # optional: rule name
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id # optional/required for FORWARD rules

  target_ip {           # optional/required for FORWARD rules
    ip   = "10.10.0.10" # required in target_ip: DNS target IP
    port = 53           # optional: DNS target port
  }

  target_ip {
    ip   = "10.10.0.11" # required
    port = 53           # optional
  }

  tags = local.tags # optional
}

resource "aws_route53_resolver_rule_association" "forward_corp" {
  resolver_rule_id = aws_route53_resolver_rule.forward_corp.id # required: resolver rule ID
  vpc_id           = local.vpc_id                              # required: VPC ID
  name             = "prod-forward-corp"                       # optional: association name
}

resource "aws_route53_resolver_dnssec_config" "prod_vpc" {
  resource_id = local.vpc_id # required: VPC ID to enable Resolver DNSSEC validation on
}

resource "aws_route53_resolver_query_log_config" "prod" {
  name            = "prod-resolver-query-logs" # required: config name
  destination_arn = local.log_group_arn        # required: CloudWatch Logs, S3, or Firehose destination ARN

  tags = local.tags # optional
}

resource "aws_route53_resolver_query_log_config_association" "prod_vpc" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.prod.id # required: query log config ID
  resource_id                  = local.vpc_id                                  # required: VPC ID
}

# -----------------------------------------------------------------------------
# DNS Firewall
# -----------------------------------------------------------------------------

resource "aws_route53_resolver_firewall_config" "prod_vpc" {
  resource_id        = local.vpc_id # required: VPC ID
  firewall_fail_open = "DISABLED"   # required: ENABLED favors availability, DISABLED favors security
}

resource "aws_route53_resolver_firewall_domain_list" "blocked" {
  name    = "prod-blocked-domains"          # required: domain list name
  domains = ["malware.example", "bad.test"] # optional: domains; can also be imported/managed externally

  tags = local.tags # optional
}

resource "aws_route53_resolver_firewall_rule_group" "prod" {
  name = "prod-dns-firewall" # required: rule group name

  tags = local.tags # optional
}

resource "aws_route53_resolver_firewall_rule" "block_list" {
  firewall_rule_group_id             = aws_route53_resolver_firewall_rule_group.prod.id     # required: rule group ID
  firewall_domain_list_id            = aws_route53_resolver_firewall_domain_list.blocked.id # optional/required for standard rule
  name                               = "block-known-bad"                                    # required: rule name
  priority                           = 100                                                  # required: lower priority runs first
  action                             = "BLOCK"                                              # required: ALLOW, BLOCK, ALERT
  block_response                     = "NXDOMAIN"                                           # required if action is BLOCK: NODATA, NXDOMAIN, OVERRIDE
  q_type                             = "A"                                                  # optional: DNS query type
  firewall_domain_redirection_action = "INSPECT_REDIRECTION_DOMAIN"                         # optional: redirection handling
}

resource "aws_route53_resolver_firewall_rule" "advanced_dns_tunneling" {
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.prod.id # required
  name                   = "alert-dns-tunneling"                            # required
  priority               = 200                                              # required
  action                 = "ALERT"                                          # required
  dns_threat_protection  = "DNS_TUNNELING"                                  # optional/required for advanced rule
  confidence_threshold   = "HIGH"                                           # optional/required for advanced rule
}

resource "aws_route53_resolver_firewall_rule_group_association" "prod_vpc" {
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.prod.id # required: rule group ID
  vpc_id                 = local.vpc_id                                     # required: VPC ID
  priority               = 100                                              # required: association priority
  name                   = "prod-dns-firewall"                              # required: association name
  mutation_protection    = "ENABLED"                                        # optional: ENABLED or DISABLED

  tags = local.tags # optional
}

# -----------------------------------------------------------------------------
# Route 53 Profiles
# Terraform resource prefix is aws_route53profiles_*, not aws_route53_profile_*.
# -----------------------------------------------------------------------------

resource "aws_route53profiles_profile" "prod" {
  name = "prod-route53-profile" # required: profile name
  tags = local.tags             # optional
}

resource "aws_route53profiles_association" "prod_vpc" {
  name        = "prod-profile-vpc"                  # required: association name
  profile_id  = aws_route53profiles_profile.prod.id # required: Route 53 Profile ID
  resource_id = local.vpc_id                        # required: VPC ID
  tags        = local.tags                          # optional
}

resource "aws_route53profiles_resource_association" "private_zone" {
  name                = "prod-private-zone"                 # required: resource association name
  profile_id          = aws_route53profiles_profile.prod.id # required: Route 53 Profile ID
  resource_arn        = aws_route53_zone.private.arn        # required: resource ARN to associate
  resource_properties = jsonencode({})                      # optional: resource-specific association properties
}

# -----------------------------------------------------------------------------
# Route 53 Domains / Registrar
# Use only if AWS manages the registered domain. For existing domains, prefer
# aws_route53domains_registered_domain. For Terraform-managed registration,
# use aws_route53domains_domain.
# -----------------------------------------------------------------------------

resource "aws_route53domains_registered_domain" "existing" {
  domain_name   = local.domain_name # required: already-registered domain name
  auto_renew    = true              # optional: auto renew domain
  transfer_lock = true              # optional: lock domain against transfer

  admin_privacy      = true # optional: conceal admin contact from WHOIS
  registrant_privacy = true # optional: conceal registrant contact from WHOIS
  tech_privacy       = true # optional: conceal tech contact from WHOIS
  billing_privacy    = true # optional: conceal billing contact from WHOIS

  name_server {                                        # optional: authoritative nameserver
    name     = aws_route53_zone.public.name_servers[0] # required in block
    glue_ips = []                                      # optional: glue IPs
  }

  tags = local.tags # optional
}

resource "aws_route53domains_domain" "new_registration" {
  domain_name       = "new-example-registration.com" # required: domain to register/manage
  duration_in_years = 1                              # optional: registration/renewal duration
  auto_renew        = true                           # optional
  transfer_lock     = true                           # optional

  admin_privacy      = true # optional
  registrant_privacy = true # optional
  tech_privacy       = true # optional
  billing_privacy    = true # optional

  admin_contact {                               # required for new registration
    first_name        = "Platform"              # optional contact field
    last_name         = "Team"                  # optional contact field
    contact_type      = "COMPANY"               # optional contact field
    organization_name = "Example Inc"           # optional contact field
    address_line_1    = "100 Main St"           # optional contact field
    city              = "Seattle"               # optional contact field
    state             = "WA"                    # optional contact field
    country_code      = "US"                    # optional contact field
    zip_code          = "98101"                 # optional contact field
    phone_number      = "+1.2065550100"         # optional contact field
    email             = "dns-admin@example.com" # optional contact field
  }

  registrant_contact { # required for new registration
    first_name        = "Platform"
    last_name         = "Team"
    contact_type      = "COMPANY"
    organization_name = "Example Inc"
    address_line_1    = "100 Main St"
    city              = "Seattle"
    state             = "WA"
    country_code      = "US"
    zip_code          = "98101"
    phone_number      = "+1.2065550100"
    email             = "dns-admin@example.com"
  }

  tech_contact { # required for new registration
    first_name        = "Platform"
    last_name         = "Team"
    contact_type      = "COMPANY"
    organization_name = "Example Inc"
    address_line_1    = "100 Main St"
    city              = "Seattle"
    state             = "WA"
    country_code      = "US"
    zip_code          = "98101"
    phone_number      = "+1.2065550100"
    email             = "dns-admin@example.com"
  }

  billing_contact { # optional billing contact
    first_name        = "Billing"
    last_name         = "Team"
    contact_type      = "COMPANY"
    organization_name = "Example Inc"
    address_line_1    = "100 Main St"
    city              = "Seattle"
    state             = "WA"
    country_code      = "US"
    zip_code          = "98101"
    phone_number      = "+1.2065550101"
    email             = "billing@example.com"
  }

  tags = local.tags # optional
}

# -----------------------------------------------------------------------------
# Route 53 ARC - Recovery Control Config
# -----------------------------------------------------------------------------

resource "aws_route53recoverycontrolconfig_cluster" "prod" {
  name = "prod-arc-cluster" # required: ARC cluster name

  tags = local.tags # optional
}

resource "aws_route53recoverycontrolconfig_control_panel" "prod" {
  name        = "prod-control-panel"                              # required: control panel name
  cluster_arn = aws_route53recoverycontrolconfig_cluster.prod.arn # required: ARC cluster ARN

  tags = local.tags # optional
}

resource "aws_route53recoverycontrolconfig_routing_control" "primary" {
  name              = "primary-region"                                        # required: routing control name
  cluster_arn       = aws_route53recoverycontrolconfig_cluster.prod.arn       # required: ARC cluster ARN
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.prod.arn # optional: control panel ARN
}

resource "aws_route53recoverycontrolconfig_routing_control" "secondary" {
  name              = "secondary-region"                                      # required
  cluster_arn       = aws_route53recoverycontrolconfig_cluster.prod.arn       # required
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.prod.arn # optional
}

resource "aws_route53recoverycontrolconfig_safety_rule" "at_least_one_region" {
  name              = "at-least-one-region"                                   # required: safety rule name
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.prod.arn # required: control panel ARN
  wait_period_ms    = 5000                                                    # required: evaluation wait period in ms

  rule_config {           # required: safety rule criteria
    inverted  = false     # required in block: negate rule result when true
    threshold = 1         # required in block: number of controls for ATLEAST
    type      = "ATLEAST" # required in block: ATLEAST, AND, OR
  }

  asserted_controls = [ # optional: assertion-rule controls evaluated before state changes
    aws_route53recoverycontrolconfig_routing_control.primary.arn,
    aws_route53recoverycontrolconfig_routing_control.secondary.arn
  ]

  gating_controls = [ # optional: gating-rule controls that must evaluate true
    aws_route53recoverycontrolconfig_routing_control.primary.arn
  ]

  target_controls = [ # optional: controls protected by gating_controls
    aws_route53recoverycontrolconfig_routing_control.secondary.arn
  ]

  tags = local.tags # optional
}

# -----------------------------------------------------------------------------
# Route 53 ARC - Recovery Readiness
# -----------------------------------------------------------------------------

resource "aws_route53recoveryreadiness_cell" "primary" {
  cell_name = "primary-cell" # required: cell name
  tags      = local.tags     # optional
}

resource "aws_route53recoveryreadiness_cell" "secondary" {
  cell_name = "secondary-cell" # required
  tags      = local.tags       # optional
}

resource "aws_route53recoveryreadiness_recovery_group" "prod" {
  recovery_group_name = "prod-recovery-group" # required: recovery group name
  cells = [                                   # optional: cell ARNs in recovery group
    aws_route53recoveryreadiness_cell.primary.arn,
    aws_route53recoveryreadiness_cell.secondary.arn
  ]
  tags = local.tags # optional
}

resource "aws_route53recoveryreadiness_resource_set" "dns_targets" {
  resource_set_name = "prod-dns-targets"          # required: resource set name
  resource_set_type = "AWS::Route53::HealthCheck" # required: supported readiness resource type

  resources {                                                          # required: one or more resources
    resource_arn     = aws_route53_health_check.https.arn              # optional/one-of resource identifier
    readiness_scopes = [aws_route53recoveryreadiness_cell.primary.arn] # optional: recovery group/cell scope
  }

  tags = local.tags # optional
}

resource "aws_route53recoveryreadiness_readiness_check" "dns_targets" {
  readiness_check_name = "prod-dns-targets"                                                      # required: readiness check name
  resource_set_name    = aws_route53recoveryreadiness_resource_set.dns_targets.resource_set_name # required: resource set name

  tags = local.tags # optional
}

# -----------------------------------------------------------------------------
# Production Supporting Resources Commonly Needed With Route 53
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "route53_query_logs" {
  name              = "/aws/route53/query-logs" # required: log group name
  retention_in_days = 365                       # optional: retention period
  kms_key_id        = local.kms_key_arn         # optional: encrypt logs with KMS
  tags              = local.tags                # optional
}

resource "aws_cloudwatch_metric_alarm" "route53_health_check" {
  alarm_name          = "prod-route53-health-check-unhealthy" # required: alarm name
  comparison_operator = "LessThanThreshold"                   # required
  evaluation_periods  = 1                                     # required
  metric_name         = "HealthCheckStatus"                   # required
  namespace           = "AWS/Route53"                         # required
  period              = 60                                    # required
  statistic           = "Minimum"                             # required
  threshold           = 1                                     # required
  alarm_description   = "Route 53 health check is unhealthy"  # optional
  alarm_actions       = [local.sns_topic_arn]                 # optional
  treat_missing_data  = "breaching"                           # optional

  dimensions = { # optional: dimensions for Route 53 health check metric
    HealthCheckId = aws_route53_health_check.https.id
  }

  tags = local.tags # optional
}



