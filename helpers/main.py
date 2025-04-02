from ast import Dict
from typing import List

# Retrieve env variables from secrets manager or parameter store
def get_env_variables(variables: List, region: str) -> dict:
    # Assumes the use of AWS Secrets Manager or Parameter Store
    # Assumes boto3 is installed and configured
    import boto3
    from botocore.exceptions import ClientError

    result = dict()
    if not variables:
        raise ValueError("Environment must be provided")
    
    var_in_secrets = []
    var_in_parameter_store = []

    for var in variables:
        name = var.get("name")
        origin = var.get("origin")
        if not name:
            raise ValueError("Name must be provided")
        if not origin:
            raise ValueError("Origin must be provided")
        if origin == "secrets_manager":
            var_in_secrets.append(name)
        elif origin == "parameter_store":
            var_in_parameter_store.append(name)
        else:
            raise ValueError("Origin must be either secrets_manager or parameter_store")
    
    if var_in_secrets:
        client = boto3.client("secretsmanager", region_name=region)
        for name in var_in_secrets:
            try:
                response = client.get_secret_value(SecretId=name)
                secret = response["SecretString"]
                result[name] = secret
            except ClientError as e:
                raise ValueError(f"Error retrieving secret {name}: {e}")
            
    if var_in_parameter_store:
        client = boto3.client("ssm", region_name=region)
        for name in var_in_parameter_store:
            try:
                response = client.get_parameter(Name=name, WithDecryption=True)
                parameter = response["Parameter"]["Value"]
                result[name] = parameter
            except ClientError as e:
                raise ValueError(f"Error retrieving parameter {name}: {e}")
    return result




# Create an env file with the retrieved variables
# return the path to the env file
def create_env(variables: dict) -> str:
    if not variables:
        raise ValueError("Environment must be provided")

    content = ""

    for key, value in variables.items():
        for key, value in variables.items():
            content += f"{key}={value}\n"
    return content
    


def create_systemd_service_file(config: dict) -> str:
    """
    Create a systemd service file for a FastAPI application.
    :param config: Dictionary containing the configuration for the service
    :return: String containing the systemd service file
    config must contain the following keys:
    - service_name: The name of the service
    - user: The user to run the service
    - working_directory: The working directory for the service
    - env_file: The path to the env file
    - entry_point: The entry point for the FastAPI application

    """
    if not config:
        raise ValueError("Config must be provided")
    
    required_keys = ["service_name", "user", "working_directory", "env_file", "entry_point"]
    for key in required_keys:
        if key not in config:
            raise ValueError(f"{key} must be provided")
    service_name = config["service_name"]
    user = config["user"]
    working_directory = config["working_directory"]

    env_file = config["env_file"]
    restart = config.get("restart", "always")

    entry_point = config["entry_point"]

    unit = f"""[Unit]
        Description={service_name} service
        After=network.target
    """

    exec_start = f"fastapi run {entry_point}"


    service = f"""[Service]
        Type=simple
        User={user}
        WorkingDirectory={working_directory}
        ExecStart={exec_start}
        Restart={restart}
        EnvironmentFile={env_file}
    """

    install = """[Install]
        WantedBy=multi-user.target
    """

    service_file = f"""
        {unit}
        {service}
        {install}
    """

    return service_file

# Write the service file to the systemd directory
def write_file(content: str, file: str) -> str:
    if not content:
        raise ValueError("Content must be provided")
    if not file:
        raise ValueError("File must be provided")
    
    with open(file, "w") as f:
        f.write(content)
    
    return file
    


# Each file should be in a separate module
# Here is an example of how to use the functions above

if __name__ == "__main__":
    # Get arguments from the command line
    import argparse
    parser = argparse.ArgumentParser(description="Create a systemd service file for a FastAPI application.")
    parser.add_argument("--service_name", type=str, required=True, help="The name of the service")
    parser.add_argument("--user", type=str, required=True, help="The user to run the service")
    parser.add_argument("--working_directory", type=str, required=True, help="The working directory for the service")
    parser.add_argument("--env_file", type=str, required=True, help="The path to the env file")
    parser.add_argument("--entry_point", type=str, required=True, help="The entry point for the FastAPI application")
    parser.add_argument("--region", type=str, required=True, help="The AWS region")
    args = parser.parse_args()
   

    for arg in vars(args):
        print(f"{arg}: {getattr(args, arg)}")
        