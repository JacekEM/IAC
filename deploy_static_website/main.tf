
provider "aws" {
  region = "${var.aws_region}" 
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" web_hosting_bucket {
    bucket = "${var.stack_name}"
    acl    = "private"
    website {
      index_document = "index.html"
      error_document = "index.html"
    }
    tags {
        Name = "mybucket"
        Env = "Dev"
    }
}

resource "aws_s3_bucket_policy" web_bucket_policy {
  bucket = "${aws_s3_bucket.web_hosting_bucket.id}"
  policy =<<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadGetObject",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.stack_name}/*"
      ]
    }
  ]
}
POLICY

}


resource "aws_iam_role" code_build_service_role {
  name               = "code_build_${var.stack_name}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" code_build_role_policy {
  name   = "code_build_${var.stack_name}"
  role   = "${aws_iam_role.code_build_service_role.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
       "s3:PutObject",
       "s3:GetObject",
       "s3:ListObject",
       "s3:DeleteObject",
       "s3:ListBucket"
      ],
      "Resource": [
         "arn:aws:s3:::${var.stack_name}",
         "arn:aws:s3:::${var.stack_name}/*"
      ],
      "Effect": "Allow"
    },

    {
      "Effect": "Allow",
      "Resource": [
        "${aws_codebuild_project.codebuild_website.id}"
      ],
      "Action": [
        "codebuild:*"
      ]
    },

    {
      "Effect": "Allow",
      "Resource": [
        "*",
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*${var.stack_name}/*"
      ],
      "Action": [
        "logs:*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}


resource "aws_codebuild_project" codebuild_website {
  name          = "${var.stack_name}"
  description   = "deploys static web to s3" 
  build_timeout = "5"
  service_role  = "${aws_iam_role.code_build_service_role.arn}"

  source {
    type            = "GITHUB"
    location        = "${var.github_repo_url}"
    git_clone_depth = 1
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/python:3.6.5" 
    type         = "LINUX_CONTAINER"

  }
  artifacts {
    type     = "S3"
    location = "${var.stack_name}"
  }

}

