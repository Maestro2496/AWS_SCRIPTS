#!/bin/bash

# Function to retrieve environment variables from AWS Secrets Manager or Parameter Store
get_env_variables() {
    local json_input="$1"  # JSON input containing variable mappings
    local json='{}'  # Initialize an empty JSON object

    # Extract keys (variable names) from the JSON input
    local keys
    keys=$(echo "$json_input" | jq -r 'keys[]')

    # Check if the input is empty
    if [ -z "$keys" ]; then
        echo "Error: Environment variables must be provided in JSON format"
        exit 1
    fi

    # Loop through each key in the JSON input
    for name in $keys; do
        # Retrieve the origin (secrets_manager or parameter_store)
        origin=$(echo "$json_input" | jq -r ".\"$name\"")

        if [ -z "$name" ] || [ -z "$origin" ]; then
            echo "Error: Name and Origin must be provided for each variable"
            exit 1
        fi

        case "$origin" in
            secrets_manager)
                value=$(aws secretsmanager get-secret-value --secret-id "$name" --query SecretString --output text 2>/dev/null)
                if [ $? -ne 0 ]; then
                    echo "Error retrieving secret: $name"
                    exit 1
                fi
                ;;
            parameter_store)
                value=$(aws ssm get-parameter --name "$name" --with-decryption --query "Parameter.Value" --output text 2>/dev/null)
                if [ $? -ne 0 ]; then
                    echo "Error retrieving parameter: $name"
                    exit 1
                fi
                ;;
            *)
                echo "Error: Origin must be either secrets_manager or parameter_store"
                exit 1
                ;;
        esac

        # Sanitize the key (replace '/' with '_')
        name_sanitized=$(echo "$name" | tr '/' '_')
        name_sanitized=${name_sanitized#_}  # Remove leading '_'

        # Add the key-value pair to the JSON result
        json=$(echo "$json" | jq --arg key "$name_sanitized" --arg value "$value" '. + {($key): $value}')
    done

    # Print the final JSON object
    echo "$json"
}






# # Example Usage with flags:
# # ./create_systemd_service.sh -s fastapi_app -u ubuntu -w /home/ubuntu/app -e /home/ubuntu/app/.env -p main.py -r always

# declare -A env_vars=(
#     ["DB_USER"]="admin"
#     ["DB_PASS"]="secret"
#     ["API_KEY"]="123456"
# )

# env_content=$(create_env "${env_vars[@]}")

# # Save to a .env file
# echo -e "$env_content" > .env

# # Print output
# echo "Generated .env file:"
# cat .env


# # Example usage
# # Pass environment variables as "VAR_NAME:secrets_manager VAR_NAME2:parameter_store" and AWS region
# get_env_variables "DB_PASSWORD:secrets_manager API_KEY:parameter_store" "us-east-1"
# # Note: In a real-world scenario, you would want to handle the output of this function
# # more securely, such as writing to a .env file or using them directly in your application.