module "tictactoe_backend_setup" {
  source                 = "../../modules/bootstrap"
  region                 = "us-east-1"
  backend_s3_bucket      = "riyaz-tictactoe-backend-bucket-20260122"
  backend_dynamodb_table = "riyaz-backend-locker-dynamodb-table-20260122"
}
