#!/bin/bash

# Ensure dialog is installed
if ! command -v dialog &>/dev/null; then
    echo "The 'dialog' package is required but not installed. Installing it now..."
    sudo pacman -S --noconfirm dialog
fi

# Directories
SCRIPT_DIR="./src"
LOG_DIR="./logs"

# Ensure necessary directories exist
mkdir -p "$SCRIPT_DIR"
mkdir -p "$LOG_DIR"

# Function to read metadata from a script
get_script_metadata() {
    local script="$1"
    name=$(grep -E "^# Name:" "$script" | sed 's/^# Name: //')
    description=$(grep -E "^# Description:" "$script" | sed 's/^# Description: //')
    version=$(grep -E "^# Version:" "$script" | sed 's/^# Version: //')
    author=$(grep -E "^# Author:" "$script" | sed 's/^# Author: //')
    updated=$(grep -E "^# Last Updated:" "$script" | sed 's/^# Last Updated: //')
    requires_root=$(grep -E "^#root:" "$script" | sed 's/^#root: //')

    [ -z "$name" ] && name="Unknown"
    [ -z "$description" ] && description="No description provided"
    [ -z "$version" ] && version="Unknown"
    [ -z "$author" ] && author="Unknown"
    [ -z "$updated" ] && updated="Unknown"
    [ -z "$requires_root" ] && requires_root="false"  # Default to false
}


# Build menu options dynamically with metadata
# Build menu options dynamically with only script names
build_menu_options() {
    scripts=()
    for script in "$SCRIPT_DIR"/*.sh; do
        if [ -e "$script" ]; then
            scripts+=("$(basename "$script")" "Select this script")
        fi
    done
    if [ ${#scripts[@]} -eq 0 ]; then
        dialog --msgbox "No scripts found in $SCRIPT_DIR. Add .sh scripts to this folder." 6 50
        exit 0
    fi
}

initialize_environment() {
    # Ensure dialog is installed
    if ! command -v dialog &>/dev/null; then
        echo "The 'dialog' package is required but not installed. Installing it now..."
        sudo pacman -S --noconfirm dialog
    fi

    # Create necessary directories
    mkdir -p "$SCRIPT_DIR" "$LOG_DIR"
}

build_menu() {
    local title="$1"
    local prompt="$2"
    shift 2
    dialog --backtitle "Script Manager" --title "$title" --menu "$prompt" 20 60 10 "$@" 2>&1 >/dev/tty
}


parse_metadata() {
    local script="$1"
    name=$(grep -E "^# Name:" "$script" | sed 's/^# Name: //')
    description=$(grep -E "^# Description:" "$script" | sed 's/^# Description: //')
    version=$(grep -E "^# Version:" "$script" | sed 's/^# Version: //')
    author=$(grep -E "^# Author:" "$script" | sed 's/^# Author: //')
    updated=$(grep -E "^# Last Updated:" "$script" | sed 's/^# Last Updated: //')
    requires_root=$(grep -E "^#root:" "$script" | sed 's/^#root: //')

    name=${name:-"Unknown"}
    description=${description:-"No description provided"}
    version=${version:-"Unknown"}
    author=${author:-"Unknown"}
    updated=${updated:-"Unknown"}
    requires_root=${requires_root:-"false"}
}



# Main menu function
main_menu() {
    build_menu_options
    scripts+=("new_script" "Create a new script template")
    scripts+=("search" "Search scripts")
    scripts+=("export_metadata" "Export all metadata to JSON")
    scripts+=("delete_old_logs" "Delete old logs")
    scripts+=("help" "View help and usage instructions")

    local selected=$(build_menu "Main Menu" "Select an option:" "${scripts[@]}")

    case "$selected" in
        new_script) create_new_script ;;
        search) search_scripts ;;
        export_metadata) export_metadata ;;
        delete_old_logs) delete_old_logs ;;
        help) show_help ;;
        *) script_submenu "$selected" ;;
    esac
}



show_help() {
    dialog --backtitle "Script Manager" \
        --title "Help and Usage Instructions" \
        --msgbox "Welcome to the Script Manager!

Features:
- Create new scripts using customizable templates.
- View, edit, execute, duplicate, delete, and schedule scripts.
- Search for scripts by name, description, or author.
- Export script metadata to JSON for documentation.
- Delete old logs to save space.

Template Directory:
Place your templates in the './templates' folder. Templates are used as the base for new scripts.

Enjoy your organized and efficient script management!" 35 80
    main_menu
}




# Submenu for managing a selected script
script_submenu() {
    local script_path="$SCRIPT_DIR/$1"
    get_script_metadata "$script_path"

    submenu_choice=$(dialog --backtitle "Script Manager" \
        --title "Manage Script: $1" \
        --menu "Select an action for $1:" 20 60 10 \
        1 "View Metadata" \
        2 "View Script Content" \
        3 "Edit Script" \
        4 "Execute Script" \
        5 "View Logs" \
        6 "Duplicate Script" \
        7 "Schedule Script" \
        8 "Delete Script" \
        9 "Assign Category" \
        10 "Back to Main Menu" 2>&1 >/dev/tty)

    case $submenu_choice in
        1) view_metadata "$script_path" ;;
        2) view_script "$script_path" ;;
        3) edit_script "$script_path" ;;
        4) execute_script "$script_path" ;;
        5) view_logs "$(basename "$script_path")" ;;
        6) duplicate_script "$script_path" ;;
        7) schedule_script "$script_path" ;;
        8) delete_script "$script_path" ;;
        9) assign_category "$script_path" ;;
        10) main_menu ;;
    esac
}


delete_script() {
    local script_path="$1"

    # Confirm deletion
    dialog --yesno "Are you sure you want to delete the script:\n\n$script_path" 10 50
    if [ $? -eq 0 ]; then
        # Delete the script
        rm -f "$script_path"
        dialog --msgbox "Script deleted successfully!" 6 40
    else
        dialog --msgbox "Script deletion canceled." 6 40
    fi

    # Return to the main menu
    main_menu
}


search_scripts() {
    # Prompt for a search term
    search_term=$(dialog --inputbox "Enter a search term (name, description, or author):" 10 50 2>&1 >/dev/tty)
    [ -z "$search_term" ] && main_menu

    # Filter scripts based on the search term
    scripts=()
    for script in "$SCRIPT_DIR"/*.sh; do
        if grep -q -i "$search_term" "$script"; then
            scripts+=("$(basename "$script")" "Found in metadata or content")
        fi
    done

    if [ ${#scripts[@]} -eq 0 ]; then
        dialog --msgbox "No scripts found matching '$search_term'." 6 50
        main_menu
    fi

    # Show filtered scripts
    selected_script=$(dialog --backtitle "Script Manager" \
        --title "Search Results for '$search_term'" \
        --menu "Select a script to execute or manage:" 20 50 10 \
        "${scripts[@]}" 2>&1 >/dev/tty)

    if [ $? -eq 0 ]; then
        script_submenu "$selected_script"
    else
        main_menu
    fi
}



view_by_category() {
    local category=$(dialog --menu "Select a category:" 15 50 5 \
        "Backup" "Scripts for backup tasks" \
        "Setup" "Scripts for setup tasks" \
        "Utilities" "Utility scripts" \
        "Other" "Miscellaneous scripts" 2>&1 >/dev/tty)

    [ -z "$category" ] && main_menu

    scripts=()
    for script in "$SCRIPT_DIR"/*.sh; do
        if grep -q "# Category: $category" "$script"; then
            scripts+=("$(basename "$script")" "Select this script")
        fi
    done

    if [ ${#scripts[@]} -eq 0 ]; then
        dialog --msgbox "No scripts found in category '$category'." 6 50
        main_menu
    fi

    local selected_script=$(build_menu "Scripts in Category: $category" "Select a script:" "${scripts[@]}")
    script_submenu "$selected_script"
}


assign_category() {
    category=$(dialog --menu "Select a category for this script:" 15 50 5 \
        "Backup" "Scripts for backup tasks" \
        "Setup" "Scripts for setup tasks" \
        "Utilities" "Utility scripts" \
        "Other" "Miscellaneous scripts" 2>&1 >/dev/tty)

    [ -z "$category" ] && return

    echo "# Category: $category" >> "$1"
    dialog --msgbox "Category '$category' assigned to the script." 6 50
}


export_metadata() {
    local output_file="./script_metadata.json"
    echo "[" > "$output_file"
    local first=true

    for script in "$SCRIPT_DIR"/*.sh; do
        parse_metadata "$script"
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$output_file"
        fi
        cat <<EOF >> "$output_file"
{
    "name": "$name",
    "description": "$description",
    "version": "$version",
    "author": "$author",
    "last_updated": "$updated",
    "requires_root": "$requires_root"
}
EOF
    done

    echo "]" >> "$output_file"
    dialog --msgbox "Metadata exported to $output_file" 6 50
    main_menu
}

check_for_updates() {
    local current_version="1.0.0" # Set the current version of your script manager
    local latest_version=$(curl -s "https://example.com/version" || echo "1.0.0") # Replace with your version source URL

    if [ "$current_version" != "$latest_version" ]; then
        dialog --yesno "A new version ($latest_version) is available. Do you want to update?" 10 50
        if [ $? -eq 0 ]; then
            update_script_manager
        fi
    fi
}

update_script_manager() {
    # Add logic to download and replace the current script
    curl -o script_manager.sh "https://example.com/script_manager.sh" # Replace with your update source URL
    chmod +x script_manager.sh
    dialog --msgbox "Script Manager has been updated to the latest version!" 6 50
    exit 0
}

backup_script() {
    local script_path="$1"
    local backup_dir="./backup"
    mkdir -p "$backup_dir"
    cp "$script_path" "$backup_dir/$(basename "$script_path").bak"
    dialog --msgbox "Backup created for $(basename "$script_path")." 6 50
}




delete_old_logs() {
    days=$(dialog --inputbox "Delete logs older than X days:" 10 50 2>&1 >/dev/tty)
    if [ -z "$days" ]; then
        dialog --msgbox "No value entered. Returning to the main menu." 6 50
        main_menu
    fi

    find "$LOG_DIR" -type f -mtime +"$days" -exec rm -f {} \;
    dialog --msgbox "Logs older than $days days have been deleted." 6 50
    main_menu
}

log_action() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_DIR/script_manager.log"
}




duplicate_script() {
    local script_path="$1"
    local duplicate_name=$(dialog --inputbox "Enter the name for the duplicate script (without .sh):" 10 50 2>&1 >/dev/tty)
    [ -z "$duplicate_name" ] && script_submenu "$(basename "$script_path")"

    local duplicate_path="$SCRIPT_DIR/$duplicate_name.sh"
    if [ -e "$duplicate_path" ]; then
        dialog --msgbox "A script with this name already exists!" 6 50
        script_submenu "$(basename "$script_path")"
    fi

    cp "$script_path" "$duplicate_path"
    dialog --msgbox "Script duplicated as '$duplicate_name.sh' successfully!" 6 50
    main_menu
}

handle_error() {
    local message="$1"
    dialog --msgbox "Error: $message" 6 50
    main_menu
}



schedule_script() {
    local script_path="$1"
    schedule=$(dialog --inputbox "Enter the schedule (e.g., '0 17 * * *' for 5 PM daily):" 10 50 2>&1 >/dev/tty)
    if [ -z "$schedule" ]; then
        dialog --msgbox "No schedule entered. Returning to the submenu." 6 50
        script_submenu "$(basename "$script_path")"
    fi

    cron_command="$schedule bash $script_path >> $LOG_DIR/$(basename "$script_path" .sh)_scheduled.log 2>&1"
    (crontab -l; echo "$cron_command") | crontab -
    dialog --msgbox "Script scheduled successfully!" 6 50
    main_menu
}




create_new_script() {
    # Get the current Linux username
    default_author=$(whoami)

    while true; do
        # Prompt for script name
        script_name=$(dialog --inputbox "Enter the name of the new script (without .sh):" 10 50 2>&1 >/dev/tty)
        if [ -z "$script_name" ]; then
            dialog --msgbox "No script name provided. Returning to the main menu." 6 50
            main_menu
            return
        fi

        # Check if the script already exists
        script_path="$SCRIPT_DIR/$script_name.sh"
        if [ -e "$script_path" ]; then
            dialog --msgbox "A script with this name already exists! Please choose a different name." 6 50
        else
            break
        fi
    done

    # Ask user to choose between a blank template or a pre-defined template
    template_choice=$(dialog --menu "Choose a template type:" 15 50 2 \
        "Blank" "Start with a blank script" \
        "From Template" "Use a predefined template" 2>&1 >/dev/tty)

    if [ $? -ne 0 ]; then
        main_menu
        return
    fi

    # Handle the user's choice
    if [ "$template_choice" == "Blank" ]; then
        # Create a blank script with standard metadata
        cat <<EOL > "$script_path"
#!/bin/bash
# Name: $script_name
# Description: No description provided
# Version: 1.0.0
# Author: $default_author
# Last Updated: $(date "+%Y-%m-%d")
#root: false

echo "Hello! This is your blank script template."
# Add your script logic here
EOL
    elif [ "$template_choice" == "From Template" ]; then
        # Select a template from the templates directory
        templates=()
        for template in ./templates/*.sh; do
            templates+=("$(basename "$template")" "Use this template")
        done

        if [ ${#templates[@]} -eq 0 ]; then
            dialog --msgbox "No templates found in ./templates. Please add templates first." 6 50
            main_menu
            return
        fi

        while true; do
            selected_template=$(dialog --menu "Select a template for the new script (or go back):" 20 50 10 \
                "${templates[@]}" \
                "Go Back" "Return to the template selection menu" 2>&1 >/dev/tty)

            if [ $? -ne 0 ] || [ "$selected_template" == "Go Back" ]; then
                main_menu
                return
            fi

            # Preview the selected template
            dialog --textbox "./templates/$selected_template" 20 70
            preview_choice=$(dialog --menu "What do you want to do next?" 15 50 3 \
                "Use Template" "Create the script using this template" \
                "Choose Another" "Select another template" \
                "Go Back" "Return to the template selection menu" 2>&1 >/dev/tty)

            if [ "$preview_choice" == "Use Template" ]; then
                # Copy the selected template to the new script
                cp "./templates/$selected_template" "$script_path"

                # Update metadata
                sed -i "s/^# Name:.*/# Name: $script_name/" "$script_path"
                sed -i "s/^# Author:.*/# Author: $default_author/" "$script_path"
                sed -i "s/^# Last Updated:.*/# Last Updated: $(date "+%Y-%m-%d")/" "$script_path"
                break
            elif [ "$preview_choice" == "Go Back" ]; then
                main_menu
                return
            fi
        done
    else
        dialog --msgbox "Invalid option selected. Returning to the main menu." 6 50
        main_menu
        return
    fi

    # Make the script executable
    chmod +x "$script_path"

    # Confirm script creation
    dialog --msgbox "New script '$script_name.sh' created successfully!" 6 50

    # Refresh the main menu
    main_menu
}


validate_script_name() {
    local script_name="$1"
    if [[ ! "$script_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        dialog --msgbox "Invalid script name. Use only letters, numbers, underscores, and hyphens." 6 50
        return 1
    fi
    return 0
}


setup_wizard() {
    dialog --msgbox "Welcome to the Script Manager Setup Wizard!" 6 50

    SCRIPT_DIR=$(dialog --inputbox "Enter the directory for storing scripts:" 10 50 "$SCRIPT_DIR" 2>&1 >/dev/tty)
    LOG_DIR=$(dialog --inputbox "Enter the directory for storing logs:" 10 50 "$LOG_DIR" 2>&1 >/dev/tty)

    mkdir -p "$SCRIPT_DIR" "$LOG_DIR"
    dialog --msgbox "Setup completed. Directories created!" 6 50
}


show_features() {
    local features=(
        "Create new scripts with templates"
        "View, edit, execute, duplicate, and delete scripts"
        "Search for scripts by metadata"
        "Export metadata to JSON"
        "Delete old logs"
        "Assign categories to scripts"
        "Schedule script execution with cron"
        "Structured logging and error handling"
    )
    dialog --msgbox "$(printf "%s\n" "${features[@]}")" 15 60
}



# View metadata of a script
view_metadata() {
    local script_path="$1"
    get_script_metadata "$script_path"
    dialog --backtitle "Script Manager" \
        --title "Metadata for $name" \
        --msgbox "Name: $name\nDescription: $description\nVersion: $version\nAuthor: $author\nLast Updated: $updated" 10 50
    script_submenu "$(basename "$script_path")"
}

# View the content of a script
view_script() {
    local script_path="$1"
    dialog --backtitle "Script Manager" \
        --title "Content of $name" \
        --textbox "$script_path" 20 70
    script_submenu "$(basename "$script_path")"
}

# Edit a script
edit_script() {
    local script_path="$1"
    get_script_metadata "$script_path"

    if [ "$requires_root" == "true" ]; then
        dialog --msgbox "This script requires root privileges to edit. You will be prompted for your sudo password." 8 50
        sudo nano "$script_path"
    else
        nano "$script_path"
    fi

    script_submenu "$(basename "$script_path")"
}


# Execute the selected script and log its output
execute_script() {
    local script_path="$1"
    get_script_metadata "$script_path"

    dialog --yesno "Do you want to execute:\n\nName: $name\nDescription: $description\nVersion: $version\nRequires Root: $requires_root" 10 50
    [ $? -ne 0 ] && return

    local log_file="$LOG_DIR/$(basename "$script_path" .sh)_$(date "+%Y%m%d-%H%M%S").log"
    local timeout_duration=300 # Timeout in seconds

    if [ "$requires_root" == "true" ]; then
        sudo timeout "$timeout_duration" bash "$script_path" &>> "$log_file"
    else
        timeout "$timeout_duration" bash "$script_path" &>> "$log_file"
    fi

    if [ $? -eq 124 ]; then
        dialog --msgbox "Script execution timed out after $timeout_duration seconds." 6 50
    else
        dialog --msgbox "Execution completed. Log saved to $log_file." 6 50
    fi
}




# View logs for a selected script
# View logs for a selected script
view_logs() {
    local script_name="$1"
    local script_logs=()

    # Collect log files for the specific script
    for log_file in "$LOG_DIR/${script_name%.sh}"*; do
        if [ -e "$log_file" ]; then
            script_logs+=("$log_file" "$(basename "$log_file")")
        fi
    done

    # If no logs exist, display a message and return to submenu
    if [ ${#script_logs[@]} -eq 0 ]; then
        dialog --msgbox "No logs found for $script_name." 6 50
        script_submenu "$script_name"
        return
    fi

    # Display logs in a menu
    selected_log=$(dialog --backtitle "Script Manager" \
        --title "Logs for $script_name" \
        --menu "Select a log file to view:" 20 70 10 \
        "${script_logs[@]}" 2>&1 >/dev/tty)

    # If a log is selected, display its content
    if [ $? -eq 0 ]; then
        dialog --backtitle "Script Manager" \
            --title "Log: $(basename "$selected_log")" \
            --textbox "$selected_log" 20 70
    fi

    # Return to the script submenu
    script_submenu "$script_name"
}


# Run the main menu
main_menu
