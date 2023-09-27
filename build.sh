#!/bin/bash

# Namespace and image name
NAMESPACE="mannmengineer"

# List of image names
IMAGE_NAMES=("udagram-api-feed" "udagram-api-user")

# Loop through the list of image names
for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
    IMAGE_FULL_NAME="$NAMESPACE/$IMAGE_NAME:latest"
    echo "Processing image: $IMAGE_FULL_NAME"

    # Pull the latest version of the image
    docker pull $IMAGE_FULL_NAME

    # Get the current image ID
    CURRENT_ID=$(docker inspect --format '{{.Id}}' $IMAGE_FULL_NAME)

    # Build the new version of the image
    docker build -t $IMAGE_FULL_NAME ./$IMAGE_NAME

    # Get the new image ID
    NEW_ID=$(docker inspect --format '{{.Id}}' $IMAGE_FULL_NAME)

    # Compare the image IDs
    if [ "$CURRENT_ID" == "$NEW_ID" ]; then
        echo "Image ID has not changed."
    else
        echo "Image ID has been updated from $CURRENT_ID to $NEW_ID."
        docker push $IMAGE_FULL_NAME
    fi
done
