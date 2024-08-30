/*
1. aws_iam_role:
  - This is the basic IAM role resource.
  - It defines who or what can assume the role (via the assume_role_policy).
  - Used for services like EC2, Lambda, or for cross-account access.
2. aws_iam_policy:
  - This resource creates a standalone policy document.
  - It defines a set of permissions that can be attached to roles, users, or groups.
3. aws_iam_role_policy:
  - This attaches an inline policy directly to a role.
  - The policy is defined within this resource and is ** not a standalone policy**.
4. aws_iam_role_policy_attachment:
  - This attaches a standalone policy (either AWS-managed or customer-managed) to a role.
  - It uses the ARN of an existing policy.
5. aws_iam_instance_profile:
  - This is used specifically for EC2 instances.
  - It's a container for an IAM role that can be attached to an EC2 instance.
6. aws_iam_user:
  - This resource creates an IAM user.
7. aws_iam_user_policy:
  - Similar to aws_iam_role_policy, but for users instead of roles.
8. aws_iam_group:
  - This resource creates an IAM group.
9. aws_iam_group_policy:
  - Attaches an inline policy to an IAM group.
10. aws_iam_policy_document:
  - This is a data source (not a resource) used to generate policy documents in JSON format.
*/


terraform {
  required_version = ">= 0.12.0"
}

resource "aws_iam_role" "iam_role" {
  name = var.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = var.name
  role = aws_iam_role.iam_role.name
}

data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    effect = "Allow"
    actions = var.actions
    resources = var.resources
  }
}

resource "aws_iam_role_policy" "iam_role_policy" {
  name = var.name
  role = aws_iam_role.iam_role.name
  policy = data.aws_iam_policy_document.iam_policy_document.json
}

# Attach AmazonSSMManagedInstanceCore policy for accessing to private ec2 using session manager
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


/**
 iams for monitoring + rds monitoring for prometheus server 
*/
# New combined IAM role for monitoring server (Prometheus + RDS Enhanced Monitoring)
resource "aws_iam_role" "monitoring_role" {
  name = "${var.name}-monitoring"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "monitoring.rds.amazonaws.com"]
        }
      }
    ]
  })
}

# New instance profile for the monitoring role
resource "aws_iam_instance_profile" "monitoring_profile" {
  name = "${var.name}-monitoring"
  role = aws_iam_role.monitoring_role.name
}

# Combine Prometheus and RDS Enhanced Monitoring policies
resource "aws_iam_role_policy" "monitoring_role_policy" {
  name = "${var.name}-monitoring"
  role = aws_iam_role.monitoring_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:Describe*", "elasticloadbalancing:Describe*", "autoscaling:Describe*"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach RDS Enhanced Monitoring policy to the combined monitoring role
resource "aws_iam_role_policy_attachment" "monitoring_rds_policy_attachment" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# New: Attach AmazonSSMManagedInstanceCore policy to the monitoring role for Session Manager access
resource "aws_iam_role_policy_attachment" "monitoring_ssm_policy_attachment" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


/*
# iam policy for prometheus monitoring
resource "aws_iam_role_policy" "prometheus_iam_role_policy" {
  name = "prometheus_iam_role_policy"
  role = aws_iam_role.iam_role.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:Describe*",
            "Resource": "*"
        }
    ]
}
 EOF
}

# Create an IAM role for RDS Enhanced Monitoring(PMM)
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "rds-enhanced-monitoring-role-for-pmm"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the necessary policy to the IAM role
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_enhanced_monitoring.name
}
*/