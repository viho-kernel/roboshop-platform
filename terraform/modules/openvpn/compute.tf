resource "aws_instance" "openvpn" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.openvpn.id]
  iam_instance_profile   = aws_iam_instance_profile.openvpn.name

  user_data = templatefile(
    "${path.module}/templates/openvpn-bootstrap.sh.tftpl",
    {
      vpn_client_network = cidrhost(var.vpn_client_cidr, 0)
      vpn_client_netmask = cidrnetmask(var.vpn_client_cidr)
      vpc_network        = cidrhost(data.aws_vpc.current.cidr_block, 0)
      vpc_netmask        = cidrnetmask(data.aws_vpc.current.cidr_block)
    }
  )

  user_data_replace_on_change = true

  associate_public_ip_address = false
  source_dest_check           = false

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-openvpn"
  }
}

resource "aws_eip" "openvpn" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-openvpn"
  }
}

resource "aws_eip_association" "openvpn" {
  allocation_id = aws_eip.openvpn.id
  instance_id   = aws_instance.openvpn.id
}
