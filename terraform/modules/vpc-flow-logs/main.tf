resource "aws_kms_key" "flow_logs" {
  description             = "KMS key for RoboShop VPC Flow Logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.flow_logs_kms.json
  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
  }
}

resource "aws_kms_alias" "flow_logs" {
  name          = "alias/${var.project_name}-${var.environment}-vpc-flow-logs"
  target_key_id = aws_kms_key.flow_logs.key_id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "flow_logs_kms" {
  statement {
    sid    = "EnableRootAccountPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchLogsUseOfKey"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/${var.project_name}/${var.environment}/flow-logs"
      ]
    }
  }
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/${var.project_name}/${var.environment}/flow-logs"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = aws_kms_key.flow_logs.arn

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
  }
}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"
      ]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  name               = "${var.project_name}-${var.environment}-vpc-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role.json

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
  }
}



data "aws_iam_policy_document" "flow_logs_to_cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "flow_logs_to_cloudwatch" {
  name   = "${var.project_name}-${var.environment}-vpc-flow-logs-write"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs_to_cloudwatch.json
}

resource "aws_flow_log" "vpc" {
  iam_role_arn         = aws_iam_role.flow_logs.arn
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id

  depends_on = [
    aws_iam_role_policy.flow_logs_to_cloudwatch
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
  }
}
