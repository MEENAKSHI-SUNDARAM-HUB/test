resource "aws_ebs_volume" "disk1" {
  size=5
  type="gp2"
  availability_zone=aws_instance.vm1.availability_zone
  tags = { Name="disk1" }
}

resource "aws_volume_attachment" "ebs-att" {
  device_name="/dev/sdc"
  volume_id=aws_ebs_volume.disk1.id
  instance_id=aws_instance.vm1.id
}

resource "null_resource" "exec" {
connection {
user="ec2-user"
private_key=file("~/ssh-key.pem")
host=aws_instance.vm1.public_ip
type="ssh"
}
provisioner "remote-exec" {
inline=[
"sudo yum install git -y",
"mkdir git && cd git",
"git clone https://github.com/NwayNway/test-repo-789"
]
}
}

