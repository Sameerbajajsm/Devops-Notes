#!/bin/bash


# Define an array of 10 servers to monitor
servers=("13.126.148.5" "13.232.82.175" "13.127.156.228" "15.207.32.135" "15.207.225.44" 
  "65.0.153.125" "3.110.180.106" "3.6.48.236" "65.1.19.50" "13.127.115.148" 
  "13.232.194.131" "13.234.50.170" "3.6.233.10" "3.108.77.241" "65.1.239.64" 
  "3.108.75.174" "3.108.9.178" "3.7.54.141" "3.108.85.174" "3.108.31.87" "13.235.47.187" 
  "35.154.41.156" "13.126.158.236" "3.109.180.241" "15.207.194.232")


# Create a CSV file with headers
echo "Server,Date,Load_Average,Total_RAM,Used_RAM,Available_RAM,Total_Disk,Used_Disk,Available_Disk,Disk_used_in_%,partition,Total_Disk_nvme1n1,Used_Disk_nvme1n1,Available_Disk_nvme1n1,Disk_used_in_%_nvme1n1" > server_monitoring.csv

# Loop through the server array
for server in "${servers[@]}"; do
  # Try to SSH into the server and retrieve its load average, disk usage, and memory usage
  date_stamp=$(date "+%Y-%m-%d %H:%M:%S")
  load_average=$(ssh ec2-user@"$server" "cat /proc/loadavg | awk '{print \$3}'")
  total_ram=$(ssh ec2-user@"$server" "free -h | awk '/Mem:/ {print \$2}'")
  used_ram=$(ssh ec2-user@"$server" "free -h | awk '/Mem:/ {print \$3}'")
  available_ram=$(ssh ec2-user@"$server" "free -h | awk '/Mem:/ {print \$7}'")
  total_disk=$(ssh ec2-user@"$server" "df -h | awk '/\/$/ {print \$2}'")
  used_disk=$(ssh ec2-user@"$server" "df -h | awk '/\/$/ {print \$3}'")
  available_disk=$(ssh ec2-user@"$server" "df -h | awk '/\/$/ {print \$4}'")
  disk_used_percentage=$(ssh ec2-user@"$server" "df -h | awk '/\/$/ {print \$5}'")

  # Adding information for /dev/nvme1n1 filesystem
  nvme1n1_total_disk=$(ssh ec2-user@"$server" "df -h | awk '/\/dev\/nvme1n1/ {print \$2}'")
  nvme1n1_used_disk=$(ssh ec2-user@"$server" "df -h | awk '/\/dev\/nvme1n1/ {print \$3}'")
  nvme1n1_available_disk=$(ssh ec2-user@"$server" "df -h | awk '/\/dev\/nvme1n1/ {print \$4}'")
  nvme1n1_used_percentage=$(ssh ec2-user@"$server" "df -h | awk '/\/dev\/nvme1n1/ {print \$5}'")

  # Append the data to the CSV file
  echo "$server,$date_stamp,$load_average,$total_ram,$used_ram,$available_ram,$total_disk,$used_disk,$available_disk,$disk_used_percentage,/dev/nvme1n1,$nvme1n1_total_disk,$nvme1n1_used_disk,$nvme1n1_available_disk,$nvme1n1_used_percentage" >> server_monitoring.csv
done

cp -r server_monitoring.csv /home/surya/server_monitoring$(date +%Y_%m_%dT%H_%M_%S).csv

