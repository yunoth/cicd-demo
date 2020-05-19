output "java_url" {
  description = "java app url"
  value       = module.alb.this_lb_dns_name
}