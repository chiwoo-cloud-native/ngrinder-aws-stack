##### custom-role
data "aws_iam_policy_document" "custom" {
  statement {
    sid     = "DataCollectToS3Bucket"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::otcmp-tbd-artifact-s3",
      "arn:aws:s3:::otcmp-tbd-artifact-s3/*"
    ]
  }

}
