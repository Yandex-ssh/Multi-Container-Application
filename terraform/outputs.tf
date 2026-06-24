output "api_url" {
  description = "Local URL to access the Todo API"
  value       = "http://localhost:${var.api_port}"
}

output "mongo_url" {
  description = "Local connection URI for MongoDB"
  value       = "mongodb://localhost:${var.mongo_port}"
}
