#!/bin/bash

install_dependencies() {
    MISSING_PKGS=""
    
    # Check if mongodump is installed
    if ! command -v mongodump &> /dev/null; then
        MISSING_PKGS+="mongodb-database-tools "
    fi
    
    # Check if mongorestore is installed
    if ! command -v mongorestore &> /dev/null; then
        MISSING_PKGS+="mongodb-database-tools "
    fi

    # Check if crontab is installed
    if ! command -v crontab &> /dev/null; then
        MISSING_PKGS+="cron "
    fi

    # If any package is missing, install them
    if [ -n "$MISSING_PKGS" ]; then
        zenity --question --text="Required packages ($MISSING_PKGS) are missing. Install now?" --title="Install Dependencies" --ok-label="Yes" --cancel-label="No"
        if [ $? -eq 0 ]; then
            sudo apt-get update
            sudo apt-get install -y $MISSING_PKGS
            zenity --info --text="Installation completed." --timeout=5
        else
            zenity --error --text="Required dependencies are missing. Exiting..." --timeout=5
            exit 1
        fi
    fi
}

install_dependencies

HOST=$(zenity --entry --title="MongoDB Configuration" --text="Enter MongoDB Host:" --entry-text="103.86.177.49")
PORT=$(zenity --entry --title="MongoDB Configuration" --text="Enter MongoDB Port:" --entry-text="32289")
USERNAME=$(zenity --entry --title="MongoDB Configuration" --text="Enter MongoDB Username:" --entry-text="hmsroot")
PASSWORD=$(zenity --password --title="MongoDB Configuration" --text="Enter MongoDB Password:")
AUTH_DB=$(zenity --entry --title="MongoDB Configuration" --text="Enter Authentication Database:" --entry-text="admin")
DATABASE=$(zenity --entry --title="MongoDB Configuration" --text="Enter Database Name:" --entry-text="hms")


BACKUP_DIR=$(zenity --file-selection --directory --title="Select Backup Directory")
LOG_FILE="$BACKUP_DIR/mongodb_backup.log"


mkdir -p "$BACKUP_DIR"

ACTION=$(zenity --list --radiolist --column="Select" --column="Action" TRUE "Backup" FALSE "Restore" --title="Choose Action" --width=400 --height=300)

if [ "$ACTION" == "Backup" ]; then
    # Backup file location
    DAY_OF_WEEK=$(date +%A)
    DAY_DIR="$BACKUP_DIR/$DAY_OF_WEEK"
    mkdir -p "$DAY_DIR"
    BACKUP_PATH="$DAY_DIR/mongodb_backup"
    
    # Check if a backup already exists
    if [ -d "$BACKUP_PATH" ]; then
        zenity --question --text="Backup for today already exists. Overwrite?" --title="Confirm Overwrite" --ok-label="Yes" --cancel-label="No"
        if [ $? -ne 0 ]; then
            exit 0
        fi
    fi

    # Run backup
    mongodump --host "$HOST" --port "$PORT" --username "$USERNAME" --password "$PASSWORD" --authenticationDatabase "$AUTH_DB" --db "$DATABASE" --out "$BACKUP_PATH" &> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        zenity --info --text="Backup completed successfully!" --timeout=5
    else
        zenity --error --text="Backup failed! Check logs for details." --timeout=10
    fi

    # Check if cron job exists before adding
    CRON_JOB="0 12 * * * /bin/bash $(realpath "$0")"
    (crontab -l 2>/dev/null | grep -q "$CRON_JOB") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

elif [ "$ACTION" == "Restore" ]; then
    # Ask user for backup file
    RESTORE_PATH=$(zenity --file-selection --directory --title="Select Backup Directory to Restore")
    
    if [ ! -d "$RESTORE_PATH" ]; then
        zenity --error --text="Invalid backup directory selected." --timeout=5
        exit 1
    fi

    # Restore the database
    mongorestore --host "$HOST" --port "$PORT" --username "$USERNAME" --password "$PASSWORD" --authenticationDatabase "$AUTH_DB" --db "$DATABASE" "$RESTORE_PATH" &>> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        zenity --info --text="Restore completed successfully!" --timeout=5
    else
        zenity --error --text="Restore failed! Check logs for details." --timeout=10
    fi
fi

zenity --info --text="Backup and restore operations completed." --title="MongoDB Backup" --timeout=5

