terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "null" {}

# Variables para facilitar cambios futuros
variable "topology_file" {
  default = "intervlan.yaml"
}

# 1. Desplegar la Topología con Containerlab
resource "null_resource" "deploy_lab" {
  
  # Este trigger sirve para que si cambias el archivo yaml, Terraform sepa que debe recrear
  triggers = {
    topo_content = filesha1(var.topology_file)
  }

  # Comando para crear el laboratorio
  provisioner "local-exec" {
    command = "sudo containerlab deploy --topo ${var.topology_file} --reconfigure"
  }

  # Comando para destruir el laboratorio cuando hagas 'terraform destroy'
  provisioner "local-exec" {
    when    = destroy
    command = "sudo containerlab destroy --topo intervlan.yaml --cleanup"
  }
}

# 2. Configurar con Ansible
resource "null_resource" "run_ansible" {
  
  # Esperamos a que el laboratorio esté desplegado
  depends_on = [null_resource.deploy_lab]

  triggers = {
    always_run = timestamp() # Esto fuerza a que Ansible corra siempre que hagas apply
  }

  provisioner "local-exec" {
    # Containerlab genera automáticamente un inventario. Lo usaremos.
    # Ajusta la ruta del inventario si containerlab genera una carpeta con nombre distinto.
    # Normalmente es: clab-<nombre_del_lab>/ansible-inventory.yml
    
    command = <<EOT
      echo "Esperando a que los dispositivos inicien..."
      sleep 15
      ansible-playbook -i clab-intervlan/ansible-inventory.yml playbooks/site.yml
    EOT
  }
}

# 3. Desplegar Edgeshark (Visualizador de paquetes)
resource "null_resource" "deploy_edgeshark" {
  
  # CRÍTICO: Esto asegura que SOLO inicie cuando Ansible haya terminado
  depends_on = [null_resource.run_ansible]

  # Iniciar Edgeshark
  provisioner "local-exec" {
    command = <<EOT
      curl -sL \
      https://github.com/siemens/edgeshark/raw/main/deployments/wget/docker-compose.yaml \
    | DOCKER_DEFAULT_PLATFORM= docker compose -f - up -d
    EOT
  }

  # Eliminar Edgeshark al destruir la infra
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      curl -sL \
      https://github.com/siemens/edgeshark/raw/main/deployments/wget/docker-compose.yaml \
    | DOCKER_DEFAULT_PLATFORM= docker compose -f - down
    EOT
  }
}