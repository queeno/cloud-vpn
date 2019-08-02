data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "simon" {
  key_name = "simons-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/FEaB4sBIYlHUNWMYFfj/A0FFKiopWS1+FUD5/IDgjkrtRtxyia59eKFC/Xgt85bUmaRs/Wm9xf4rr7dB3zFvlHrDLEVZRmG3xJadz48NA16VpBTOjsZMeKuAcRpHDOEuWIQ6nwmq2HFa2hKwOVA9/P4Qadh0NPLp00e+J5oU8/TIrwMH2W0gsioGLWBGye4NovsWev5sDFLnWQX3XH9/sx/d9o9++6ennk8v9d6uutT85dlqa0eZnp0uJzob/MkJ5qFGre1dJre0Zb1XvBZSMGP/p4zAftJd2bZeWmB2ikHScbvqioBWBf9+qtLsjVjJUsG5yRR3X5MZQr6cjrrXoO85cBAovm2+Uaboa7xo9ukvLLlL3j6h2ltPNFhR3Fq3dsAXDK4IppCT7FHS4crxa+68S1HVBmBZIsdeMCNgQ/2iU1Ee8VmQUeKw5XmtSDsmqkcA1dNkhLUlPCEYFPU+Fw2ud2YXFtZcgwUIv2b1DURd/CdA0GVVV9KaZHJLd/JUwMCyn/DHDdNkSafloZ/Q8i/9awNQt6nj1yaCKOgJRQh0EYDsuX23UqPScPzFr2VEF4wFL3spWpOoauyn7xeZ6AdKz5jr49Pe/RhJFyKUiQ4QsbN+FVY2KG9Uu3H6heVV0oGiD1inWFySH3SJSKXhUlFW1YUcVx8mgfgQm6UG+Q== siaquino@LM-TXL-14511298"
}

data "template_file" "init_script" {
  template = file("init-script.tpl")
  vars = {
    hostname = var.vm_name
    dns_name = local.dns_name
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.simon.key_name
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = data.template_file.init_script.rendered

  subnet_id = aws_subnet.this.id
}