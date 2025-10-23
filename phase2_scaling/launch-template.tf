resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-lt-"
  image_id      = "ami-0e2bc5787d3b38798" # latest valid AL2 in eu-west-2
  instance_type = "t3.micro"

  # ✅ simpler and compatible
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -xe
    amazon-linux-extras enable nginx1
    yum clean metadata
    yum install -y nginx
    systemctl enable nginx
    systemctl start nginx
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    echo "<h1>Auto Scaling WebApp</h1><p>Instance ID: $${INSTANCE_ID}</p><p>AZ: $${AZ}</p>" > /usr/share/nginx/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "asg-simple-web" }
  }
}
