data "aws_route53_zone" "primary" {
  name = "${var.profileName}.${var.route53_domain}"
}

# A Record for ec2
resource "aws_route53_record" "primary_A_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.profileName}.${var.route53_domain}"
  type    = "A"

  // ttl        = "300"
  // records    = [aws_instance.EC2_instance.public_ip]
  // depends_on = [aws_instance.EC2_instance]
  alias {
    name                   = aws_lb.loadBalancer.dns_name
    zone_id                = aws_lb.loadBalancer.zone_id
    evaluate_target_health = true
  }

}