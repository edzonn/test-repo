# create s3 bucket

resource "aws_s3_bucket" "da-mlops-test001-s3-bucket" {
    bucket = "da-mlops-test0021-s3-bucket"
    acl = "private"
    versioning {
        enabled = true
    }
    tags = {
        Name = "da-mlops-test001-s3-bucket"
    }
}

# create s3 bucket policy to terrafom state file

resource "aws_s3_bucket_policy" "da-mlops-test001-s3-bucket-policy" {
    bucket = aws_s3_bucket.da-mlops-test001-s3-bucket.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.da-mlops-test001-s3-bucket.id}",
                "arn:aws:s3:::${aws_s3_bucket.da-mlops-test001-s3-bucket.id}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF
}


