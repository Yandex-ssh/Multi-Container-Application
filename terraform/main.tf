terraform {
  required_version = ">= 1.0.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  # Connects to the local docker socket by default
}

# Network to allow containers to communicate
resource "docker_network" "todo_network" {
  name = "todo-network"
}

# Persistent volume for MongoDB data
resource "docker_volume" "mongo_volume" {
  name = "todo-mongo-volume"
}

# MongoDB Image
resource "docker_image" "mongo_image" {
  name = "mongo:latest"
}

# Build Todo API image from local source code
resource "docker_image" "api_image" {
  name = "todo-api:latest"
  build {
    context = "../todo-api"
  }
}

# MongoDB Container
resource "docker_container" "mongo_container" {
  name  = "todo-mongo"
  image = docker_image.mongo_image.image_id

  networks_advanced {
    name    = docker_network.todo_network.name
    aliases = ["mongo"] # Enables routing via http://mongo:27017
  }

  ports {
    internal = 27017
    external = var.mongo_port
  }

  volumes {
    volume_name    = docker_volume.mongo_volume.name
    container_path = "/data/db"
  }

  restart = "unless-stopped"
}

# API Container
resource "docker_container" "api_container" {
  name  = "todo-api"
  image = docker_image.api_image.image_id

  networks_advanced {
    name = docker_network.todo_network.name
  }

  ports {
    internal = 3000
    external = var.api_port
  }

  env = [
    "MONGO_URI=mongodb://mongo:27017/todos"
  ]

  # Mount local source code directory to reflect edits immediately
  volumes {
    host_path      = abspath("${path.module}/../todo-api")
    container_path = "/app"
  }

  # Anonymous volume for node_modules to avoid host overrides
  volumes {
    container_path = "/app/node_modules"
  }

  restart = "unless-stopped"

  depends_on = [
    docker_container.mongo_container
  ]
}