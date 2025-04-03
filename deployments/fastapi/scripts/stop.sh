#!/bin/bash

# Update this script to stop the application
SERVICE_NAME="my.fastapi.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"


# Check if the service file exists
if [ -f "$SERVICE_FILE" ]; then
    echo -e "\e[32mStopping the service...\e[0m"
    sudo systemctl stop $SERVICE_NAME
    echo -e "\e[32mService stopped successfully.\e[0m"
else
    echo -e "\e[31mService file not found. Skipping stopping the service.\e[0m"
fi

#Remove the service file
if [ -f "$SERVICE_FILE" ]; then
    echo -e "\e[32mRemoving the service file...\e[0m"
    sudo rm -f $SERVICE_FILE
    echo -e "\e[32mService file removed successfully.\e[0m"
else
    echo -e "\e[31mService file not found. Skipping removal of the service file.\e[0m"
fi