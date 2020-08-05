
resource "random_string" "randomstring" {
  length      = 25
  min_lower   = 15
  min_numeric = 10
  special     = false
}

# Create PA-VM bootstrap s3 bucket

resource "aws_s3_bucket" "vmboot" {
  bucket        = join("", list(var.bootstrap_s3bucket, "-", random_string.randomstring.result))
  acl           = "private"
  force_destroy = true
}

# Create s3 keys for bootstrap files

resource "aws_s3_bucket_object" "bootstrap_xml" {
  bucket = aws_s3_bucket.vmboot.id
  acl    = "private"
  key    = "config/bootstrap.xml"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "initcfg" {
  bucket  = aws_s3_bucket.vmboot.id
  acl     = "private"
  key     = "config/init-cfg.txt"
  content = <<-EOF
            type=dhcp-client
            panorama-server=${var.panorama1}
            panorama-server=${var.panorama2}
            tplname=${var.template}
            dgname=${var.devicegroup}
            hostname=${var.hostname}
            dns-primary=169.254.169.253
            vm-auth-key=${var.panorama_bootstrap_key}
            dhcp-accept-server-hostname=yes
            dhcp-accept-server-domain=yes
            EOF
}

resource "aws_s3_bucket_object" "software" {
  bucket = aws_s3_bucket.vmboot.id
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "license" {
  bucket  = aws_s3_bucket.vmboot.id
  acl     = "private"
  key     = "license/authcodes"
  content = var.authcode
}

resource "aws_s3_bucket_object" "content" {
  bucket = aws_s3_bucket.vmboot.id
  acl    = "private"
  key    = "content/"
  source = "/dev/null"
}

# Create a bootstrap iam role

resource "aws_iam_role" "bootstrap_role" {
  name = "vmsereis_bootstrap_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Create aws iam policy for bootstrap

resource "aws_iam_role_policy" "bootstrap_policy" {
  name = "vmseries_bootstrap_policy"
  role = aws_iam_role.bootstrap_role.id

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.vmboot.id}"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.vmboot.id}/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.vmboot.id}"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.vmboot.id}/*"
    }
  ]
}
EOF
}

# Create aws iam instance profile

resource "aws_iam_instance_profile" "bootstrap_profile" {
  name = "vmseries_bootstrap_profile"
  role = aws_iam_role.bootstrap_role.name
  path = "/"
}