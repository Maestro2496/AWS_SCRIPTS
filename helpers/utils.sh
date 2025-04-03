#!/bin/bash

# Function to create a .env file from a JSON string
create_env() {
    # json arg
    local json="$1"
    content=""
    local keys=$(echo "$json" | jq -r 'keys[]')

    for key in $keys; do
        value=$(echo "$json" | jq -r ".\"$key\"")
        content+="$key=$value\n"
    done
    echo -e "$content"  # Print output with newlines
}


create_systemd_service_file() {
    # Default values
    local service_name=""
    local user=""
    local working_directory=""
    local env_file=""
    local entry_point=""
    local restart="always"
    local port=8000
    # Parse flags/arguments
    while getopts "s:u:w:e:p:r:" opt; do
        case $opt in
            s) service_name="$OPTARG" ;;
            u) user="$OPTARG" ;;
            w) working_directory="$OPTARG" ;;
            env) env_file="$OPTARG" ;;
            ep) entry_point="$OPTARG" ;;
            r) restart="$OPTARG" ;;
            p) port="$OPTARG" ;;
            *) echo "Usage: $0 -s service_name -u user -w working_directory -env env_file -ep entry_point -p port [-r restart]"; exit 1 ;;
        esac
    done

    # Check if all required fields are provided
    if [[ -z "$service_name" || -z "$user" || -z "$working_directory" || -z "$env_file" || -z "$entry_point" || -z "$port" ]]; then
        echo "Error: Missing required configuration values"
        exit 1
    fi

    # Define systemd unit file
    local service_file="[Unit]
Description=${service_name} service
After=network.target

[Service]
Type=simple
User=${user}
WorkingDirectory=${working_directory}
ExecStart=uvicorn ${entry_point} --host 0.0.0.0 --port ${port} --reload
Restart=${restart}
EnvironmentFile=${env_file}

[Install]
WantedBy=multi-user.target"

    # Save service file to /etc/systemd/system/
    local service_path="/etc/systemd/system/${service_name}.service"

    echo "Creating systemd service file: $service_path"

    # Check for sudo/root permissions before writing
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root (or with sudo)"
        exit 1
    fi

    echo "$service_file" | tee "$service_path" > /dev/null

    # Reload systemd to apply changes
    systemctl daemon-reload
    echo "Systemd service file created and systemd reloaded: $service_path"
}
