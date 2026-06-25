# Multi-Container Todo Application

> A production-style REST API built with Node.js, MongoDB, Docker, Ansible, Terraform, and GitHub Actions — demonstrating a real-world DevOps deployment pipeline.

![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat-square&logo=node.js&logoColor=white)
![Express](https://img.shields.io/badge/Express-000000?style=flat-square&logo=express&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=flat-square&logo=mongodb&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat-square&logo=ansible&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat-square&logo=nginx&logoColor=white)

---

## Overview

This project demonstrates a complete DevOps lifecycle for a containerized backend application. It covers writing the API, packaging it with Docker, orchestrating containers with Docker Compose, provisioning infrastructure with Terraform, configuring a remote server with Ansible, and automating the entire deployment through a GitHub Actions CI/CD pipeline.

The API manages todo items stored in MongoDB. All components run as isolated Docker containers that communicate over a shared network, with Nginx acting as a reverse proxy in production.

---

## Features

- **Full CRUD** — Create, read, update, and delete todo items
- **MongoDB persistence** — Data survives container restarts via named volumes
- **Multi-container architecture** — API and database run as separate, networked containers
- **Two deployment paths** — Docker Compose (simple) or Terraform (infrastructure-as-code)
- **Automated CI/CD** — GitHub Actions builds, pushes, and deploys on every push to `main`
- **Remote server provisioning** — Ansible installs Docker and bootstraps the production server
- **Reverse proxy** — Nginx sits in front of the Node.js API in production
- **Secure tunneling** — Tailscale connects GitHub Actions to a private VM without exposing SSH to the internet

---

## Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js |
| Framework | Express.js |
| Database | MongoDB + Mongoose |
| Containerization | Docker, Docker Compose |
| Infrastructure as Code | Terraform (kreuzwerker/docker provider) |
| Configuration Management | Ansible |
| CI/CD | GitHub Actions |
| Image Registry | Docker Hub |
| Reverse Proxy | Nginx |
| Server OS | Ubuntu Linux |
| Secure Tunnel | Tailscale |

---

## Project Structure

```text
Multi-Container Application/
│
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline definition
│
├── ansible/
│   ├── deploy.yml              # Playbook — installs Docker, copies files, starts containers
│   ├── inventory.ini           # Target host configuration
│   └── files/
│       ├── docker-compose.yml  # Production Compose file deployed to the server
│       └── .env                # Environment variables deployed to the server
│
├── terraform/
│   ├── main.tf                 # Container, network, and volume resources
│   ├── variables.tf            # Configurable port variables
│   └── outputs.tf              # Exposed resource outputs
│
└── todo-api/
    ├── Dockerfile              # Node.js container image definition
    ├── docker-compose.yml      # Local development Compose file
    ├── .env                    # Local environment variables (not committed)
    ├── server.js               # Express app entry point
    ├── package.json
    ├── models/
    │   └── Todo.js             # Mongoose schema (title, completed)
    └── routes/
        └── todoRoutes.js       # Route handlers for all CRUD endpoints
```

---

## API Reference

Base URL (local): `http://localhost:3000`

### Todo Schema

```json
{
  "_id": "ObjectId",
  "title": "string (required)",
  "completed": "boolean (default: false)"
}
```

### Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/todos` | Retrieve all todos |
| `POST` | `/todos` | Create a new todo |
| `GET` | `/todos/:id` | Retrieve a single todo by ID |
| `PUT` | `/todos/:id` | Update a todo by ID |
| `DELETE` | `/todos/:id` | Delete a todo by ID |

#### Create a Todo

```http
POST /todos
Content-Type: application/json

{
  "title": "Learn Docker Compose"
}
```

#### Update a Todo

```http
PUT /todos/:id
Content-Type: application/json

{
  "title": "Learn Docker Compose",
  "completed": true
}
```

#### Delete a Todo

```http
DELETE /todos/:id
```

Response:

```json
{ "message": "Todo deleted" }
```

---

## Local Development

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- Git

### Run with Docker Compose

```bash
# Clone the repository
git clone <repository-url>
cd Multi-Container-Application

# Start API + MongoDB containers
cd todo-api
docker compose up --build
```

The API will be available at `http://localhost:3000`.

### Run with Terraform

```bash
cd terraform
terraform init
terraform apply
```

Terraform provisions the Docker network, volume, MongoDB container, and API container using the local Docker socket.

### Quick Test

```bash
# Health check
curl http://localhost:3000/

# Create a todo
curl -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Docker"}'

# Fetch all todos
curl http://localhost:3000/todos
```

---

## Deployment

### Server Provisioning with Ansible

Ansible is used to configure a fresh Ubuntu server for production. The playbook:

1. Installs Docker and the Docker Compose plugin
2. Ensures the Docker service is running and enabled on boot
3. Creates the deployment directory (`/home/yandex/todo-app`)
4. Copies `docker-compose.yml` and `.env` to the server
5. Pulls the latest image from Docker Hub and starts the containers

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy.yml
```

### CI/CD Pipeline with GitHub Actions

The pipeline triggers automatically on every push to `main`.

```
Push to main
     │
     ▼
Checkout code
     │
     ▼
Login to Docker Hub
     │
     ▼
Build Docker image
     │
     ▼
Push image to Docker Hub
     │
     ▼
Connect to VM via Tailscale
     │
     ▼
SSH into server
     │
     ├── docker compose pull
     └── docker compose up -d
```

#### Required GitHub Secrets

| Secret | Description |
|---|---|
| `DOCKER_PASSWORD` | Docker Hub access token |
| `TS_OAUTH_CLIENT_ID` | Tailscale OAuth client ID |
| `TS_OAUTH_SECRET` | Tailscale OAuth secret |
| `VM_HOST` | Server's Tailscale IP (`100.x.x.x`) |
| `VM_USER` | SSH username on the server |
| `VM_SSH_KEY` | Private SSH key for the server |

### Production Traffic Flow

```
Client Request
      │
      ▼
   Nginx (Reverse Proxy)
      │
      ▼
   Node.js API  (:3000)
      │
      ▼
   MongoDB      (:27017)
```

---

## Environment Variables

Create a `.env` file in `todo-api/` for local development:

```env
MONGO_URI=mongodb://mongo:27017/todos
```

> **Note:** Never commit `.env` files containing secrets. The `.env` in `ansible/files/` is the production copy deployed by Ansible.

---

## Learning Objectives

This project was built to practice:

- Docker fundamentals and image building
- Multi-container orchestration with Docker Compose
- Infrastructure as Code with Terraform
- Container networking and named volumes
- MongoDB integration via Mongoose
- Linux server administration
- Remote server configuration with Ansible
- Building CI/CD pipelines with GitHub Actions
- Reverse proxy configuration with Nginx
- Secure remote access using Tailscale

---

## Roadmap

- [ ] JWT authentication and user accounts
- [ ] HTTPS with Let's Encrypt SSL certificates
- [ ] Centralised logging (Loki + Grafana)
- [ ] Metrics and alerting (Prometheus + Grafana)
- [ ] Kubernetes deployment manifests
- [ ] Terraform-provisioned cloud VM (e.g. AWS EC2 or DigitalOcean Droplet)

---

## Author

Built as part of a DevOps and Backend Engineering learning project.

**Project:** [roadmap.sh — Multi-Container Service](https://roadmap.sh/projects/multi-container-service)
