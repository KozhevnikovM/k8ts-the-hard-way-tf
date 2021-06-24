output "controllers_ips" {
  value       = [aws_instance.controller.*.public_ip]
  description = "controllers public ip-addresses"
}

output "workers_ips" {
  value       = [aws_instance.worker.*.public_ip]
  description = "workers public ip-addresses"
}

output "lb_dns_name" {
  value = aws_lb.kubernetes.dns_name
  description = "Load Balancer DNS name"
}