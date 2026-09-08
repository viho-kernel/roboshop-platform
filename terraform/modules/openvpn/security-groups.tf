resource "aws_security_group" "openvpn" {
  name        = "${var.project_name}-${var.environment}-openvpn"
  description = "Controls access to the OpenVPN gateway."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-openvpn"
  }
}

resource "aws_vpc_security_group_ingress_rule" "openvpn_udp" {
  for_each = toset(var.allowed_vpn_ingress_cidrs)

  security_group_id = aws_security_group.openvpn.id
  description       = "Allow OpenVPN connections from approved client network."
  cidr_ipv4         = each.value
  from_port         = 1194
  to_port           = 1194
  ip_protocol       = "udp"
}

resource "aws_vpc_security_group_egress_rule" "openvpn_all" {
  security_group_id = aws_security_group.openvpn.id
  description       = "Allow required outbound connectivity from OpenVPN gateway."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
