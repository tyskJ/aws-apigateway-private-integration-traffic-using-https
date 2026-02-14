/************************************************************
Root CA Certificate
************************************************************/
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name  = "Origin Root CA"
    organization = "Origin ${var.domain_name} Org"
  }
  validity_period_hours = 87600 # 10年
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing", # この証明書は他の証明書に署名するために使用できる
    "crl_signing",  # この証明書は証明書失効リスト（CRL）に署名するために使用できる
  ]
}

/************************************************************
Server Certificate - CSR
************************************************************/
resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem
  dns_names       = ["selfsigned.${var.domain_name}"] # SAN
  subject {
    common_name  = "selfsigned.${var.domain_name}"
    organization = "Origin ${var.domain_name} Org"
  }
}

/************************************************************
Server Certificate
************************************************************/
resource "tls_locally_signed_cert" "server" {
  cert_request_pem      = tls_cert_request.server.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 8760 # 1年
  allowed_uses = [
    "key_encipherment",  # TLS鍵交換に使用
    "digital_signature", # サーバーが署名で正当性を証明
    "server_auth",       # TLSサーバー（HTTPS）用途
  ]
}

/************************************************************
Import to ACM
************************************************************/
resource "aws_acm_certificate" "selfsigned_cert" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
  tags = {
    Name = "internal-alb-selfsigned-certificate"
  }
  lifecycle {
    create_before_destroy = true
  }
}