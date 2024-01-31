resource "aws_lightsail_instance" "change_detection_instance" {
  name              = "changedetection-instance-rsde-smsi"
  availability_zone = "ca-central-1"
  blueprint_id      = "amazon_linux_2"
  bundle_id         = "nano_2_0"
  add_on {
    type          = "AutoSnapshot"
    snapshot_time = "06:00"
    status        = "Enabled"
  }
}

output "instance_ip" {
  value = aws_lightsail_instance.change_detection_instance.public_ip_address
}
