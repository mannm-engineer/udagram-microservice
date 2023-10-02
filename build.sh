#!/bin/bash

# Define a function to process each image
process_image() {
    local IMAGE_NAME="$1"
    local NAMESPACE="$2"

    # Construct the full image name with namespace
    local IMAGE_FULL_NAME="$NAMESPACE/$IMAGE_NAME"
    local LATEST_TAG="$IMAGE_FULL_NAME:latest"
    local CURRENT_VERSION_TAG="$IMAGE_FULL_NAME:$(git rev-parse --short HEAD)"

    # Pull the latest version of the image
    docker pull "$IMAGE_FULL_NAME"

    # Get the current image ID for the latest tag
    local CURRENT_ID="$(docker inspect --format '{{.Id}}' "$IMAGE_FULL_NAME")"

    echo "Processing image: $IMAGE_FULL_NAME"

    # Build the new version of the image
    docker build -t "$LATEST_TAG" -t "$CURRENT_VERSION_TAG" "./$IMAGE_NAME"

    # Get the new image ID for the latest tag
    local NEW_ID="$(docker inspect --format '{{.Id}}' "$LATEST_TAG")"

    # Compare the image IDs
    if [ "$CURRENT_ID" == "$NEW_ID" ]; then
        echo "Image ID has not changed."
    else
        echo "Image ID has been updated from $CURRENT_ID to $NEW_ID."
        # Push both the latest and current version tags
        docker push "$CURRENT_VERSION_TAG"
        docker push "$LATEST_TAG"
    fi
}

# Set the IFS to ',' for splitting input string
IFS=',' read -ra IMAGE_ARRAY <<< "$IMAGE_NAMES"

# Loop through each image name in the array and call the function
for IMAGE_NAME in "${IMAGE_ARRAY[@]}"; do
    process_image "$IMAGE_NAME" "$NAMESPACE"
done
