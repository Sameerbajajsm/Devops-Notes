#!/bin/bash

# Define an array of server IPs to monitor
servers=("205.147.98.133" "101.53.136.30" "101.53.142.42" "101.53.142.177" "164.52.216.173" "164.52.195.60" 
  "164.52.195.61" "164.52.195.62" "164.52.195.5" "164.52.195.20" "164.52.195.22" "164.52.195.25" 
  "164.52.195.49" "164.52.195.52" "164.52.195.63" "164.52.202.13" "164.52.202.12" "164.52.202.17" 
  "164.52.202.19" "164.52.202.33" "164.52.201.254" "164.52.202.31" "164.52.201.203" "164.52.202.46" 
  "101.53.156.195" "101.53.155.73" "216.48.181.146" "216.48.182.237" "216.48.183.25")

# Create a CSV file with headers
echo "Server,Date,Load_Average,Total_RAM,Used_RAM,Available_RAM,Total_Disk,Used_Disk,Available_Disk,Disk_used_in_%,partition,Total_Disk_nvme1n1,Used_Disk_nvme1n1,Available_Disk_nvme1n1,Disk_used_in_%_nvme1n1" > E2E-server_monitoring.csv

# Loop through the server array
for server in "${servers[@]}"; do
  # Try to SSH into the server and retrieve its load average, disk usage, and memory usage
  date_stamp=$(date "+%Y-%m-%d %H:%M:%S")
  load_average=$(ssh root@"$server" "cat /proc/loadavg | awk '{print \$3}'")
  total_ram=$(ssh root@"$server" "free -h | awk '/Mem:/ {print \$2}'")
  used_ram=$(ssh root@"$server" "free -h | awk '/Mem:/ {print \$3}'")
  available_ram=$(ssh root@"$server" "free -h | awk '/Mem:/ {print \$7}'")
  total_disk=$(ssh root@"$server" "df -h | awk '/\/$/ {print \$2}'")
  used_disk=$(ssh root@"$server" "df -h | awk '/\/$/ {print \$3}'")
  available_disk=$(ssh root@"$server" "df -h | awk '/\/$/ {print \$4}'")
  disk_used_percentage=$(ssh root@"$server" "df -h | awk '/\/$/ {print \$5}'")

  # Adding information for /dev/nvme1n1 filesystem
  nvme1n1_total_disk=$(ssh root@"$server" "df -h | awk '/\/dev\/nvme1n1/ {print \$2}'")
  nvme1n1_used_disk=$(ssh root@"$server" "df -h | awk '/\/dev\/nvme1n1/ {print \$3}'")
  nvme1n1_available_disk=$(ssh root@"$server" "df -h | awk '/\/dev\/nvme1n1/ {print \$4}'")
  nvme1n1_used_percentage=$(ssh root@"$server" "df -h | awk '/\/dev\/nvme1n1/ {print \$5}'")

  # Append the data to the CSV file
  echo "$server,$date_stamp,$load_average,$total_ram,$used_ram,$available_ram,$total_disk,$used_disk,$available_disk,$disk_used_percentage,/dev/nvme1n1,$nvme1n1_total_disk,$nvme1n1_used_disk,$nvme1n1_available_disk,$nvme1n1_used_percentage" >> E2E-server_monitoring.csv
done

# Backup the CSV file with timestamp
cp -r E2E-server_monitoring.csv /home/surya/E2E-server_monitoring$(date +%Y_%m_%dT%H_%M_%S).csv

