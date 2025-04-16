terraform {
  backend "s3" {
    bucket         = "ssawulski-terraform"
    key            = "ecs.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "ssawulski-terraform"
    encrypt        = true
  }
}