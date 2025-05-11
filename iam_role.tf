resource "aws_iam_role" "replication" {
  name = var.iam_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "replication_policy" {
  name        = var.iam_policy
  description = "Policy for S3 Replication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow source bucket listing and reading replication configuration
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.pr_s3.arn}",
          "${aws_s3_bucket.pr_s3.arn}/*"
        ]
      },
      # Allow reading object versions from source bucket
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.pr_s3.arn}/*"
      },
      # Allow replicating objects into destination bucket
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:GetObjectVersionTagging"
        ]
        Resource = [
          "${aws_s3_bucket.sr_s3.arn}",
          "${aws_s3_bucket.sr_s3.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_replication_role_attachment" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication_policy.arn
}
