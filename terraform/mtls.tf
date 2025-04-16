resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name  = "ssawulski-ca"
    organization = "Sawulski Consulting"
  }

  validity_period_hours = 8760
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature"
  ]
}

resource "tls_private_key" "client_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "client_csr" {
  private_key_pem = tls_private_key.client_key.private_key_pem

  subject {
    common_name  = "mtls-client"
    organization = "Sawulski Client"
  }
}

resource "tls_locally_signed_cert" "client_cert" {
  cert_request_pem   = tls_cert_request.client_csr.cert_request_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem

  validity_period_hours = 8760
  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_encipherment"
  ]
}

resource "aws_s3_object" "client_cert_pem" {
  bucket  = "ssawulski-mtls"
  key     = "client.pem"
  content = tls_locally_signed_cert.client_cert.cert_pem
}

resource "aws_s3_object" "client_key_pem" {
  bucket  = "ssawulski-mtls"
  key     = "client-key.pem"
  content = tls_private_key.client_key.private_key_pem
}

resource "aws_s3_object" "ca_cert" {
  bucket  = "ssawulski-mtls"
  key     = "ca.pem"
  content = tls_self_signed_cert.ca_cert.cert_pem
}

resource "aws_lb_trust_store" "mtls_trust_store" {
  name = "ssawulski-mtls-trust"

  ca_certificates_bundle_s3_bucket = "ssawulski-mtls"
  ca_certificates_bundle_s3_key    = "ca.pem"

  depends_on = [aws_s3_object.ca_cert]
}

resource "tls_private_key" "alb_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "alb_csr" {
  private_key_pem = tls_private_key.alb_key.private_key_pem

  subject {
    common_name  = "app.ssawulski.net"
    organization = "Sawulski Consulting"
  }
}

resource "tls_locally_signed_cert" "alb_cert" {
  cert_request_pem   = tls_cert_request.alb_csr.cert_request_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem

  validity_period_hours = 8760
  allowed_uses = [
    "server_auth",
    "digital_signature",
    "key_encipherment"
  ]
}

resource "aws_acm_certificate" "alb_acm_cert" {
  private_key       = tls_private_key.alb_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.alb_cert.cert_pem
  certificate_chain = tls_self_signed_cert.ca_cert.cert_pem
}
