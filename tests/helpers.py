from helpers.main import create_env, create_systemd_service_file, write_file

def test_create_env():
    variables = dict({
        "TEST_ENV": "test_value",
        "ANOTHER_ENV": "another_value",
    })

    env = create_env(variables=variables)
    assert env is not None
    assert isinstance(env, str)
    assert "TEST_ENV=test_value" in env
    assert "ANOTHER_ENV=another_value" in env
    

def test_create_systemd_service_file():
    config = {
        "service_name": "test_service",
        "working_directory": "/path/to/working/directory",
        "exec_start": "/path/to/executable",
        "user": "test_user",
        "env_file": "/path/to/env/file",
        "entry_point": "/path/to/entry/point",
    }

    service_file = create_systemd_service_file(config=config)
    print(service_file)
    assert service_file is not None
    assert isinstance(service_file, str)
    assert "[Unit]" in service_file
    assert "[Service]" in service_file
    assert "[Install]" in service_file
    


def test_write_file():
    file_path = "/tmp/test_file.txt"
    content = """ [Unit]
        Description=test_service service
        After=network.target
    
        [Service]
        Type=simple
        User=test_user
        WorkingDirectory=/path/to/working/directory
        ExecStart=fastapi run /path/to/entry/point
        Restart=always
        EnvironmentFile=/path/to/env/file
    
        [Install]
        WantedBy=multi-user.target
    """

    write_file(file=file_path, content=content)
    
    with open(file_path, 'r') as f:
        file_content = f.read()
    
    assert file_content == content

