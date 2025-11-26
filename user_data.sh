#!/bin/bash
set -e

yum update -y
yum install -y httpd

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Web Server ${server_number}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Web Server ${server_number}</h1>
        <p>Environment: ${environment}</p>
        <p>Powered by Terraform & AWS</p>
    </div>
</body>
</html>
EOF

systemctl start httpd
systemctl enable httpd