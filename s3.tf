resource "aws_s3_bucket" "pr_s3" {
  provider = aws.primary
  bucket   = "${var.bucket_name}-${var.primary_region}"

  tags = {
    Name        = "My PR bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_pr" {
  provider = aws.primary
  bucket = aws_s3_bucket.pr_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "pr_owner" {
  provider = aws.primary
  bucket = aws_s3_bucket.pr_s3.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_pr" {
  provider = aws.primary
  bucket = aws_s3_bucket.pr_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" #SSE-S3
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  provider   = aws.primary
  depends_on = [
    aws_s3_bucket_versioning.versioning_pr,
    aws_s3_bucket_versioning.versioning_sr,
    aws_s3_bucket_server_side_encryption_configuration.sse_sr
  ]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.pr_s3.id

  rule {
    id     = "replication-rule-1"
    status = "Enabled"

    filter {} # Required: empty filter to match all objects

    delete_marker_replication {
      status = "Disabled"
    }

    destination {
      bucket        = aws_s3_bucket.sr_s3.arn
      storage_class = "STANDARD"
    }
  }
}

###############################################################################

resource "aws_s3_bucket" "sr_s3" {
  provider = aws.secondary
  bucket   = "${var.bucket_name}-${var.secondary_region}"

  tags = {
    Name        = "My SR bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_sr" {
  provider = aws.secondary
  bucket = aws_s3_bucket.sr_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "sr_owner" {
  provider = aws.secondary
  bucket = aws_s3_bucket.sr_s3.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_sr" {
  provider = aws.secondary
  bucket = aws_s3_bucket.sr_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" #SSE-S3
    }
  }
}