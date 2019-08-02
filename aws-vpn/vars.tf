variable "region" {
  description = "London's region"
  default = "eu-west-2"
}

variable "google_region" {
  default = "europe-west2"
}

variable "vm_name" {
  default = "uk-vpn"
}

variable "google_project_id" {
  description = "Project ID in GCP"
  default     = "hybrid-lore-228011"
}