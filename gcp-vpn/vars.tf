variable "project_id" {
  description = "Project ID in GCP"
  default     = "hybrid-lore-228011"
}

variable "region" {
  description = "London's region"
  default = "europe-west2"
}

variable "ssh_pub_key_file" {
  default = "~/.ssh/id_rsa.pub"
}

variable "vm_name" {
  default = "uk-vpn"
}