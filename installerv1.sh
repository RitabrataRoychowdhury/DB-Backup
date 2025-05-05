#!/bin/bash

INSTALL_DIR=$(zenity --file-selection --directory --title="Select Installation Directory")

if [ -z "$INSTALL_DIR" ]; then
    zenity --error --text="Installation directory is required."
    exit 1
fi

echo "Extracting backup scripts to $INSTALL_DIR..."
tar -xzvf backup_scripts.tar.gz -C "$INSTALL_DIR"

echo "Setting executable permissions..."
chmod +x "$INSTALL_DIR/main.sh"
chmod +x "$INSTALL_DIR/backup_mongodb.sh"
chmod +x "$INSTALL_DIR/backup_postgres.sh"

CREATE_SYMLINKS=$(zenity --question --title="Create Symlinks" --text="Do you want to create symlinks for easy access?" --ok-label="Yes" --cancel-label="No")
if [ $? -eq 0 ]; then
    ln -s "$INSTALL_DIR/main.sh" /usr/local/bin/backup_main
    ln -s "$INSTALL_DIR/backup_mongodb.sh" /usr/local/bin/backup_mongodb
    ln -s "$INSTALL_DIR/backup_postgres.sh" /usr/local/bin/backup_postgres
    zenity --info --text="Symlinks created successfully."
else
    zenity --info --text="No symlinks created."
fi

echo "Cleaning up..."
rm -f backup_scripts.tar.gz

zenity --info --text="Backup scripts installation complete!"

