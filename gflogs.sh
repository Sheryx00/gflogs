#!/bin/bash

# Output log file
LOG_FILE="gf.logs"

# Clear previous logs
> "$LOG_FILE"

# Temporary file to track seen lines
TEMP_FILE=$(mktemp)

# List all patterns and loop over them
for pattern in $(gf -list); do
    # Print the pattern to the log
    echo "\n# $pattern\n" >> "$LOG_FILE"

    # Run gf command with the -I flag to avoid "binary file matches"
    gf "$pattern" -H -I | while read -r line; do
        # Extract the file name and match
        file=$(echo "$line" | cut -d: -f1)
        match=$(echo "$line" | cut -d: -f2-)

        # Check if this line has already been seen
        if ! grep -q "$file$match" "$TEMP_FILE"; then
            # If not seen, save it to the log and mark it as seen
            echo "$line" >> "$LOG_FILE"
            echo "$file$match" >> "$TEMP_FILE"
        fi
    done

    # Add a blank line between patterns
    echo "" >> "$LOG_FILE"
done

# Clean up temporary file
rm "$TEMP_FILE"

echo "Logs saved to $LOG_FILE"

