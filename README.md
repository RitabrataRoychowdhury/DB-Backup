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
