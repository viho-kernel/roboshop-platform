data "aws_iam_policy_document" "openvpn_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "openvpn" {
  name               = "${var.project_name}-${var.environment}-openvpn"
  assume_role_policy = data.aws_iam_policy_document.openvpn_assume_role.json

  tags = {
    Name = "${var.project_name}-${var.environment}-openvpn"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.openvpn.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "openvpn" {
  name = "${var.project_name}-${var.environment}-openvpn"
  role = aws_iam_role.openvpn.name
}
