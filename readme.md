# Snapshot Execution Setup

This document provides the steps required to set up and execute the snapshot script for Azure or GCP environments.

## Prerequisites

Before running the snapshot script, ensure the following:

1. **Authenticate the cloud provider on the server**
   - For **Azure**:
     ```bash
     az login
     ```
   - For **GCP**:
     ```bash
     gcloud auth login
     ```

2. **Install `jq` on the server**
   - `jq` is required to parse JSON responses.
   - Installation:
     - On Ubuntu/Debian:
       ```bash
       sudo apt-get install jq
       ```
     - On RHEL/CentOS:
       ```bash
       sudo yum install jq
       ```

3. **Set up a cron job**

### Cron Configuration

Add the following line to the crontab based on the cloud environment:

- **For Azure:**
  ```bash
  30 23 * * * sh /home/apps/prod/snapshot/snapshot.sh AZURE >> /home/logs/cron/snapshotAutoCreation-`date +\%Y-\%m-\%d`.log 2>&1

- **For GCP:**
  ```bash
  30 23 * * * sh /home/apps/prod/snapshot/snapshot.sh GCP >> /home/logs/cron/snapshotAutoCreation-`date +\%Y-\%m-\%d`.log 2>&1
  

