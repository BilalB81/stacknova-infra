# Image Nginx avec version épinglée (jamais "latest")
resource "docker_image" "nginx" {
  name         = "nginx:1.25.3"
  keep_locally = false
}

# Conteneur de recette exposé sur le port 8080
resource "docker_container" "stacknova_recette" {
  name  = "stacknova-recette"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8080
  }

  labels {
    label = "env"
    value = "recette"
  }
  labels {
    label = "project"
    value = "stacknova"
  }
  labels {
    label = "managed-by"
    value = "terraform"
  }

  restart = "unless-stopped"
}
