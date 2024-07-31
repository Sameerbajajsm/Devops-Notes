#!/bin/bash

# Define days when backup should run (Monday and Friday)
CURRENT_DAY=$(date +%A)
if [ "$CURRENT_DAY" != "Monday" ] && [ "$CURRENT_DAY" != "Friday" ]; then
    echo "Backup will only run on Monday and Friday. Exiting."
    exit 0
fi

# Function to perform backup for a user and IP
perform_backup() {
    local REMOTE_USER="$1"
    local REMOTE_IP="$2"
    
    # Define backup directory structure based on date and time
    BACKUP_DIR="/DATA-SP/50hertz-user-data/$REMOTE_USER/$(date +%Y-%m-%d_%H-%M-%S)"
    mkdir -p "$BACKUP_DIR"
    
    echo "Starting backup for $REMOTE_USER@$REMOTE_IP..."
    rsync -avz -e ssh root@$REMOTE_IP:/home/$REMOTE_USER/.thunderbird $BACKUP_DIR
#    rsync -avz -e ssh root@$REMOTE_IP:/home/$REMOTE_USER/DEV $BACKUP_DIR

    if [ $? -eq 0 ]; then
        USER_BACKUP_STATUS="Backup for $REMOTE_USER@$REMOTE_IP completed successfully."
    else
        USER_BACKUP_STATUS="Backup for $REMOTE_USER@$REMOTE_IP failed. Please coordinate with surya."
    fi
    
    echo "$USER_BACKUP_STATUS"
    echo "$USER_BACKUP_STATUS" | mail -s "Backup Status" surya.p@50hertz.in
}

# Backup for user "vikas" on IP "172.16.1.111"
perform_backup "vikas" "172.16.1.111"

# Backup for user "puspendu" on IP "172.16.1.115"
perform_backup "puspendu" "172.16.1.115"

# Backup for user "rahul" on IP "172.16.1.205"
perform_backup "rahul" "172.16.1.205"

# Backup for user "adarsh" on IP "172.16.1.66"
perform_backup "adarsh" "172.16.1.66"

# Backup for user "adarsh" on IP "172.16.1.66"
perform_backup "adarsh" "172.16.1.66"



