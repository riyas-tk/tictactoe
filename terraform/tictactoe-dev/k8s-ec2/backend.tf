terraform {
  backend "s3" {
    bucket = "us-east-1-riyaz-tictactoe-backend-bucket-20260122"
    key    = "tictactoe/ec2.state"
    region = "us-east-1"
  }
}