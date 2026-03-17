# Sentry Deployment & Log Rotation Cronjob

This repository contains the necessary files for provisioning an EC2 instance to deploy a self-hosted Sentry server, and to upload and configure a shell script that archives and then truncates log entries older than 5 days.

This was achieved using **Terraform**, **Ansible**, and **Bash**.

## Assignment 1: Infrastructure & Sentry Deployment
### Overview

This project uses Terraform to provision a cloud VM (AWS EC2) and Ansible to configure the environment and deploy Sentry via Docker Compose.

- Infrastructure: AWS EC2 (t3.medium recommended)
- Provisioning: Ansible
- Application: Self-hosted Sentry (Docker-based)

### Setup Instructions

**Infrastructure:**
```Bash
cd terraform
terraform init
terraform plan
terraform apply
```

***Note:** This will automatically generate an inventory.ini inside the ansible/ directory.*

**Configuration:**
```Bash
cd ../ansible
ansible-playbook -i inventory.ini deploy_sentry_playbook.yml
```

## Assignment 2: Log Rotation Automation
### Overview

The system includes a custom Bash script designed to manage application logs effectively without interrupting service availability or losing data.

### How the Script Works

The script (log_rotate.sh) uses a Copy-and-Truncate strategy to ensure the application continues writing without a restart.

- **Safety Checks:** It validates root privileges and ensures the log file exists before proceeding.

- **Rotation:** It copies /var/log/application.log to a timestamped backup file.

- **Truncation:** It uses truncate -s 0 to empty the file in place. This is safer than mv because it maintains the existing file descriptor.

- **Compression:** The backup is compressed using gzip to reduce storage footprint.

### Log Retention & Archival Logic

- **Retention Policy:** The script maintains logs for the last 5 days only.

- **Archival:** Logs are stored in /var/log/archive/.

- **Cleanup:** It utilizes the find command with the -delete flag. This efficiently removes files modified (-mtime) more than 5 days ago using the unlink() system call.

# Cron Schedule configuration

For reproducibility and ease, playbook *upload_and_configure_log_script.yml* is provided. 

Running it **after** provisioning the infrastructure will upload the bash script to the EC2 instance and configure the cronjob for it.

In order to skip the task that adds some dummy content to the script, run the playbook as:
```Bash
ansible-playbook -i inventory.ini upload_and_configure_log_script.yml --skip-tags "debug_script"
```

- **Schedule:** Daily at Midnight (0 0 * * *).

- **Deployment Path:** `/opt/log_rotate.sh`

- **Logging:** Output and errors are logged to `/var/log/rotation_cron.log` for easy troubleshooting.

### How to Test Manually

1. SSH into the EC2 instance

2. Generate dummy logs:
```bash
echo "Simulated log entry" | sudo tee -a /var/log/application.log
```
3. Run the script:
```bash
sudo /opt/log_rotate.sh
```

4. Verify:

    Confirm `/var/log/application.log` is now empty.

    Confirm a new .gz file exists in `/var/log/archive/`.