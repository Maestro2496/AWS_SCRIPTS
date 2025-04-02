#!/bin/bash
NVM_VERSION="v0.39.7"

echo "Updating system..."
sudo yum update -y

# Install  pip
echo "Installing pip..."
sudo yum install -y python3-pip
sudo pip3 install --upgrade pip
sudo yum install ruby -y
sudo yum install wget -y

# Getting aws region
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
AWS_REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/region)

echo "AWS Region: $AWS_REGION"
#Install codedeployagent TODO
CODE_DEPLOY_AGENT_BUCKET_NAME="aws-codedeploy-$AWS_REGION"
CODE_DEPLOY_AGENT_URL="https://$CODE_DEPLOY_AGENT_BUCKET_NAME.s3.$AWS_REGION.amazonaws.com/latest/install"

echo "Installing CodeDeploy agent..."
wget $CODE_DEPLOY_AGENT_URL -O install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
sudo systemctl enable codedeploy-agent
sudo systemctl start codedeploy-agent

# Install Cloudwatch agent (TODO)

# Function to install NVM and Node.js for a user
install_nvm_for_user() {
    local user=$1
    local home_dir=$(eval echo ~$user)

    echo "Installing NVM for $user..."
    sudo -u $user bash -c "
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
        source $home_dir/.bashrc
        nvm install --lts
    " 
}

# Install NVM and Node.js for both ec2-user and root
install_nvm_for_user "ec2-user"
install_nvm_for_user "root"

echo "Verifying installation..."
sudo -i -u ec2-user bash -c "node -v && npm -v"
sudo -i -u root bash -c "node -v && npm -v"

echo "Installation complete!"
