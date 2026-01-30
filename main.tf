terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Docker network
resource "docker_network" "devops_network" {
  name = "devops_network"
}

resource "docker_image" "app_image" {
  name         = "terraform-flask-app"
  build {
    context = "./app"
  }
}

resource "docker_container" "app_container" {
  name  = "flask_app"
  image = docker_image.app_image.image_id

  ports {
    internal = 5000
    external = 5000
  }

  networks_advanced {
    name = docker_network.devops_network.name
  }
}
