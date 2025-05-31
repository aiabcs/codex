#!/bin/bash

# Check if the required environment variables are set
if [ -z "$GH_CR_USER" ] || [ -z "$GH_CR_PAT" ]; then
  echo "Error: GH_CR_USER and GH_CR_PAT environment variables must be set."
  exit 1
else
  echo "GH_CR_USER and GH_CR_PAT are set."
fi
# Check if the required environment variables are set for Azure Container Registry
if [ -z "$REGISTRY_PASSWORD" ]; then
  echo "Error: REGISTRY_PASSWORD environment variable must be set."
  exit 1
else
  echo "REGISTRY_PASSWORD is set."
fi

# Enable corepack
corepack enable

# Install dependencies and build
pnpm install
pnpm build

# Linux-only: download prebuilt sandboxing binaries (requires gh and zstd).
# first clean up any previous sandboxing binaries in folder $HOME/src/aiabcs/codex/codex-cli/bin/
rm -rf $HOME/src/aiabcs/codex/codex-cli/bin/codex-linux-sandbox-arm64
rm -rf $HOME/src/aiabcs/codex/codex-cli/bin/codex-linux-sandbox-x64
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

# Print success message
echo "Docker image '${IMAGE_NAME}:${IMAGE_TAG}' pushed to Azure Container Registry '${REGISTRY_SERVER}' successfully."

# now push dist/codex.tgz to GitHub Releases
# Check if the dist directory exists
if [ -d "dist" ]; then
  echo "dist directory exists, proceeding to upload codex.tgz"
else
  echo "dist directory does not exist, exiting"
  exit 1
fi
# Check if codex.tgz exists in the dist directory
if [ -f "dist/codex.tgz" ]; then
  echo "codex.tgz exists, proceeding to upload"
else
  echo "codex.tgz does not exist, exiting"
  exit 1
fi
# Upload codex.tgz to GitHub Releases
#RELEASE_TAG="v$(node -p "require('../package.json').version")"
RELEASE_TAG="v0.0.1"  # Replace with your desired release tag
# Check if the gh CLI is installed
if ! command -v gh &> /dev/null; then
  echo "gh CLI could not be found, please install it first."
  exit 1
fi
# Check if the user is authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
  echo "You are not authenticated with GitHub CLI, please run 'gh auth login' first."
  exit 1
fi
# Create a new release with the specified tag
echo "Creating a new release with tag $RELEASE_TAG"
gh release create --repo aiabcs/codex $RELEASE_TAG --title "Release $RELEASE_TAG" --notes "Release notes for version $RELEASE_TAG"
# Upload the codex.tgz file to the release
if [ ! -f "dist/codex.tgz" ]; then
  echo "codex.tgz file does not exist in dist directory, exiting"
  exit 1
fi
# Check if the release already exists
if gh release view $RELEASE_TAG --repo aiabcs/codex &> /dev/null; then
  echo "Release $RELEASE_TAG already exists, updating the release"
else
  echo "Release $RELEASE_TAG does not exist, creating a new release"
fi
# Create a new release or update the existing one
gh release upload --repo aiabcs/codex $RELEASE_TAG dist/codex.tgz --clobber


# create folder $HOME/src/codex-tests
mkdir -p $HOME/src/codex-tests
# check if the folder exists
if [ ! -d "$HOME/src/codex-tests" ]; then
  echo "Failed to create directory $HOME/src/codex-tests"
  exit 1
else
  echo "Directory $HOME/src/codex-tests created successfully"
fi
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
  echo "No previous instance found, starting from test000"
  last_instance_number=0
else
  echo "Last instance number found: $last_instance_number"
  # remove leading zeros from the number
  last_instance_number=$(echo $last_instance_number | sed 's/^0*//')
  # if the number is empty, default to 0
  if [ -z "$last_instance_number" ]; then
    echo "No previous instance number found, starting from test000"
    last_instance_number=0
  fi
  echo "Last instance number after removing leading zeros: $last_instance_number"
fi
# if the last instance number is not a number, default to 0
if ! [[ "$last_instance_number" =~ ^[0-9]+$ ]]; then
  echo "Last instance number is not a valid number, starting from test000"
  last_instance_number=0
fi
# echo the last instance number
echo "Last instance number: $last_instance_number"

# now increment the last instance number by 1
last_instance_number=$((last_instance_number + 1))
# echo the incremented last instance number
echo "Incremented last instance number: $last_instance_number"
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

# includes firewall rules for allowed domains for python packages and OpenAI API and Azure OpenAI API and nuget packages
export OPENAI_ALLOWED_DOMAINS="api.github.com github.com api4c9f86da943f4670bed2f3d40d8847c382yedt9t163bf3zfpiw1h.eastus2.cloudapp.azure.com api.openai.com pypi.org a2043.dscr.akamai.net apif52012fb91654e8c9f8a14aaecaa8c6f44erawvbyh5bf5t2q3xms.northcentralus.cloudapp.azure.com  a918.dscr.akamai.net waws-prod-ch1-ca8d2570.sip.p.azurewebsites.windows.net waws-prod-ch1-fbae39a0.sip.p.azurewebsites.windows.net waws-prod-ch1-fa793126.sip.p.azurewebsites.windows.net"

echo "Testing allowed IPs for domains: $OPENAI_ALLOWED_DOMAINS"
echo ""
echo "To run a python FIREWALL test, you can use the following command:"
# for simple .NET 8 MVC app to manage books in a public library
echo "./scripts/run_in_container.sh --work_dir $next_instance \"echo hello world\""

# then do
echo "cd app$next_instance"
echo "python3 -m venv .venv"
echo "chmod +x .venv/bin/activate"
echo ".venv/bin/activate"
echo ".venv/bin/pip3 install -r requirements.txt"
echo "export GH_TOKEN=ghp_Ggi******************"
echo "gh repo list"
echo "git config --global user.email \"codex@openai.com\""
echo "git config --global user.name \"Codex\""
echo "git add *"
echo "git commit -m \"Initial commit from sandbox\""
echo "gh repo create emmanuelknafo/$last_instance --push --private --source ."

# for .net small console app with restore and build
echo ""
echo "To run a .NET FIREWALL test, you can use the following command:"
echo "cd app$next_instance"
echo "dotnet new console -n MyConsoleApp"
echo "cd MyConsoleApp"
echo "dotnet add package Microsoft.Extensions.DependencyInjection"
echo "dotnet restore"
echo "dotnet build"

echo ""
echo "To run a python CODEX CLI test, you can use the following command:"
# for a python flask app to manage books in a public library
echo "./scripts/run_in_container.sh --work_dir $next_instance \"write a simple python flask app to manage books in a public library\""

echo ""
echo "To run a .NET CODEX CLI test, you can use the following command:"
# for simple .NET 8 MVC app to manage books in a public library
echo "./scripts/run_in_container.sh --work_dir $next_instance \"write a simple .net 8 mvc app to manage books in a public library\""


