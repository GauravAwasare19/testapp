#!/bin/bash

# Define variables
REPO_URL="https://github.com/GauravAwasare19/testapp.git"
APP_DIR="/home/ubuntu/testapp"   # Update this to the correct path where your app is cloned
DOCKER_IMAGE="testapp"           # Name of your Docker image
DOCKER_CONTAINER="testapp-container" # Name of the running Docker container
BRANCH="main"                    # Your main branch

# Navigate to the app directory
cd $APP_DIR || exit

# Pull the latest code from the specified branch
git checkout $BRANCH
git pull origin $BRANCH

# Check if there is a new tag on the branch
git fetch --tags
LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)

# Check if the latest tag has already been deployed (optional - to skip duplicates)
if [ -f ".last-deployed-tag" ] && [ "$(cat .last-deployed-tag)" == "$LATEST_TAG" ]; then
    echo "The latest tag ($LATEST_TAG) is already deployed."
    exit 0
fi

# Build the Docker image with the latest tag
docker build -t $DOCKER_IMAGE:$LATEST_TAG .

# Stop and remove the previous container if it's running
docker stop $DOCKER_CONTAINER 2>/dev/null
docker rm $DOCKER_CONTAINER 2>/dev/null

# Run the new Docker container
docker run -d --name $DOCKER_CONTAINER -p 3000:3000 $DOCKER_IMAGE:$LATEST_TAG

# Save the latest deployed tag for future checks
echo $LATEST_TAG > .last-deployed-tag

echo "Deployment complete for tag $LATEST_TAG"
