#!/bin/bash

# Print headers
echo -e "User\t\tIP Address\t\tLogin Attempts"

# Extract failed login data and format it
lastb | awk '{print $1 "\t" $3}' | sort | uniq -c | awk '{print $2 "\t\t" $3 "\t\t" $1}'
