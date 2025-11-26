# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# EC2 Instances with cyclic subnet distribution
resource "aws_instance" "web_server" {
  count = var.instance_count

  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              yum update -y
              
              # Install Apache
              yum install -y httpd
              
              # Create custom index page
              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Web Server ${count.index + 1}</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          text-align: center;
                          padding: 50px;
                          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                          color: white;
                          margin: 0;
                      }
                      .container {
                          background: rgba(255, 255, 255, 0.1);
                          padding: 40px;
                          border-radius: 10px;
                          backdrop-filter: blur(10px);
                          max-width: 600px;
                          margin: 0 auto;
                      }
                      h1 {
                          font-size: 3em;
                          margin: 0;
                      }
                      p {
                          font-size: 1.2em;
                          margin: 10px 0;
                      }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>🚀 Web Server ${count.index + 1}</h1>
                      <p>Environment: ${var.environment}</p>
                      <p>Powered by Terraform & AWS</p>
                      <p>Instance Type: ${var.instance_type}</p>
                  </div>
              </body>
              </html>
              HTML
              
              # Start and enable Apache
              systemctl start httpd
              systemctl enable httpd
              
              # Log success
              echo "Web server ${count.index + 1} configured successfully" > /var/log/user-data.log
              EOF

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-web-server-${count.index + 1}-${var.environment}"
      Environment = var.environment
      ServerIndex = count.index + 1
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}