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

resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus.image_id

  volumes {
    host_path      = "${path.cwd}/prometheus/prometheus.yml"
    container_path = "/etc/prometheus/prometheus.yml"
  }

  ports {
    internal = 9090
    external = 9090
  }

  networks_advanced {
    name = docker_network.devops_network.name
  }
}

resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.image_id

  ports {
    internal = 3000
    external = 3000
  }

  networks_advanced {
    name = docker_network.devops_network.name
  }
}
