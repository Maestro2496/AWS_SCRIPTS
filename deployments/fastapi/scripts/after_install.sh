#!bin/bash

ENV_FILE_LOCATION= "$(pwd)/.env"
# This script is executed after the installation of the application

# Change the file permissions


# Install requirements


# Check if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo -e "\e[32mInstalling requirements...\e[0m"
    pip3 install -r requirements.txt
else
    echo -e "\e[31mrequirements.txt not found. Skipping installation of requirements.\e[0m"
fi

# Generate .env file using the python script

# 1- Retrieve environment variables from AWS Parameter Store or Secrets Manager using
# utils function in helpers/functions.sh / helpers/utils.sh


# 2- Create a .env file with the retrieved environment variables


# 3- Create the systemd service file using helpers/functions.sh
