#!/bin/bash

code_clone() {
    echo "Cloning the django app......"
    git clone https://github.com/LondheShubham153/django-notes-app.git
}

install_requirements() {
    echo "Installing dependencies"
    sudo apt-get install docker.io nginx -y
}

required_restarts() {
    sudo chown $USER /var/run/docker.sock
    sudo systemctl enable docker
    sudo systemctl enable nginx
    sudo systemctl restart docker
}

deploy() {
    docker build -t notes-app .
    docker run -d -p 8000:8000 notes-app:latest
}

echo "**************DEPLOYMENT STARTED***************"

# Check if directory already exists
if [ -d "django-notes-app" ]; then
    echo "The code directory already exists"
    cd django-notes-app
else
    if ! code_clone; then
        echo "Failed to clone repository"
        exit 1
    fi
    cd django-notes-app
fi

# Install requirements
if ! install_requirements; then
    echo "Failed to install requirements"
    exit 1
fi

# Setup services
if ! required_restarts; then
    echo "System fault identified"
    exit 1
fi

# Deploy the application
if ! deploy; then
    echo "Deployment failed"
    exit 1
fi

echo "**************DEPLOYMENT COMPLETED***************"
