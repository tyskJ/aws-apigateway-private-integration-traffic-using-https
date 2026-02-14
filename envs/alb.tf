/************************************************************
ALB
************************************************************/
resource "aws_lb" "private_alb" {
  load_balancer_type = "application"
  internal           = true
  name               = "private-alb"
  ip_address_type    = "ipv4"
  subnets = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
  customer_owned_ipv4_pool = null
  security_groups = [
    aws_security_group.alb_sg.id
  ]
  tags = {
    Name = "private-alb"
  }
  ### Traffic configuration
  enable_tls_version_and_cipher_suite_headers = false
  enable_waf_fail_open                        = false
  enable_http2                                = true
  idle_timeout                                = 60
  client_keep_alive                           = 3600
  ### Packet handling
  desync_mitigation_mode     = "defensive"
  drop_invalid_header_fields = false
  xff_header_processing_mode = "append"
  enable_xff_client_port     = false
  preserve_host_header       = false
  ### Availability Zone routing configuration
  enable_cross_zone_load_balancing = true
  enable_zonal_shift               = false
  dns_record_client_routing_policy = null
  ### Protection
  enable_deletion_protection = false
  ### Monitoring
  access_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
  connection_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
  health_check_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
}

/************************************************************
Listener - HTTP
************************************************************/
resource "aws_lb_listener" "http" {
  load_balancer_arn                    = aws_lb.private_alb.arn
  protocol                             = "HTTP"
  port                                 = 80
  routing_http_response_server_enabled = true
  tags = {
    Name = "http-listener"
  }
  default_action {
    order = 50000 # maximum
    type  = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Nothing to match"
      status_code  = "404"
    }
  }
}

/************************************************************
Listener Rule - HTTP
************************************************************/
resource "aws_lb_listener_rule" "http_for_acm" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1
  tags = {
    Name = "for-acm"
  }
  condition {
    host_header {
      values = ["acm.${var.domain_name}"]
    }
  }
  action {
    order = 1
    type  = "fixed-response"
    fixed_response {
      status_code  = "200"
      content_type = "text/plain"
      message_body = "Success For ACM Verification Response !!"
    }
  }
}

resource "aws_lb_listener_rule" "http_for_selfsigned" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2
  tags = {
    Name = "for-selfsigned"
  }
  condition {
    host_header {
      values = ["selfsigned.${var.domain_name}"]
    }
  }
  action {
    order = 1
    type  = "fixed-response"
    fixed_response {
      status_code  = "200"
      content_type = "text/plain"
      message_body = "Success For Self-Signed Verification Response !!"
    }
  }
}

/************************************************************
Listener - HTTPS
************************************************************/
resource "aws_lb_listener" "https" {
  load_balancer_arn                    = aws_lb.private_alb.arn
  port                                 = 443
  protocol                             = "HTTPS"
  routing_http_response_server_enabled = true
  certificate_arn                      = aws_acm_certificate_validation.public_cert_validation.certificate_arn
  ssl_policy                           = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  tags = {
    Name = "https-listener"
  }
  default_action {
    order = 50000 # maximum
    type  = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Nothing to match"
      status_code  = "404"
    }
  }
}

/************************************************************
Listener Rule - HTTPS
************************************************************/
resource "aws_lb_listener_rule" "https_for_acm" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1
  tags = {
    Name = "for-acm"
  }
  condition {
    host_header {
      values = ["acm.${var.domain_name}"]
    }
  }
  action {
    order = 1
    type  = "fixed-response"
    fixed_response {
      status_code  = "200"
      content_type = "text/plain"
      message_body = "Success For ACM Verification Response !!"
    }
  }
}

resource "aws_lb_listener_rule" "https_for_selfsigned" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 2
  tags = {
    Name = "for-selfsigned"
  }
  condition {
    host_header {
      values = ["selfsigned.${var.domain_name}"]
    }
  }
  action {
    order = 1
    type  = "fixed-response"
    fixed_response {
      status_code  = "200"
      content_type = "text/plain"
      message_body = "Success For Self-Signed Verification Response !!"
    }
  }
}

/************************************************************
Listener Certificates
************************************************************/
resource "aws_lb_listener_certificate" "selfsigned_cert" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.selfsigned_cert.arn
}