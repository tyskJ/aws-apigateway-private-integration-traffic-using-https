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
    order            = 50000 # maximum
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden..."
      status_code  = "403"
    }
  }
}