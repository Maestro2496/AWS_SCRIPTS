#!bin/bash

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



# Create the systemd service file