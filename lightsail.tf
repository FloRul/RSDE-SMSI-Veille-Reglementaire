resource "aws_lightsail_instance" "this" {
  name              = "changedetection-instance-rsde-smsi"
  availability_zone = "us-west-2a" # Replace with your desired availability zone
  blueprint_id      = "amazon_linux_2"
  bundle_id         = "nano_2_0"
  add_on {
    type          = "AutoSnapshot"
    snapshot_time = "06:00"
    status        = "Enabled"
  }
}

output "instance_ip" {
  value = aws_lightsail_instance.this.public_ip_address
}
