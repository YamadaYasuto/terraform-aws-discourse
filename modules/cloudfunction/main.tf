# Basic 認証を行う CloudFront Function
resource "aws_cloudfront_function" "basicauth" {
  name    = "basic-auth-cloudfront"
  runtime = "cloudfront-js-1.0"
  publish = true
  code = templatefile(
    "${path.module}/basicauth.js",
    {
      authString = base64encode("${var.basicauth_username}:${var.basicauth_password}")
    }
  )
}
