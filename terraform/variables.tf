variable "api_port" {
  description = "External port for the Todo API"
  type        = number
  default     = 3000
}

variable "mongo_port" {
  description = "External port for MongoDB"
  type        = number
  default     = 27017
}
