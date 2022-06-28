resource "azurerm_network_interface" "nic3" {
    name                = "${var.prefix}-nic3"
    location            = "${var.region}"
    resource_group_name = "${var.prefix}-RG"

    ip_configuration {
        name                          = "nic3-ip"
        subnet_id                     = azurerm_subnet.subnet3.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicip3.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface_security_group_association" "nic-nsg-association3" {
  network_interface_id      = azurerm_network_interface.nic3.id
  network_security_group_id = azurerm_network_security_group.this.id
}