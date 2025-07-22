# This file contains variable definitions for the Terraform configuration.
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

# Variable for the virtual machine name
variable "vm_username" {
    type        = string
}

variable "vm_password" {}

variable "vm_count" {
    type    = number
    default = 2
}

variable "vm_size" {
    type    = string
    default = "Standard_B1s"
}

variable "vm_image" {
    type    = string
    default = "22_04-lts"
}
