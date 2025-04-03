#!/bin/bash
source helpers/functions.sh
source helpers/utils.sh

output=$(get_env_variables '{"TEST":"parameter_store", "/GIFT_CARD/REDIS_PORT" : "parameter_store"}')

env_vars=$(create_env "$output")

# write the env_vars to a file
echo -e "$env_vars" > .env



