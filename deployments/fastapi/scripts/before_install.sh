#!bin/bash
# This script is executed before the installation of the application


# Check if python and pip are installed
if ! command -v python3 &> /dev/null
then

    echo -e "\e[31mPython3 is not installed. Please install Python3.\e[0m"
    # install python3 pip
    echo -e "\e[33mInstalling Python3...\e[0m"
    sudo yum install -y python3
    sudo yum install -y python3-pip
else
    echo -e "\e[32mPython3 is installed.\e[0m"
fi

