#!/bin/bash

# Configuration
BUCKET_NAME="armory.sentri.cloud"
REGION="us-east-2"
BASE_URL="https://s3.us-east-2.amazonaws.com"
KEY_LIST_KEY="consulting/setup/foundation_files.txt"
LOCAL_KEY_LIST="./foundation_files.txt"
LOCAL_DIR="./foundation"

echo ""
echo "Starting download of foundational templates from Sentri Cloud"

# Create local directory if it doesn't exist
mkdir -p "$LOCAL_DIR"

# Step 1: Download foundation_files.txt from S3
# echo "Downloading key list from: $BASE_URL/$BUCKET_NAME/$KEY_LIST_KEY to $LOCAL_KEY_LIST"
curl -s "$BASE_URL/$BUCKET_NAME/$KEY_LIST_KEY" -o "$LOCAL_KEY_LIST"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download $KEY_LIST_KEY from S3. It may not exist or isn’t public."
    exit 1
fi

# Check if the downloaded key list is empty
if [ ! -s "$LOCAL_KEY_LIST" ]; then
    echo "Error: $LOCAL_KEY_LIST is empty after download. Please ensure it contains object keys."
    exit 1
fi

echo ""
echo "Successfully downloaded foundational templates:"
cat "$LOCAL_KEY_LIST"

# Counter for tracking
DOWNLOADED=0
SKIPPED=0

# Step 2: Read each key from the downloaded list and download the files
while IFS= read -r key; do
    # Skip empty lines
    [ -z "$key" ] && continue

    # Construct full URL and local path
    url="$BASE_URL/$BUCKET_NAME/$key"
    local_path="$LOCAL_DIR/$key"

    # Create directory structure for the file
    mkdir -p "$(dirname "$local_path")"

    # echo "Downloading: $key to $local_path"
    curl -s "$url" -o "$local_path"
    if [ $? -eq 0 ]; then
        ((DOWNLOADED++))
    else
        echo "Failed to download: $key (may not exist or isn’t public)"
    fi
done < "$LOCAL_KEY_LIST"

echo ""
echo "Download complete!"
echo "Files downloaded: $DOWNLOADED"
echo "Files saved to: $(realpath "$LOCAL_DIR")"

# Optional: Clean up the downloaded key list
rm -f "$LOCAL_KEY_LIST"