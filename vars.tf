variable "repo_name" {
  type    = string
  default = "dev-repo"
}

variable "branch_name" {
  type    = string
  default = "master"
}

variable "build_project" {
  type    = string
  default = "ECS_BUILD"
}

variable "cidr" {
  type    = string
  default = "145.0.0.0/16"
}

variable "azs" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "subnets-ip" {
  type = list(string)
  default = [
    "145.0.1.0/24",
    "145.0.2.0/24"
  ]

}

variable "github_link" {
  default = "https://github.com/Vikrant1020/Service.git"  
}

variable "bucketname" {
  default = "cnaljbfubackweu"  
}

variable "github_token" {
  default = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" 
}

variable "github_owner" {
  default = "Vikrant1020"    
}

variable "github_repo" {
  default = "Service"   
}

variable "github_branch" {
  default = "master"   
}

variable "service1" {
  default = "service1"  
}

variable "service2" {
  default = "service2"  
}

variable "service3" {
  default = "service3"  
}

variable "service4" {
  default = "service4"  
}

variable "service5" {
  default = "service5"  
}

variable "service6" {
  default = "service6"  
}

variable "cluster_name" {
  default = "ECS_cluster"  
}

variable "dns" {
  default = "hellofromdevops.tk"
}