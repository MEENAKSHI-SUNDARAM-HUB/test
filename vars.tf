variable "region" {
default="ap-south-1"
}

variable "secret" {
sensitive=true
}

variable "access" {
sensitive=true
}

variable "cidr" {
}

variable "cidr-sub" {
}
