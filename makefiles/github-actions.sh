#!/bin/bash

# The path to the workflow file
workflow_path=".github/workflows/test.yml"

# The names of the jobs to add the environment variables to
job_names=("Test" "Run test for base code")

# The environment variables to add and their values
env_vars=("POSTGRES_TEST_USER" "POSTGRES_TEST_PASSWORD")
env_values=("runner" "postgres_password")

# Add the global environment variables
for index in ${!env_vars[*]}; do
    yq e ".env.${env_vars[$index]} = \"${env_values[$index]}\"" -i $workflow_path
done

# Add the service
yq e ".jobs.test.services.postgres.image = \"postgres:latest\"" -i $workflow_path
yq e ".jobs.test.services.postgres.env.POSTGRES_DB = \"postgres\"" -i $workflow_path
yq e ".jobs.test.services.postgres.env.POSTGRES_PASSWORD = \"\${{ env.POSTGRES_TEST_PASSWORD }}\"" -i $workflow_path
yq e ".jobs.test.services.postgres.env.POSTGRES_PORT = \"5432\"" -i $workflow_path
yq e ".jobs.test.services.postgres.env.POSTGRES_USER = \"\${{ env.POSTGRES_TEST_USER }}\"" -i $workflow_path
yq e ".jobs.test.services.postgres.ports[0] = \"5432:5432\"" -i $workflow_path
yq e ".jobs.test.services.postgres.options = \"--health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5\"" -i $workflow_path


# Add the environment variables to the jobs
for job_name in "${job_names[@]}"; do
    for env_var in "${env_vars[@]}"; do
        yq e ".jobs.*.steps[] |= (select(.name == \"$job_name\") .env.$env_var = \"\${{ env.$env_var }}\")" -i $workflow_path
    done
done