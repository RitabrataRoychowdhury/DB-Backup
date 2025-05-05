# 🧰 Backup & Restore Script Installer

A user-friendly Bash-based installer that sets up backup and restore scripts for **MongoDB** and **PostgreSQL** with GUI prompts, symlink creation, and optional cron scheduling.

---

## 📦 Features

- ✅ Backup & restore support for **MongoDB** and **PostgreSQL**
- 🖥️ Zenity-based **GUI installer**
- 🔗 Option to create **symlinks** for easy CLI access
- 🕒 Optional **cron job** integration for automatic backups
- 🔁 Supports both **manual and automated** workflows
- ⚡ Lightweight & easy to use

---

## 🛠️ Requirements

Ensure your system has the following installed:

- `bash`, `tar`, `chmod`, `ln`, `cron`
- `zenity` (GUI prompts)
- `mongodump`, `mongorestore` (for MongoDB)
- `pg_dump`, `pg_restore` (for PostgreSQL)

---

## 🚀 Installation

Run the installation script:

```bash
./install_backup_scripts.sh
```

During installation:
- 📁 Choose the installation directory via a GUI prompt
- 🔐 Scripts are made executable
- 🔗 Optionally create symlinks (e.g., `backup_mongodb`) for easier CLI usage

---

## 💻 Usage

### 🔐 Backups

Run the backup scripts directly:

```bash
./backup_mongodb.sh
./backup_postgres.sh
```

### ♻️ Restore

Run the restore scripts, specifying the backup path:

```bash
./restore_mongodb.sh /path/to/backup
./restore_postgres.sh /path/to/backup
```

Replace `/path/to/backup` with the actual backup folder or `.tar.gz` file path.

### 🔗 Symlink Commands (Optional)

If symlinks were created during setup, use simplified commands:

```bash
backup_mongodb
restore_mongodb /your/backup/path
backup_postgres
restore_postgres /your/backup/path
```

---

## ⏱️ Setup Cron Job for Automatic Backups

To automate backups, edit the cron table:

```bash
crontab -e
```

Add entries like:

```cron
0 2 * * * /usr/local/bin/backup_mongodb >> ~/mongodb_backup.log 2>&1
30 2 * * * /usr/local/bin/backup_postgres >> ~/postgres_backup.log 2>&1
```

This schedules:
- 🕑 MongoDB backups daily at 2:00 AM
- 🕝 PostgreSQL backups daily at 2:30 AM

---

## ❌ Uninstall

To remove the scripts:
1. Delete the installed directory.
2. Remove symlinks (if created):

```bash
sudo rm /usr/local/bin/backup_mongodb
sudo rm /usr/local/bin/restore_mongodb
sudo rm /usr/local/bin/backup_postgres
sudo rm /usr/local/bin/restore_postgres
```
