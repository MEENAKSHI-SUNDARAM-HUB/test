resource "null_resource" "test" {
triggers = {
always_run=timestamp()
}
connection {
type="ssh"
user="ubuntu"
host=aws_instance.vm2.public_ip
private_key=file("~/ssh-key.pem")
}
provisioner "remote-exec" {
inline= ["sudo bash -c 'echo Hello world modified! >> /var/www/html/index.html'"]
}
}

output "testout" {
value = timestamp()
}

