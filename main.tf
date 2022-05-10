provider "aws" {
	region = "us-west-2"
}

locals {
	site_domain = "htorianyk.com"
}

data "aws_route53_zone" "primary" {
	name = local.site_domain
}

resource "aws_s3_bucket" "primary" {
	bucket = "www.${local.site_domain}"
}

resource "aws_s3_bucket_website_configuration" "primary" {
	bucket = aws_s3_bucket.primary.id

	index_document {
		suffix = "index.html"
	}

	error_document {
		key = "error.html"
	}
}

resource "aws_s3_bucket_policy" "primary_public_access" {
	bucket = aws_s3_bucket.primary.id
	policy = data.aws_iam_policy_document.public_access.json
}

data "aws_iam_policy_document" "public_access" {
	statement {
		actions = ["s3:GetObject"]

		principals {
			type        = "AWS"
			identifiers = ["*"]
		}

		resources = [
			"${aws_s3_bucket.primary.arn}/*"
		]
	}
}

resource "aws_route53_record" "primary" {
	zone_id = data.aws_route53_zone.primary.zone_id
	name = "www.${local.site_domain}"
	type = "A"

	alias {
		name = aws_s3_bucket.primary.website_domain
		zone_id = aws_s3_bucket.primary.hosted_zone_id
		evaluate_target_health = true
	}
}