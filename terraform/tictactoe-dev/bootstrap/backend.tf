terraform {
  backend "s3" {
    bucket = "us-east-1-riyaz-tictactoe-backend-bucket-20260122"
    key    = "tictactoe/backend_config.state"
    region = "us-east-1"
  }
}