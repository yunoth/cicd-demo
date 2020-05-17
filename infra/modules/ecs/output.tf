output "java_url" {
  description = "java app url"
  value       = "${aws_elb.java-app-elb.dns_name}"
}