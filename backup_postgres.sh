#!/bin/bash
#Developed By Ritabrata Roychowdhury
SCRIPT_DIR=$(dirname "$0")

# Ask the user for database details
HOST=$(zenity --entry --title="Database Configuration" --text="Enter PostgreSQL Host:" --entry-text="103.212.120.138")
PORT=$(zenity --entry --title="Database Configuration" --text="Enter PostgreSQL Port:" --entry-text="5432")
USER=$(zenity --entry --title="Database Configuration" --text="Enter PostgreSQL User:" --entry-text="postgres")
DATABASE=$(zenity --entry --title="Database Configuration" --text="Enter PostgreSQL Database:" --entry-text="postgres")
PGPASSWORD=$(zenity --password --title="Database Configuration" --text="Enter PostgreSQL Password:")

# Ask for backup directory and log file location
BACKUP_DIR=$(zenity --file-selection --directory --title="Select Backup Directory")
LOG_FILE=$(zenity --file-selection --save --title="Select Log File Location" --filename="$BACKUP_DIR/backup.log")

# Ensure required PostgreSQL tools are available
echo "[INFO] Checking for required PostgreSQL tools..." | tee -a "$LOG_FILE"
if ! command -v pg_dump &> /dev/null || ! command -v pg_restore &> /dev/null; then
    echo "[WARNING] PostgreSQL tools not found. Installing..." | tee -a "$LOG_FILE"
    sudo apt update && sudo apt install -y postgresql-client
else
    echo "[INFO] PostgreSQL tools are installed." | tee -a "$LOG_FILE"
fi

# Ensure Zenity is installed for GUI notifications
if ! command -v zenity &> /dev/null; then
    echo "[INFO] Installing Zenity for GUI notifications..." | tee -a "$LOG_FILE"
    sudo apt install -y zenity
fi

# Ask user for action (Backup or Restore)
ACTION=$(zenity --list --radiolist --column="Select" --column="Action" TRUE "Backup" FALSE "Restore" --title="Choose Action" --width=400 --height=200)

if [ "$ACTION" == "Backup" ]; then
    # Ask for confirmation to proceed with the backup
    zenity --question --text="Are you sure you want to perform a backup?" --title="Confirm Backup" --ok-label="Yes" --cancel-label="No"
    if [ $? -eq 0 ]; then
        DAY_OF_WEEK=$(date +%A)
        DAY_DIR="$BACKUP_DIR/$DAY_OF_WEEK"
        mkdir -p "$DAY_DIR"
        BACKUP_FILE="$DAY_DIR/hms_new.sql"

        # Check if a backup already exists for today
        if [ -f "$BACKUP_FILE" ]; then
            zenity --question --text="Backup for today already exists. Do you want to overwrite it?" --title="Overwrite Backup" --ok-label="Yes" --cancel-label="No"
            if [ $? -ne 0 ]; then
                echo "[INFO] Backup operation skipped by user." | tee -a "$LOG_FILE"
                exit 0
            fi
        fi
        
        echo "[INFO] Starting database backup..." | tee -a "$LOG_FILE"
        (
            echo "0"
            if PGPASSWORD="$PGPASSWORD" pg_dump -h "$HOST" -p "$PORT" -U "$USER" -d "$DATABASE" -F c -f "$BACKUP_FILE" 2>> "$LOG_FILE"; then
                echo "100"
                zenity --info --text="Backup completed successfully!" --timeout=5
            else
                zenity --error --text="Backup failed! Check logs." --timeout=10
                exit 1
            fi
        ) | zenity --progress --title="Backup Progress" --percentage=0 --width=400
        
        # Check if cron job is already set
        CRON_JOB="0 12 * * * /bin/bash $(realpath "$0")"
        if crontab -l 2>/dev/null | grep -q "$CRON_JOB"; then
            echo "[INFO] Cron job already exists. Skipping setup." | tee -a "$LOG_FILE"
        else
            zenity --question --text="Do you want to schedule a daily backup at 12:00 PM?" --title="Schedule Backup" --ok-label="Yes" --cancel-label="No"
            if [ $? -eq 0 ]; then
                (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
                echo "[INFO] Cron job scheduled successfully." | tee -a "$LOG_FILE"
            fi
        fi
    else
        echo "[INFO] Backup operation canceled by user." | tee -a "$LOG_FILE"
    fi
elif [ "$ACTION" == "Restore" ]; then
    zenity --question --text="Are you sure you want to restore the database?" --title="Confirm Restore" --ok-label="Yes" --cancel-label="No"
    if [ $? -eq 0 ]; then
        RESTORE_FILE=$(zenity --file-selection --title="Select Backup File for Restore")
        if [ -f "$RESTORE_FILE" ]; then
            (
                echo "0"
                if PGPASSWORD="$PGPASSWORD" pg_restore -h "$HOST" -p "$PORT" -U "$USER" -d "$DATABASE" -F c "$RESTORE_FILE" 2>> "$LOG_FILE"; then
                    echo "100"
                    zenity --info --text="Database restored successfully!" --timeout=5
                else
                    zenity --error --text="Restore failed! Check logs." --timeout=10
                fi
            ) | zenity --progress --title="Restore Progress" --percentage=0 --width=400
        else
            zenity --warning --text="Restore file not found. Skipping restore step." --timeout=5
        fi
    else
        echo "[INFO] Restore operation canceled by user." | tee -a "$LOG_FILE"
    fi
fi

# Ask if the user wants to back up something else
zenity --question --text="Do you want to back up another database or directory?" --title="Additional Backup" --ok-label="Yes" --cancel-label="No"
if [ $? -eq 0 ]; then
    EXTRA_BACKUP_DIR=$(zenity --file-selection --directory --title="Select Additional Backup Directory")
    tar -czf "$EXTRA_BACKUP_DIR/additional_backup.tar.gz" "$EXTRA_BACKUP_DIR"
    zenity --info --text="Additional backup completed successfully!" --timeout=5
fi

zenity --info --text="Backup and restore operations completed." --title="PostgreSQL Backup" --timeout=5

