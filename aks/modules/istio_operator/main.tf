# RESOUCRES TO INSTALL ISTIO 

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
  count = "${var.to_provision == "true" ? 1 : 0}"
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
  count = "${var.to_provision == "true" ? 1 : 0}"
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "istio-system"
    labels = {
      app = "grafana"
    }
  }
  data = {
    username   = "admin"
    passphrase = random_password.password[count.index].result
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.istio_system]
  count = "${var.to_provision == "true" ? 1 : 0}"
}

resource "kubernetes_secret" "kiali" {
  metadata {
    name      = "kiali"
    namespace = "istio-system"
    labels = {
      app = "kiali"
    }
  }
  data = {
    username   = "admin"
    passphrase = random_password.password[count.index].result
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.istio_system]
  count = "${var.to_provision == "true" ? 1 : 0}"
}

resource "local_file" "istio-config" {
  content = templatefile("${path.module}/istio-aks.tmpl", {
    enableGrafana = true
    enableKiali   = true
    enableTracing = true
  })
  filename = ".istio/istio-aks.yaml"
  count = "${var.to_provision == "true" ? 1 : 0}"
}

resource "null_resource" "istio" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "istioctl manifest apply -f \".istio/istio-aks.yaml\" "
  }
  depends_on = [kubernetes_secret.grafana, kubernetes_secret.kiali, local_file.istio-config]
  
  count = "${var.to_provision == "true" ? 1 : 0}"
}

