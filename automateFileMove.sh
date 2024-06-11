#!/bin/bash

# Directories to check
DIR1="/path/to/first/directory"
DIR2="/path/to/second/directory"

# Custom command to run
CUSTOM_COMMAND="your_custom_command_here"

# Get the file count
COUNT1=$(ls -1 "$DIR1" | wc -l)
COUNT2=$(ls -1 "$DIR2" | wc -l)

# Check if the file count is less than 7 in both directories
if [ "$COUNT1" -lt 7 ] && [ "$COUNT2" -lt 7 ]; then
  echo "Both $DIR1 and $DIR2 have less than 7 files. Running custom command."
  $CUSTOM_COMMAND
else
  echo "One or both directories have 7 or more files."
fi
