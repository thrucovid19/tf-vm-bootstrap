variable "authcode" {
}

variable "bootstrap_s3bucket" {
  default = "vmseries-bootstrap"
}

variable "panorama1" {
  type = string
  description = "Primary Panorama IP address" 
}

variable "panorama2" {
  type = string
  description = "Secondary Panorama IP address" 
}

variable "template" {
  type = string
  description = "Panorama template"
}

variable "devicegroup" {
  type = string
  description = "Panorama device group"
}

variable "panorama_bootstrap_key" {
  type = string
  description = "Panorama bootstrap key"
}

variable "hostname" {
  type = string
  description = "Hostname for the firewall"
}