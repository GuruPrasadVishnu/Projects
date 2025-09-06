# Horizontal Pod Autoscaler setup

# Deploy Metrics Server for HPA
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.1"
  namespace  = "kube-system"

  set {
    name  = "args"
    value = "{--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP}"
  }
}

# Example deployment that can be auto-scaled by HPA
resource "kubernetes_deployment" "sample_app" {
  metadata {
    name      = "sample-app"
    namespace = "default"
    labels = {
      app = "sample-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "sample-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "sample-app"
        }
      }

      spec {
        container {
          image = "nginx:1.21"
          name  = "nginx"

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [helm_release.metrics_server]
}

# Service for the sample app
resource "kubernetes_service" "sample_app" {
  metadata {
    name      = "sample-app-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = "sample-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# Horizontal Pod Autoscaler for the sample app
resource "kubernetes_horizontal_pod_autoscaler_v2" "sample_app_hpa" {
  metadata {
    name      = "sample-app-hpa"
    namespace = "default"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.sample_app.metadata[0].name
    }

    min_replicas = 2
    max_replicas = 10

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.sample_app,
    helm_release.metrics_server
  ]
}
