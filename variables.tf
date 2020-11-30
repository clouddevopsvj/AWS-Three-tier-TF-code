variable "region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  description = "Web Servers CIDR block"
  default     = "10.0.1.0/24"
}

variable "private1_cidr" {
  description = "App servers CIDR Block"
  default     = "10.0.2.0/24"
}

variable "private2_cidr" {
  description = "DataBase servers CIDR Block"
  default     = "10.0.3.0/24"
}

variable "ami" {
  default = "ami-026669ec456129a70"
}

variable "access_key" {
}
variable "secret_key" {
}

/*variable "key_path" {
  description = "SSH Public Key Path"
  default = "<location of PEM file>"
}
*/
