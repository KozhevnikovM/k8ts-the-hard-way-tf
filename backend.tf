terraform {
  backend "remote" {
    organization = "example-org-883e22"

    workspaces {
      name = "k8s-the-hard-way"
    }
  }
}