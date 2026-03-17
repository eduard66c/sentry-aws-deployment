output "instance_public_ip" {
  description = "Public IP of the Sentry Server instance"
  value = aws_instance.sentry_vm.public_ip
}

resource "local_file" "ansible_inventory" {

    filename = "${path.module}/../ansible/inventory.ini"

    content = <<EOT
    [sentry_servers]
    ${aws_instance.sentry_vm.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.private_key_path}
    EOT
}