#!/bin/bash

# The name of the workflow file
#filename=".github/workflows/test-unit.yml"
#
## The environment variables to add
#env_vars="  POSTGRES_TEST_USER: runner\\
#  POSTGRES_TEST_PASSWORD: postgres_password"
#
## Add the environment variables to the file
#sed -i "" -e "/^env:/a\\
#$env_vars" $filename
#
## The text to add
#text="    services:\n\
#      postgres:\n\
#        image: postgres:latest\n\
#        env:\n\
#          POSTGRES_DB: postgres\n\
#          POSTGRES_PASSWORD: \${{ env.POSTGRES_TEST_PASSWORD }}\n\
#          POSTGRES_PORT: 5432\n\
#          POSTGRES_USER: \${{ env.POSTGRES_TEST_USER }}\n\
#        ports:\n\
#          - 5432:5432\n\
#        options: >-\n\
#          --health-cmd pg_isready\n\
#          --health-interval 10s\n\
#          --health-timeout 5s\n\
#          --health-retries 5"
#
## Add the text to the file before the first 'steps' line
#awk -v text="$text" '/steps:/ {print text} {print}' $filename > $filename.tmp && mv $filename.tmp $filename

# The name of the step to add the environment variables to
#step_name="Test"
#
## The environment variables to add
#env_vars=("POSTGRES_TEST_USER" "POSTGRES_TEST_PASSWORD")
#
## Loop over the environment variables
#for env_var in "${env_vars[@]}"; do
#    # Use yq to add the environment variable to the step
#    yq e ".jobs.*.steps[] |= (select(.name == \"$step_name\") .env.$env_var = \"\${{ env.$env_var }}\")" -i $filename
#done



# The path to the workflow file
workflow_path=".github/workflows/test-unit.yml"

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