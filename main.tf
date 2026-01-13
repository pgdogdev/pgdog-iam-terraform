data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Trust policy document
data "aws_iam_policy_document" "trust_policy" {
  statement {
    sid     = "AllowPgDogAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.pgdog_account_id}:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

# Role policy document
data "aws_iam_policy_document" "role_policy" {
  statement {
    sid    = "EKSClusterAccessForAuthAndKubectl"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:AccessKubernetesApi",
      "eks:ListNodegroups",
      "eks:ListFargateProfiles",
      "eks:ListUpdates"
    ]
    resources = ["arn:aws:eks:${var.aws_region}:${local.account_id}:cluster/${var.eks_cluster_name}"]
  }

  statement {
    sid       = "EKSNodegroupDescribe"
    effect    = "Allow"
    actions   = ["eks:DescribeNodegroup"]
    resources = ["arn:aws:eks:${var.aws_region}:${local.account_id}:nodegroup/${var.eks_cluster_name}/*/*"]
  }

  statement {
    sid       = "EKSFargateProfileDescribe"
    effect    = "Allow"
    actions   = ["eks:DescribeFargateProfile"]
    resources = ["arn:aws:eks:${var.aws_region}:${local.account_id}:fargateprofile/${var.eks_cluster_name}/*"]
  }

  statement {
    sid       = "EKSUpdateDescribe"
    effect    = "Allow"
    actions   = ["eks:DescribeUpdate"]
    resources = ["arn:aws:eks:${var.aws_region}:${local.account_id}:update/${var.eks_cluster_name}/*"]
  }

  statement {
    sid    = "EksctlCloudFormationLifecycle"
    effect = "Allow"
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:UpdateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:DescribeStackEvents",
      "cloudformation:ListStackResources",
      "cloudformation:DescribeStackResources"
    ]
    resources = ["arn:aws:cloudformation:*:${local.account_id}:stack/eksctl-${var.eks_cluster_name}-*/*"]
  }

  statement {
    sid       = "AllowPassingOnlyClusterRolesToEKS"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${local.account_id}:role/eksctl-${var.eks_cluster_name}-*",
      "arn:aws:iam::${local.account_id}:role/${var.eks_cluster_name}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com"]
    }
  }

  statement {
    sid    = "RDSFullControlOnlyThatDB"
    effect = "Allow"
    actions = [
      "rds:ListTagsForResource",
      "rds:ModifyDBInstance",
      "rds:RebootDBInstance",
      "rds:StartDBInstance",
      "rds:StopDBInstance"
    ]
    resources = ["arn:aws:rds:${var.aws_region}:${local.account_id}:db:${var.rds_database_name}"]
  }

  statement {
    sid    = "RDSDescribeAccountScoped"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:DescribeDBParameters",
      "rds:DescribeDBSnapshots"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Route53OnlyThatHostedZone"
    effect = "Allow"
    actions = [
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/${var.route53_hosted_zone_id}"]
  }

  statement {
    sid       = "BasicIdentityForTooling"
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

# Permission boundary policy document
data "aws_iam_policy_document" "permission_boundary" {
  statement {
    sid       = "DenyOutsideRegion"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringNotEqualsIfExists"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid     = "AllowEKSOnlyThatCluster"
    effect  = "Allow"
    actions = ["eks:*"]
    resources = [
      "arn:aws:eks:${var.aws_region}:${var.pgdog_account_id}:cluster/${var.eks_cluster_name}",
      "arn:aws:eks:${var.aws_region}:${var.pgdog_account_id}:nodegroup/${var.eks_cluster_name}/*/*",
      "arn:aws:eks:${var.aws_region}:${var.pgdog_account_id}:fargateprofile/${var.eks_cluster_name}/*",
      "arn:aws:eks:${var.aws_region}:${var.pgdog_account_id}:update/${var.eks_cluster_name}/*"
    ]
  }

  statement {
    sid       = "AllowRDSOnlyThatDatabase"
    effect    = "Allow"
    actions   = ["rds:*"]
    resources = ["arn:aws:rds:${var.aws_region}:${var.pgdog_account_id}:db:${var.rds_database_name}"]
  }

  statement {
    sid    = "AllowRDSDescribeAccountScoped"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:DescribeDBParameters",
      "rds:DescribeDBSnapshots"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowRoute53OnlyThatZone"
    effect    = "Allow"
    actions   = ["route53:*"]
    resources = ["arn:aws:route53:::hostedzone/${var.route53_hosted_zone_id}"]
  }

  statement {
    sid    = "AllowEksctlCloudFormationStacks"
    effect = "Allow"
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:UpdateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:DescribeStackEvents",
      "cloudformation:ListStackResources",
      "cloudformation:DescribeStackResources"
    ]
    resources = ["arn:aws:cloudformation:*:${var.pgdog_account_id}:stack/eksctl-${var.eks_cluster_name}-*/*"]
  }

  statement {
    sid       = "AllowPassRoleToEKSOnly"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${var.pgdog_account_id}:role/eksctl-${var.eks_cluster_name}-*",
      "arn:aws:iam::${var.pgdog_account_id}:role/${var.eks_cluster_name}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com"]
    }
  }

  statement {
    sid    = "UnavoidableReadOnlyAccountScopedAPIs"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "eks:ListClusters",
      "eks:DescribeCluster",
      "cloudformation:ListStacks",
      "cloudformation:DescribeStacks",
      "cloudformation:ListStackResources",
      "cloudformation:DescribeStackResources",
      "iam:GetRole",
      "iam:ListRoles",
      "iam:ListOpenIDConnectProviders",
      "iam:GetOpenIDConnectProvider"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ExplicitDenyAccountAndIAMAdmin"
    effect = "Deny"
    actions = [
      "iam:Create*",
      "iam:Delete*",
      "iam:Update*",
      "iam:Put*",
      "iam:Attach*",
      "iam:Detach*",
      "iam:Set*",
      "iam:Add*",
      "iam:Remove*",
      "organizations:*",
      "account:*",
      "sso:*",
      "sso-directory:*",
      "kms:Delete*",
      "kms:DisableKey",
      "kms:ScheduleKeyDeletion",
      "kms:PutKeyPolicy"
    ]
    resources = ["*"]
  }
}

# Permission boundary policy
resource "aws_iam_policy" "permission_boundary" {
  name        = "${var.role_name}-permission-boundary"
  description = "Permission boundary for PgDog client-hosted role"
  policy      = data.aws_iam_policy_document.permission_boundary.json
  tags        = var.tags
}

# IAM role
resource "aws_iam_role" "pgdog" {
  name                 = var.role_name
  assume_role_policy   = data.aws_iam_policy_document.trust_policy.json
  permissions_boundary = aws_iam_policy.permission_boundary.arn
  tags                 = var.tags
}

# Inline policy attached to the role
resource "aws_iam_role_policy" "pgdog" {
  name   = "${var.role_name}-policy"
  role   = aws_iam_role.pgdog.id
  policy = data.aws_iam_policy_document.role_policy.json
}
