#!bin/bash

# Start the app
SERVICE_NAME="my.fastapi.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"

# Check if the service file exists
if [ -f "$SERVICE_FILE" ]; then
    echo -e "\e[32mStarting the service...\e[0m"
    sudo systemctl start $SERVICE_NAME
    echo -e "\e[32mService started successfully.\e[0m"
else
    echo -e "\e[31mService file not found. Skipping starting the service.\e[0m"
fi

# Check the status of the service
if [ -f "$SERVICE_FILE" ]; then
    echo -e "\e[32mChecking the status of the service...\e[0m"
    sudo systemctl status $SERVICE_NAME
else
    echo -e "\e[31mService file not found. Skipping checking the status of the service.\e[0m"
fi