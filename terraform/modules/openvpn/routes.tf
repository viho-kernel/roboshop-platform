resource "aws_route" "vpn_client_return" {
  for_each = toset(var.private_route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = var.vpn_client_cidr
  network_interface_id   = aws_instance.openvpn.primary_network_interface_id
}
