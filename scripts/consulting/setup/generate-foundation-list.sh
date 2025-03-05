#!/bin/bash

# Configuration
OUTPUT_FILE="foundation_files.txt"  # The file to generate
# CURRENT_DIR="$(pwd)"  # Current directory as the base
CURRENT_DIR="../../../"

echo "Generating $OUTPUT_FILE from files in $CURRENT_DIR"

# Check if the output file already exists and warn
if [ -f "$OUTPUT_FILE" ]; then
    echo "Warning: $OUTPUT_FILE already exists. Overwriting it."
fi

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Counter for tracking
FILE_COUNT=0

# Recursively find all files in the current directory
# Exclude .git directory, .DS_Store, LICENSE, and foundation_files.txt itself
find "$CURRENT_DIR" -type f \
    -not -path "*/.git*" \
    -not -path "*/.trunk/*" \
    -not -path "*/scripts/*" \
    -not -path "*/archive/*" \
    -not -name ".DS_Store" \
    -not -name "LICENSE" \
    -not -name "foundation_files.txt" \
    -not -name "generate-foundation-list.sh" \
    -not -name "README.md" \
    -not -name "$OUTPUT_FILE" | while IFS= read -r file; do
    # Remove the leading './' from the path to make it a clean S3 key
    key="${file#"$CURRENT_DIR/"}"

    # Write the key to the output file
    echo "$key" >> "$OUTPUT_FILE"

    # Increment counter
    ((FILE_COUNT++))
    echo "Added: $key"
done

echo "Generation complete!"
echo "Total files added: $FILE_COUNT"
echo "Keys saved to: $(realpath "$OUTPUT_FILE")"

# Show the contents of the generated file
echo "Contents of $OUTPUT_FILE:"
cat "$OUTPUT_FILE"