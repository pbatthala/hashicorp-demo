output "server_addresses" {
    value = "\n  ${join("\n  ", formatlist("%s", aws_instance.server.*.public_dns))}"
}

output "consul_dns" {
    value = "${element(aws_instance.server.*.public_dns, 0)}"
}

output "consul_url" {
    value = "\n  http://${element(aws_instance.server.*.public_dns, 0)}:8500/ui/"
}
