locals {
  # Automatically determine the current AWS account ID and region
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 1. Create the S3 bucket
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "my-cloudwatch-logs-destination-bucket-${local.account_id}"
  # Note: The bucket must be in the same region as the log group
}

# 2. Grant permissions to the CloudWatch logs service principal
resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudWatchLogsPutObject"
        Effect    = "Allow"
        Principal = {
          Service = "logs.${local.region}.amazonaws.com"
        }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.logs_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" : local.account_id
          }
          ArnLike = {
            "aws:SourceArn" : "arn:aws:logs:${local.region}:${local.account_id}:*"
          }
        }
      },
      {
        Sid       = "AllowCloudWatchLogsGetBucketAcl"
        Effect    = "Allow"
        Principal = {
          Service = "logs.${local.region}.amazonaws.com"
        }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.logs_bucket.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" : local.account_id
          }
          ArnLike = {
            "aws:SourceArn" : "arn:aws:logs:${local.region}:${local.account_id}:*"
          }
        }
      }
    ]
  })
}

# 3. Define the CloudWatch Logs Delivery Destination
resource "aws_cloudwatch_log_delivery_destination" "s3_destination" {
  name                   = "my-s3-destination"
  destination_resource_arn = aws_s3_bucket.logs_bucket.arn
  output_format          = "json" # Other formats include plain, w3c, raw, parquet
}

# 4. Create the log group that will send logs to S3
resource "aws_cloudwatch_log_group" "example_log_group" {
  name = "/aws/example/log-group"
  # Optional: Configure retention if needed, e.g., 14 days
  retention_in_days = 14
}

# 5. Define the CloudWatch Logs Delivery Source (associates the log group with the destination)
resource "aws_cloudwatch_log_delivery" "log_delivery_to_s3" {
  delivery_source_name     = aws_cloudwatch_log_group.example_log_group.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.s3_destination.arn
}