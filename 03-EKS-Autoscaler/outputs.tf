# Simple outputs for demo
output "cluster_autoscaler_status" {
  description = "Command to check autoscaler status"
  value       = "kubectl get pods -n kube-system -l app.kubernetes.io/name=cluster-autoscaler"
}

output "autoscaler_logs" {
  description = "Command to see autoscaler logs"
  value       = "kubectl logs -n kube-system -l app.kubernetes.io/name=cluster-autoscaler"
}

output "hpa_status" {
  description = "Command to check HPA status"
  value       = "kubectl get hpa -n default"
}

output "sample_app_status" {
  description = "Command to check sample app deployment"
  value       = "kubectl get deployment sample-app -n default"
}

output "load_test_command" {
  description = "Command to create load and test autoscaling"
  value       = "kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c 'while true; do wget -q -O- http://sample-app-service.default.svc.cluster.local; done'"
}
