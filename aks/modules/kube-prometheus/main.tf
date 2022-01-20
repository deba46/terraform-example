resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "null_resource" "run_build" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "chmod +x build.sh ; ./build.sh config.jsonnet"
    working_dir = "../modules/kube-prometheus"
  }
  depends_on = [kubernetes_namespace.monitoring]

  count = "${var.build_and_compile == "true" ? 1 : 0}"
}


resource "null_resource" "run_setup" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ../modules/kube-prometheus/manifests/setup"
  }
  depends_on = [kubernetes_namespace.monitoring]
}

resource "null_resource" "run_manifests" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ../modules/kube-prometheus/manifests/"
  }
  depends_on = [null_resource.run_setup]
}

