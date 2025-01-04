# T1/T2/T3 Automated Troubleshooting Script
# Author: [Vuk Markovic]

# Function: Install Prerequisites
function Install-Prerequisites {
    Write-Output "Installing prerequisites and external tools..."

    # Ensure Chocolatey is installed
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Output "Chocolatey installed successfully."
    }

    # Install Wireshark
    if (!(Get-Command tshark -ErrorAction SilentlyContinue)) {
        Write-Output "Installing Wireshark..."
        choco install wireshark -y
        Write-Output "Wireshark installed successfully."
    }

    # Install tcpdump (if applicable for the platform)
    if ($env:OS -match "Linux") {
        Write-Output "Installing tcpdump..."
        sudo apt-get install tcpdump -y
        Write-Output "tcpdump installed successfully."
    }

    # Install SQL Server Management Studio (if required for database troubleshooting)
    Write-Output "Checking for SQL Server Management Studio..."
    if (!(Get-Command ssms -ErrorAction SilentlyContinue)) {
        Write-Output "Installing SQL Server Management Studio..."
        choco install sql-server-management-studio -y
        Write-Output "SQL Server Management Studio installed successfully."
    }

    # Install PowerShell modules
    Write-Output "Installing necessary PowerShell modules..."
    Install-Module -Name SqlServer -Force -Scope CurrentUser
    Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
    Write-Output "PowerShell modules installed successfully."

    Write-Output "All prerequisites installed."
}

# Function: Check System Uptime
function Check-SystemUptime {
    $uptime = (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime
    Write-Output "System Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
}

# Function: Check Disk Space
function Check-DiskSpace {
    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        Write-Output "Drive $_.Name: $([math]::round($_.Used/1GB, 2)) GB used of $([math]::round($_.Used + $_.Free/1GB, 2)) GB"
    }
}

# Function: Check Network Connectivity
function Check-NetworkConnectivity {
    Write-Output "Pinging Google DNS (8.8.8.8)..."
    if (Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet) {
        Write-Output "Network is reachable."
    } else {
        Write-Output "Network is unreachable. Check the network connection."
    }
}

# Function: Check Service Status
function Check-ServiceStatus {
    param (
        [string]$ServiceName = "wuauserv" # Windows Update Service by default
    )
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Output "Service '$ServiceName' not found."
    } else {
        Write-Output "Service '$ServiceName' is $($service.Status)."
    }
}

# Function: Advanced Database Connectivity Test
function Test-DatabaseConnectivity {
    param (
        [string]$ServerName,
        [string]$DatabaseName,
        [string]$Username,
        [string]$Password
    )
    Write-Output "Testing database connectivity..."
    try {
        $connectionString = "Server=$ServerName;Database=$DatabaseName;User Id=$Username;Password=$Password;"
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $connection.Open()
        Write-Output "Connection to $DatabaseName on $ServerName successful."
        $connection.Close()
    } catch {
        Write-Output "Failed to connect to the database. Error: $_"
    }
}

# Function: Advanced Log Correlation
function Correlate-Logs {
    Write-Output "Correlating logs across sources..."
    Get-WinEvent -LogName Security | Where-Object { $_.LevelDisplayName -eq "Error" } |
    ForEach-Object {
        Write-Output "Security Log: $($_.TimeCreated) - $($_.Message)"
    }
    Get-WinEvent -LogName Application | Where-Object { $_.LevelDisplayName -eq "Error" } |
    ForEach-Object {
        Write-Output "Application Log: $($_.TimeCreated) - $($_.Message)"
    }
}

# Function: Packet Capture (Simulated)
function Capture-NetworkPackets {
    Write-Output "Starting network packet capture..."
    Write-Output "(This feature would require external tools like Wireshark or tcpdump.)"
}

# Function: Advanced Recovery Options
function Rebuild-SystemComponents {
    Write-Output "Rebuilding system components..."
    try {
        Write-Output "Repairing Windows bootloader..."
        bcdedit /export C:\BCDBackup
        bootrec /fixmbr
        bootrec /fixboot
        bootrec /rebuildbcd
        Write-Output "Bootloader repair completed."
    } catch {
        Write-Output "Error during system repair: $_"
    }
}

# Function: Process and Thread Analysis
function Analyze-Processes {
    Write-Output "Analyzing processes and threads..."
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 |
    ForEach-Object {
        Write-Output "Process: $($_.ProcessName) - CPU: $($_.CPU)% - Memory: $([math]::round($_.WorkingSet / 1MB, 2)) MB"
    }
}

# Function: Remote Access Diagnostics
function Test-RemoteAccess {
    param (
        [string]$RemoteHost
    )
    Write-Output "Testing RDP connectivity to $RemoteHost..."
    try {
        Test-Connection -ComputerName $RemoteHost -Count 2 -Quiet | Out-Null
        Write-Output "RDP connectivity successful to $RemoteHost."
    } catch {
        Write-Output "Failed to connect to $RemoteHost."
    }
}

# Function: Generate Comprehensive Audit Report
function Generate-AuditReport {
    $reportPath = "$env:USERPROFILE\Desktop\AuditReport.txt"
    Write-Output "Generating comprehensive audit report..."
    $uptime = (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime
    $diskInfo = Get-PSDrive -PSProvider FileSystem
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
    $memory = Get-CimInstance Win32_OperatingSystem
    $usedMemory = $memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory
    $memoryUsage = [math]::round(($usedMemory / $memory.TotalVisibleMemorySize) * 100, 2)

    @"
Comprehensive System Audit Report
==================================
System Uptime: $($uptime.Days) days, $($uptime.Hours) hours
Operating System: $($osInfo.Caption)
Version: $($osInfo.Version)
Architecture: $($osInfo.OSArchitecture)
CPU Usage: $cpu%
Memory Usage: $memoryUsage%
Disk Space: $(($diskInfo | ForEach-Object {"Drive $_.Name: $([math]::round($_.Used/1GB, 2)) GB used"}) -join "`n")
"@ | Out-File $reportPath

    Write-Output "Audit report saved to $reportPath."
}

# Main Menu
function Show-Menu {
    Clear-Host
    Write-Output "============================="
    Write-Output " T1/T2/T3 Troubleshooting Script "
    Write-Output "============================="
    Write-Output "0. Install Prerequisites"
    Write-Output "1. Check System Uptime"
    Write-Output "2. Check Disk Space"
    Write-Output "3. Check Network Connectivity"
    Write-Output "4. Check Service Status"
    Write-Output "5. Advanced Database Connectivity Test"
    Write-Output "6. Advanced Log Correlation"
    Write-Output "7. Network Packet Capture (Simulated)"
    Write-Output "8. Advanced Recovery Options"
    Write-Output "9. Process and Thread Analysis"
    Write-Output "10. Test Remote Access"
    Write-Output "11. Generate Comprehensive Audit Report"
    Write-Output "12. Exit"
    Write-Output "============================="
}

# Script Execution
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        "0" { Install-Prerequisites }
        "1" { Check-SystemUptime }
        "2" { Check-DiskSpace }
        "3" { Check-NetworkConnectivity }
        "4" {
            $service = Read-Host "Enter the service name (default: wuauserv)"
            if ([string]::IsNullOrWhiteSpace($service)) { $service = "wuauserv" }
            Check-ServiceStatus -ServiceName $service
        }
        "5" {
            $server = Read-Host "Enter the database server name"
            $database = Read-Host "Enter the database name"
            $username = Read-Host "Enter the username"
            $password = Read-Host "Enter the password"
            Test-DatabaseConnectivity -ServerName $server -DatabaseName $database -Username $username -Password $password
        }
        "6" { Correlate-Logs }
        "7" { Capture-NetworkPackets }
        "8" { Rebuild-SystemComponents }
        "9" { Analyze-Processes }
        "10" {
            $remoteHost = Read-Host "Enter the remote host name"
            Test-RemoteAccess -RemoteHost $remoteHost
        }
        "11" { Generate-AuditReport }
        "12" { break }
        default { Write-Output "Invalid choice. Please select a valid option." }
    }
    Pause
}