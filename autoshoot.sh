#!/bin/bash
# T1/T2/T3 Automated Troubleshooting Script for Linux
# Author: [Your Name]

# Function: Install Prerequisites
install_prerequisites() {
    echo "Installing prerequisites..."

    # Update package lists
    sudo apt update -y

    # Install tcpdump
    if ! command -v tcpdump &> /dev/null; then
        echo "Installing tcpdump..."
        sudo apt install tcpdump -y
    else
        echo "tcpdump is already installed."
    fi

    # Install Wireshark
    if ! command -v tshark &> /dev/null; then
        echo "Installing Wireshark..."
        sudo apt install wireshark -y
    else
        echo "Wireshark is already installed."
    fi

    # Install MySQL client
    if ! command -v mysql &> /dev/null; then
        echo "Installing MySQL client..."
        sudo apt install mysql-client -y
    else
        echo "MySQL client is already installed."
    fi

    echo "All prerequisites installed."
}

# Function: Check System Uptime
check_system_uptime() {
    uptime
}

# Function: Check Disk Space
check_disk_space() {
    df -h
}

# Function: Check Network Connectivity
check_network_connectivity() {
    echo "Pinging Google DNS (8.8.8.8)..."
    if ping -c 2 8.8.8.8 &> /dev/null; then
        echo "Network is reachable."
    else
        echo "Network is unreachable."
    fi
}

# Function: Check Service Status
check_service_status() {
    read -p "Enter the service name: " service
    if systemctl is-active --quiet $service; then
        echo "Service '$service' is running."
    else
        echo "Service '$service' is not running."
    fi
}

# Function: Advanced Database Connectivity Test
test_database_connectivity() {
    read -p "Enter database host: " db_host
    read -p "Enter database user: " db_user
    read -sp "Enter database password: " db_pass
    echo "\nTesting database connectivity..."

    mysql -h $db_host -u $db_user -p$db_pass -e "SHOW DATABASES;" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Database connection successful."
    else
        echo "Database connection failed."
    fi
}

# Function: Correlate Logs
correlate_logs() {
    echo "Checking logs for errors..."
    sudo journalctl -p err --since "1 hour ago" | less
}

# Function: Packet Capture
capture_network_packets() {
    echo "Starting packet capture on interface eth0 for 30 seconds..."
    sudo tcpdump -i eth0 -w packets.pcap -G 30 &> /dev/null
    echo "Packet capture saved to packets.pcap."
}

# Function: Advanced Recovery Options
rebuild_system_components() {
    echo "Attempting system recovery..."
    sudo fsck -A
    sudo update-grub
    echo "System recovery completed."
}

# Function: Analyze Processes
analyze_processes() {
    echo "Top 10 processes by CPU usage:"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 11
}

# Function: Test Remote Access
test_remote_access() {
    read -p "Enter remote host: " remote_host
    echo "Testing SSH connectivity to $remote_host..."
    ssh -o ConnectTimeout=5 $remote_host "echo 'SSH connectivity successful.'" || echo "SSH connectivity failed."
}

# Function: Generate Audit Report
generate_audit_report() {
    report_file="audit_report_$(date +%F).txt"
    echo "Generating audit report..."

    echo "System Uptime:" > $report_file
    uptime >> $report_file

    echo "\nDisk Usage:" >> $report_file
    df -h >> $report_file

    echo "\nMemory Usage:" >> $report_file
    free -h >> $report_file

    echo "\nTop Processes:" >> $report_file
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 11 >> $report_file

    echo "\nRecent Logs:" >> $report_file
    sudo journalctl -p err --since "1 hour ago" >> $report_file

    echo "Audit report saved to $report_file."
}

# Main Menu
while true; do
    clear
    echo "============================="
    echo " T1/T2/T3 Troubleshooting Script for Linux "
    echo "============================="
    echo "1. Install Prerequisites"
    echo "2. Check System Uptime"
    echo "3. Check Disk Space"
    echo "4. Check Network Connectivity"
    echo "5. Check Service Status"
    echo "6. Test Database Connectivity"
    echo "7. Correlate Logs"
    echo "8. Capture Network Packets"
    echo "9. Rebuild System Components"
    echo "10. Analyze Processes"
    echo "11. Test Remote Access"
    echo "12. Generate Audit Report"
    echo "0. Exit"
    echo "============================="

    read -p "Enter your choice: " choice

    case $choice in
        1) install_prerequisites ;;
        2) check_system_uptime ;;
        3) check_disk_space ;;
        4) check_network_connectivity ;;
        5) check_service_status ;;
        6) test_database_connectivity ;;
        7) correlate_logs ;;
        8) capture_network_packets ;;
        9) rebuild_system_components ;;
        10) analyze_processes ;;
        11) test_remote_access ;;
        12) generate_audit_report ;;
        0) exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac

    read -p "Press Enter to continue..." temp
done
