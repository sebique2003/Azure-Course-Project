locals {
    prefix = "Iordache"
}

terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "=3.0.0"
        }
    }
}

provider "azurerm" {
    features {}
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
    name     = "${local.prefix}-resource-group"
    location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
    name                = "${local.prefix}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
    name                 = "${local.prefix}-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vm_public_ip" {
    count               =  var.vm_count
    name                = "${local.prefix}-public-ip-${count.index}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_network_interface" "main" {
    count               = var.vm_count
    name = "${local.prefix}-nic-${count.index}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "${local.prefix}-ip-config"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.vm_public_ip[count.index].id
    }
}

resource "azurerm_network_security_group" "vm_allow_ports" {
    name                = "${local.prefix}-network-security-group"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

security_rule {
    name                       = "allow_ports_vm"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
    count                     = var.vm_count
    network_interface_id      = azurerm_network_interface.main[count.index].id
    network_security_group_id = azurerm_network_security_group.vm_allow_ports.id
}

resource "azurerm_virtual_machine" "main" {
    count                = var.vm_count
    name                  = "${local.prefix}-linux-vm-${count.index}"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.main[count.index].id]
    vm_size               = var.vm_size


delete_os_disk_on_termination = true
delete_data_disks_on_termination = true

storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = var.vm_image
    version   = "latest"
    }
storage_os_disk {
    name              = "${local.prefix}-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    }
os_profile {
    computer_name  = "${local.prefix}-vm-${count.index}"
    admin_username = var.vm_username
    admin_password = var.vm_password
    }
os_profile_linux_config {
    disable_password_authentication = false
    }
}

resource "null_resource" "ping_test" {
    depends_on = [azurerm_virtual_machine.main]

    provisioner "remote-exec" {
        connection {
        type     = "ssh"
        user     = var.vm_username
        password = var.vm_password
        host     = azurerm_public_ip.vm_public_ip[0].ip_address
        }

        inline = [
        "ping -c 4 ${azurerm_network_interface.main[1].private_ip_address}"
        ]
    }
}




