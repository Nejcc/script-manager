#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to determine the package manager
detect_package_manager() {
    if command_exists "pacman"; then
        echo "pacman"
    elif command_exists "dnf"; then
        echo "dnf"
    elif command_exists "apt"; then
        echo "apt"
    else
        echo "unknown"
    fi
}

# Function to install a package
install_package() {
    local package=$1
    local program=$2
    local manager=$(detect_package_manager)

    case $manager in
        pacman)
            dialog --yesno "$program is not installed. Would you like to install it using pacman?" 10 50
            if [[ $? -eq 0 ]]; then
                sudo pacman -S --noconfirm "$package"
            else
                dialog --msgbox "$program will not be installed." 10 50
                exit 1
            fi
            ;;
        dnf)
            dialog --yesno "$program is not installed. Would you like to install it using dnf?" 10 50
            if [[ $? -eq 0 ]]; then
                sudo dnf install -y "$package"
            else
                dialog --msgbox "$program will not be installed." 10 50
                exit 1
            fi
            ;;
        apt)
            dialog --yesno "$program is not installed. Would you like to install it using apt?" 10 50
            if [[ $? -eq 0 ]]; then
                sudo apt install -y "$package"
            else
                dialog --msgbox "$program will not be installed." 10 50
                exit 1
            fi
            ;;
        *)
            dialog --msgbox "Unknown package manager. Please install $program manually." 10 50
            exit 1
            ;;
    esac
}

# Check and prompt to install a program
check_or_install() {
    local program=$1
    local package=${2:-$1} # If the package name differs from the program name, specify it as the second argument

    if ! command_exists "$program"; then
        install_package "$package" "$program"
    fi
}

# Functions for each monitoring tool
run_top() {
    check_or_install "top" "procps-ng"
    top
}

run_htop() {
    check_or_install "htop"
    htop
}

run_vmstat() {
    check_or_install "vmstat" "procps-ng"
    dialog --inputbox "Enter delay in seconds (e.g., 2):" 10 50 2 2> /tmp/vmstat_delay
    delay=$(cat /tmp/vmstat_delay)
    rm -f /tmp/vmstat_delay
    vmstat "$delay"
}

run_iostat() {
    check_or_install "iostat" "sysstat"
    dialog --inputbox "Enter interval in seconds (e.g., 2):" 10 50 2 2> /tmp/iostat_interval
    interval=$(cat /tmp/iostat_interval)
    rm -f /tmp/iostat_interval
    iostat "$interval"
}

run_free() {
    check_or_install "free" "procps-ng"
    free -h | less
}

run_pmap() {
    check_or_install "pmap" "procps-ng"
    dialog --inputbox "Enter Process ID (PID):" 10 50 2> /tmp/pmap_pid
    pid=$(cat /tmp/pmap_pid)
    rm -f /tmp/pmap_pid
    pmap "$pid" | less
}

run_sar() {
    check_or_install "sar" "sysstat"
    dialog --inputbox "Enter interval in seconds (e.g., 2):" 10 50 2 2> /tmp/sar_interval
    interval=$(cat /tmp/sar_interval)
    rm -f /tmp/sar_interval
    sar "$interval"
}

run_iftop() {
    check_or_install "iftop"
    sudo iftop
}

run_nethogs() {
    check_or_install "nethogs"
    sudo nethogs
}

run_monitorix() {
    check_or_install "monitorix"
    dialog --msgbox "Monitorix runs on a web server. Open http://localhost:8080 in your browser to view the interface." 10 50
    sudo systemctl start monitorix
}

run_dstat() {
    check_or_install "dstat"
    dstat -cdngyt | less
}

run_nvtop() {
    check_or_install "nvtop"
    nvtop
}

# Main menu loop
while true; do
    choice=$(dialog --menu "System Monitoring Tools" 20 70 13 \
        1 "top: Real-time process monitoring" \
        2 "htop: Interactive process viewer" \
        3 "vmstat: System performance over time" \
        4 "iostat: CPU and disk I/O statistics" \
        5 "free: Memory usage" \
        6 "pmap: Process memory usage" \
        7 "sar: Historical system activity" \
        8 "iftop: Real-time network usage" \
        9 "nethogs: Real-time per-process network usage" \
        10 "Monitorix: System and network resource graphs" \
        11 "dstat: Combined system statistics" \
        12 "nvtop: GPU usage monitoring" \
        13 "Exit" \
        3>&1 1>&2 2>&3)

    case $choice in
        1) run_top ;;
        2) run_htop ;;
        3) run_vmstat ;;
        4) run_iostat ;;
        5) run_free ;;
        6) run_pmap ;;
        7) run_sar ;;
        8) run_iftop ;;
        9) run_nethogs ;;
        10) run_monitorix ;;
        11) run_dstat ;;
        12) run_nvtop ;;
        13) break ;;
        *) dialog --msgbox "Invalid choice. Please try again." 10 30 ;;
    esac
done

# Cleanup and exit
clear
echo "Goodbye!"
