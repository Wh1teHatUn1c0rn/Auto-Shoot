# Auto-Shoot

autoshoot is a troubleshooting script with automated functionalities that could benefit:

System and Network Admins
Helpdesk T1-T3
Tech Support T1-T3

Overall it can be benefitial for personal use as well as in a professional environment.

# Prerequisites

For Windows:

    PowerShell Environment:
        Ensure PowerShell 5.1 or later is installed (or PowerShell Core for cross-platform compatibility).

    Administrative Privileges:
        The script requires admin privileges for tasks like log access, service management, and network diagnostics.

    External Tools and Modules:
        Chocolatey: Used for installing external tools like Wireshark.
        Wireshark: For packet capturing (requires tshark command-line utility).
        SQL Server Management Studio (SSMS): For advanced database troubleshooting.
        PowerShell Modules:
            SqlServer: For database connectivity and queries.
            PSWindowsUpdate: For managing Windows updates.
        Optional Tools: Install additional tools using Chocolatey if needed.

    Internet Access:
        Required for installing dependencies and running online diagnostics (e.g., ping, updates)

For Linux:

    Bash Shell:
        A standard Bash shell is required, which is pre-installed on most Linux distributions.

    Administrative Privileges:
        sudo access is necessary for installing packages, capturing network packets, and accessing system logs.

    Dependencies:
        Package Management Tool:
            apt (for Debian/Ubuntu-based systems) or equivalent (e.g., yum for CentOS).
        Installed Tools:
            tcpdump: For network packet capturing.
            Wireshark or tshark: For advanced network analysis.
            mysql-client: For database connectivity testing.
        Optional Utilities:
            journalctl: For systemd log analysis (pre-installed on systemd-based distributions).
            SSH client: Pre-installed on most distributions, required for remote access testing.

    Internet Access:
        Needed for downloading prerequisites and performing online diagnostics (e.g., ping).

    Custom Configuration:
        Ensure the script has execute permissions:

chmod +x script_name.sh

Adjust interface names (eth0 vs ens33) and package manager commands if using a non-standard distribution.

# Detailed Setup Guide:

## Windows:

Install PowerShell:

    PowerShell 5.1: Pre-installed on Windows 10/11. Update via Windows Update if outdated.
    PowerShell Core: Download and install from the Microsoft PowerShell GitHub page.

Run PowerShell as Administrator:

    Right-click the PowerShell shortcut and select Run as Administrator.

Install Chocolatey:

    Run the following in an elevated PowerShell session:

    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Install Prerequisite Tools:

    Install necessary tools using Chocolatey:

    choco install wireshark -y
    choco install sql-server-management-studio -y

    Optional: Add other tools if required for your use case.

Install PowerShell Modules:

    Run these commands in PowerShell to install modules:

    Install-Module -Name SqlServer -Force -Scope CurrentUser
    Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser

Verify Installation:

    Check if all tools are accessible by running:

    Get-Command choco
    Get-Command tshark
    Get-Module -ListAvailable SqlServer

Internet Access:

    Ensure the system can connect to external services for downloading dependencies and performing diagnostics.

Execute the Script:

    Save the script as script_name.ps1.
    Run it from PowerShell:

.\autoshoot.ps1

## Linux:

Grant Execute Permissions to the Script:

    If the script file is script_name.sh, set execute permissions:

    chmod +x script_name.sh

Update Package Manager:

    Update the package list to ensure access to the latest versions of packages:

    sudo apt update

Install Required Tools:

    Install dependencies:

    sudo apt install -y tcpdump wireshark mysql-client

Allow Non-Root Wireshark Usage (Optional):

    Add your user to the Wireshark group to capture packets without sudo:

    sudo groupadd wireshark
    sudo usermod -aG wireshark $USER
    sudo chmod +x /usr/bin/dumpcap

Verify Installed Tools:

    Check if tools are installed:

    tcpdump --version
    tshark --version
    mysql --version

Internet Access:

    Ensure the system can connect to external services for updates, ping tests, and database connections.

Custom Configuration (Optional):

    Adjust interface names (eth0 vs ens33) or services based on your Linux distribution.

Execute the Script:

    Run the script:

./autoshoot.sh
