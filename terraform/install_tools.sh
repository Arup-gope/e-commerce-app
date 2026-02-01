#!/bin/bash

# 1. Immediate Cleanup of Existing Conflicts
# This stops the "Conflicting values set for option Signed-By" errors
sudo rm -f /etc/apt/sources.list.d/jenkins.list /etc/apt/sources.list.d/trivy.list
sudo rm -f /usr/share/keyrings/jenkins-keyring.asc /usr/share/keyrings/trivy.gpg
sudo rm -f /etc/apt/keyrings/jenkins-keyring.asc # Some versions use this path

# 2. System Update & Java Setup
sudo apt-get update -y
sudo apt-get install -y curl wget apt-transport-https gnupg lsb-release fontconfig openjdk-17-jre

# 3. Jenkins Installation (Using 2026 Updated Key)
# The key 7198F4B714ABFC68 is the new 2026 requirement
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg

# Using [signed-by] is mandatory on Ubuntu 24.04
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins

# Start and Enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# 4. Docker Installation & Permissions
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins # Now that the user exists

# Fix socket permission for Jenkins builds
sudo chmod 666 /var/run/docker.sock
sudo systemctl restart docker
sudo systemctl restart jenkins

# 5. Trivy Installation (Clean repository setup)
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install -y trivy

# 6. AWS CLI, Kubectl, & Helm (Direct Binaries for reliability)
# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws/

# Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# 7. Verification and Admin Password
echo "----------------------------------------"
echo "Setup Complete!"
jenkins --version || echo "Jenkins install failed"
docker --version
trivy --version
aws --version
kubectl version --client
helm version
echo "Initial Jenkins Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "----------------------------------------"