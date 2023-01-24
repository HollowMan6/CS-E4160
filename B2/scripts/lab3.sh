#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo apt install -y nodejs npm

cat > helloworld.js <<EOL
// Importing 'http' module
const http = require('http');

// Setting Port Number as 80
const port = 8080;

// Creating Server
const server = http.createServer((req,res)=>{

	// Handling Request and Response
	res.statusCode=200;
	res.setHeader('Content-Type', 'text/html')
	res.end('<html><head></head><body><h1>Hello World!</h1></body></html>')
});

// Making the server to listen to required
// hostname and port number
server.listen(port,()=>{

	// Callback
	console.log(\`Server running at http://127.0.0.1:\${port}/\`);
});
EOL


## Start server
sudo tee -a /etc/systemd/system/server.service <<EOL
[Unit]
Description=Server service
[Service]
ExecStart=/bin/bash -c "cd /home/vagrant && node helloworld.js"
[Install]
WantedBy=multi-user.target
EOL
sudo systemctl enable server --now
