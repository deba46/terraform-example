################################################################################
# Install Elastic
################################################################################
resource "null_resource" "elastic-operator" {
  triggers = {
    hash = filemd5("../modules/deploy_elk/config/all-in-one.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ../modules/deploy_elk/config/all-in-one.yaml"
  }
}

resource "null_resource" "elastic-cluster" {
  triggers = {
    hash = filemd5("../modules/deploy_elk/config/elasticsearch.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ../modules/deploy_elk/config/elasticsearch.yaml"
  }

  depends_on = [null_resource.elastic-operator]
}
################################################################################
# Install Kibana
# https://stackoverflow.com/questions/54094575/how-to-run-kubectl-apply-commands-in-terraform
# https://stackoverflow.com/questions/58006272/how-to-create-a-file-with-terrafom-and-include-variable-as-literal
################################################################################
data "template_file" "kibana-yml-file" {
  template = file("../modules/deploy_elk/config/kibana.yaml")
  vars = {
    kibana_path = var.kibana_path
  }
}

#output "kibana-yaml-rendered" {
#  value = data.template_file.kibana-yml-file.rendered
#}

#output "kibana-yaml-template" {
#  value = data.template_file.kibana-yml-file.template
#}

data "template_file" "kibana-ingress-file" {
  template = file("../modules/deploy_elk/config/kibana-ingress.yaml")
  vars = {
    kibana_path = var.kibana_path
  }
}


resource "null_resource" "kibana-instance" {
  triggers = {
    hash = sha1(data.template_file.kibana-yml-file.rendered)
  }
  provisioner "local-exec" {
    command = "kubectl apply -f -<<EOF\n${data.template_file.kibana-yml-file.rendered}\nEOF"
  }

  depends_on = [null_resource.elastic-cluster,data.template_file.kibana-yml-file]
}

resource "null_resource" "kibana-ingress" {
  triggers = {
    hash = sha1(data.template_file.kibana-ingress-file.rendered)
  }
  provisioner "local-exec" {
    command = "kubectl apply -f -<<EOF\n${data.template_file.kibana-ingress-file.rendered}\nEOF"
  }

  depends_on = [null_resource.kibana-instance, data.template_file.kibana-ingress-file]
}

# https://sdorsett.github.io/post/2018-12-28-using-an-external-data-source-with-terraform/
# https://gist.github.com/irvingpop/968464132ded25a206ced835d50afa6b
#  Output of external data -json object:
#  {
#  "pass": ".....",
#  "service_name": "elasticsearch-es-http",
#  "port": "9200"
#  }

#
data "external" "get-elastic-info" {
  program = ["/bin/bash", "../modules/deploy_elk/elastic_info.sh"]

  depends_on = [null_resource.elastic-cluster ] #, null_resource.kibana-ingress]
}

output "elastic_info_result" {
  value = data.external.get-elastic-info.result
}

data "template_file" "fluentd-yml-file" {
  template = file("../modules/deploy_elk/config/fluentd-daemonset-elasticsearch.yaml")

  vars = {
    pass_word = data.external.get-elastic-info.result.pass
    elastic_svc = data.external.get-elastic-info.result.service_name
    port = data.external.get-elastic-info.result.port
    elastic_namespace = "elastic-system"
  }

  depends_on = [data.external.get-elastic-info]
}

#output "fluentdfile" {
#  value = data.template_file.fluentd-yml-file.rendered
#}

resource "null_resource" "fluentd-instance" {
  triggers = {
    hash = sha1(data.template_file.fluentd-yml-file.rendered)
  }
  provisioner "local-exec" {
    command = "kubectl apply -f -<<EOF\n${data.template_file.fluentd-yml-file.rendered}\nEOF"
  }

  depends_on = [data.template_file.fluentd-yml-file]
}

