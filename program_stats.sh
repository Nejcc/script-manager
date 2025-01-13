#!/bin/bash

LOG_FILE="usage_stats.log"
BACKUP_DIR="usage_stats_backups"

# Check if dialog is installed
check_dependencies() {
    if ! command -v dialog &> /dev/null; then
        echo "The 'dialog' package is required but not installed."
        echo "Would you like to install it? (y/n)"
        read -r install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            echo "Select your system package manager:"
            echo "1. Arch Linux (pacman)"
            echo "2. Fedora (dnf)"
            echo "3. Debian/Ubuntu (apt)"
            read -r package_choice

            case $package_choice in
                1) sudo pacman -S dialog ;;
                2) sudo dnf install dialog ;;
                3) sudo apt install dialog ;;
                *) echo "Invalid choice. Please install 'dialog' manually." ;;
            esac
        else
            echo "Cannot proceed without 'dialog'. Exiting."
            exit 1
        fi
    fi
}

# Update the log file by analyzing installed packages
analyze_packages() {
    echo "Analyzing installed packages..."
    tmp_file=$(mktemp)

    # Get the list of currently installed packages
    if command -v dpkg > /dev/null; then
        dpkg-query -W -f='${binary:Package}\n' > "$tmp_file"
    elif command -v rpm > /dev/null; then
        rpm -qa > "$tmp_file"
    elif command -v pacman > /dev/null; then
        pacman -Qq > "$tmp_file"
    else
        echo "Package manager not supported."
        rm -f "$tmp_file"
        return
    fi

    # Merge new packages into the log file
    awk '
        NR==FNR {packages[$1] = $1; next}
        $1 in packages {print; delete packages[$1]}
        END {for (pkg in packages) print pkg, "0"}
    ' "$tmp_file" "$LOG_FILE" > "$LOG_FILE.tmp"

    # Replace the log file with the updated one
    mv "$LOG_FILE.tmp" "$LOG_FILE"

    rm -f "$tmp_file"
    echo "Package analysis completed."
}

# Display usage statistics
show_statistics() {
    total_packages=$(wc -l < "$LOG_FILE")
    most_used=$(sort -k2 -n -r "$LOG_FILE" | head -5)
    least_used=$(sort -k2 -n "$LOG_FILE" | head -5)
    unused_packages=$(awk '$2 == 0' "$LOG_FILE" | wc -l)

    stats=$(mktemp)
    echo "Total Packages: $total_packages" > "$stats"
    echo "Unused Packages: $unused_packages" >> "$stats"
    echo -e "\nTop 5 Most Used Packages:\n$most_used" >> "$stats"
    echo -e "\nTop 5 Least Used Packages:\n$least_used" >> "$stats"

    dialog --textbox "$stats" 30 100
    rm -f "$stats"
}

# Backup usage stats
backup_log() {
    mkdir -p "$BACKUP_DIR"
    backup_file="$BACKUP_DIR/usage_stats_$(date +"%Y%m%d%H%M%S").log"
    cp "$LOG_FILE" "$backup_file"
    dialog --msgbox "Usage stats backed up to $backup_file" 10 50
}

# Restore usage stats
restore_log() {
    backups=$(ls -1 "$BACKUP_DIR" 2>/dev/null)
    if [ -z "$backups" ]; then
        dialog --msgbox "No backups available." 10 50
    else
        selected=$(dialog --menu "Select a backup to restore:" 20 60 10 $(echo "$backups" | nl -w2 -s' ') 3>&1 1>&2 2>&3)
        if [ -n "$selected" ]; then
            selected_backup=$(echo "$backups" | sed -n "${selected}p")
            cp "$BACKUP_DIR/$selected_backup" "$LOG_FILE"
            dialog --msgbox "Restored from backup: $selected_backup" 10 50
        else
            dialog --msgbox "No backup selected." 10 50
        fi
    fi
}

# Check dependencies
check_dependencies

# Ensure the log file exists
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    analyze_packages
else
    analyze_packages
fi

# Main menu loop
while true; do
    choice=$(dialog --menu "Select an option:" 20 60 5 \
        1 "List Packages by Usage Count (Descending)" \
        2 "List Packages Alphabetically by Name" \
        3 "Show Statistics" \
        4 "Backup Usage Stats" \
        5 "Restore Usage Stats" \
        6 "Exit" \
        3>&1 1>&2 2>&3)

    case $choice in
        1)
            result=$(mktemp)
            sort -k2 -n -r "$LOG_FILE" > "$result"
            dialog --textbox "$result" 30 100
            rm -f "$result"
            ;;
        2)
            result=$(mktemp)
            sort "$LOG_FILE" > "$result"
            dialog --textbox "$result" 30 100
            rm -f "$result"
            ;;
        3) show_statistics ;;
        4) backup_log ;;
        5) restore_log ;;
        6) break ;;
        *) dialog --msgbox "Invalid choice. Please try again." 10 30 ;;
    esac
done

# Cleanup and exit
clear
echo "Goodbye!"
