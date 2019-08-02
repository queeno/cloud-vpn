provider "aws" {
  region      = var.region
}

provider "google" {
  project     = var.google_project_id
  region      = var.google_region
  credentials = file("account.json")
}
