#!/bin/bash

# Enable corepack
corepack enable

# Install dependencies and build
pnpm install
pnpm build

# Linux-only: download prebuilt sandboxing binaries (requires gh and zstd).
./scripts/install_native_deps.sh

# Get the usage and the options
node ./dist/cli.js --help

./scripts/build_container.sh

# # Push the Docker image to the registry
docker tag codex:latest ghcr.io/aiabcs/codex:latest
#echo $GH_CR_PAT | docker login ghcr.io -u $GH_CR_USER --password-stdin
docker login ghcr.io -u $GH_CR_USER --password $GH_CR_PAT
docker push ghcr.io/aiabcs/codex:latest
docker inspect ghcr.io/aiabcs/codex:latest

# Print success message
echo "Docker image 'codex:latest' built and pushed to ghcr.io/aiabcs/codex:latest successfully."


# Login to Azure Container Registry
#az acr login --name $REGISTRY_NAME
echo "Logging in to Azure Container Registry..."
REGISTRY_NAME="crsoftfact001"  # Replace with your Azure Container Registry name
REGISTRY_SERVER="${REGISTRY_NAME}.azurecr.io"  # Azure Container Registry server URL
IMAGE_NAME="codex"  # Name of the Docker image
IMAGE_TAG="latest"  # Tag for the Docker image
docker login $REGISTRY_SERVER -u $REGISTRY_NAME -p $REGISTRY_PASSWORD
# Build the Docker image
docker build -t "${REGISTRY_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}" .

# Push the Docker image to Azure Container Registry
docker push "${REGISTRY_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

# give sample usage
echo "You can now run the Codex CLI using the following command:"

# get the last instance number for folder
last_instance=$(ls -d $HOME/src/codex-tests/test* | sort -V | tail -n 1)
echo "Last instance directory: $last_instance"

# get the next instance number - this assumes the last instance is named testX where X is a number padding with 3 0s
if [ -z "$last_instance" ]; then
  last_instance="$HOME/src/codex-tests/test000"
fi
last_instance=$(basename "$last_instance")
# extract the number from the last instance name
last_instance_number=$(echo $last_instance | grep -o '[0-9]*')
# if the number is not found, default to 0
if [ -z "$last_instance_number" ]; then
  last_instance_number=0
fi
# pad the number with 3 zeros
last_instance_number=$(printf "%03d" $last_instance_number)
# construct the next instance name by incrementing the last instance number
last_instance="test$last_instance_number"
echo "Last instance name: $last_instance"

# now increment the last instance number by 1
last_instance_number=$((last_instance_number + 1))
# pad the incremented number with 3 zeros
last_instance_number=$(printf "%03d" $last_instance_number)
# construct the next instance name
last_instance="test$last_instance_number"
# echo the next instance name
echo "Next instance name: $last_instance"

# create the next instance directory based on the last instance
echo "Creating next instance directory: $HOME/src/codex-tests/$last_instance"
mkdir -p "$HOME/src/codex-tests/$last_instance"
# set the next instance directory
next_instance="$HOME/src/codex-tests/$last_instance"
echo "Next instance directory: $next_instance"

# initialize the next instance directory with git
echo "Initializing Git repository in $next_instance"
git init $next_instance
echo "Initialized empty Git repository in $next_instance/.git/"
echo "You can now start working in the $next_instance directory."
echo "Remember to set the OPENAI_ALLOWED_DOMAINS environment variable before running the container."
echo "Example: export OPENAI_ALLOWED_DOMAINS='api.openai.com api.azure.com'"

echo "To run a test, you can use the following command:"
# for simple .NET 8 MVC app to manage books in a public library
echo "./scripts/run_in_container.sh --work_dir $next_instance \"write a simple .net 8 mvc app to manage books in a public library\""
# for a python flask app to manage books in a public library
echo "./scripts/run_in_container.sh --work_dir $next_instance \"write a simple python flask app to manage books in a public library\""


