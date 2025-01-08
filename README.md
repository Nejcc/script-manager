Script Manager
The Script Manager is a Bash-based utility that helps manage, organize, and execute shell scripts with ease. It provides features like script creation, metadata handling, log management, backups, and more, all accessible through a user-friendly dialog-based interface.

Features
Create Scripts: Generate new scripts using a blank template or predefined templates.
View and Edit: Easily view or edit existing scripts.
Execute Scripts: Run scripts with logging, and handle root access if required.
Backup Scripts: Automatically create backups when editing scripts.
Search Scripts: Search scripts by name, description, or author metadata.
View by Category: Organize and filter scripts by categories (e.g., Backup, Setup, Utilities).
Schedule Scripts: Schedule scripts for periodic execution using cron.
Export Metadata: Export script metadata (name, version, description, etc.) to a JSON file for documentation.
Delete Old Logs: Clean up old logs by specifying an age threshold.
Help and Features: Built-in help menu and feature list.
Requirements
Operating System: Linux-based OS with Bash.
Dependencies:
dialog package (automatically installed if missing).
Setup
Clone the repository or copy the script to your desired location:

bash
Copy code
git clone https://github.com/your-repo/script-manager.git
cd script-manager
Ensure the script is executable:

bash
Copy code
chmod +x script_manager.sh
Run the script:

bash
Copy code
./script_manager.sh
Directory Structure
The script manager automatically sets up the following directories:

./src: Stores all your scripts.
./logs: Logs generated during script execution.
./backup: Backups of edited scripts.
./templates (optional): Templates for new scripts.

Metadata Structure
Scripts are expected to include metadata in the following format:

bash
Copy code
# Name: Example Script
# Description: This script does something useful.
# Version: 1.0.0
# Author: Your Name
# Last Updated: YYYY-MM-DD
#root: false
This metadata is used for display, search, and export functionalities.

Main Menu Options
Create a New Script: Start with a blank template or choose a predefined one.
Search Scripts: Search for scripts by name, description, or author metadata.
View Scripts by Category: List scripts based on predefined categories (e.g., Backup, Setup, Utilities).
Export Metadata: Save all script metadata to a JSON file.
Delete Old Logs: Remove logs older than a specified number of days.
Show Features: View the complete list of features.
Help: View detailed help instructions.
Example Usage
Create a New Script:

Select the "Create New Script" option from the menu.
Choose between a blank or predefined template.
Provide a name and start coding!
Search Scripts:

Enter a keyword to search in script names, descriptions, or authors.
Select a script from the results to manage it.
Execute a Script:

Select a script and choose the "Execute Script" option.
Logs will be saved in the ./logs directory.
Schedule a Script:

Set up a cron schedule for periodic execution (e.g., 0 17 * * * for 5 PM daily).
Delete Old Logs:

Specify the age threshold (e.g., 30 days) to remove outdated logs.
Configuration
Change Directories
You can configure the directories for storing scripts and logs by editing the following variables in the script:

bash
Copy code
SCRIPT_DIR="./src"
LOG_DIR="./logs"
BACKUP_DIR="./backup"
Alternatively, use the Setup Wizard to set custom directories from the menu.

Exported Metadata Example
When exporting metadata, the generated JSON file (script_metadata.json) will look like this:

json
Copy code
[
    {
        "name": "Example Script",
        "description": "This script does something useful.",
        "version": "1.0.0",
        "author": "Your Name",
        "last_updated": "2025-01-08",
        "requires_root": "false"
    }
]
Future Improvements
Integration with external version control systems like git.
Advanced analytics for script execution performance.
Enhanced template management with interactive previews.
Troubleshooting
dialog not found
If the dialog package is not installed, the script will attempt to install it automatically. If it fails, you can manually install it using:

bash
Copy code
sudo pacman -S dialog    # For Arch-based distros
sudo apt install dialog  # For Debian-based distros
Permission Denied
Ensure the script has execute permissions:

bash
Copy code
chmod +x script_manager.sh
Logs Not Generated
Ensure the ./logs directory exists and has write permissions:

bash
Copy code
mkdir -p ./logs
chmod -R 755 ./logs
License
This project is licensed under the MIT License. Feel free to use, modify, and distribute it as needed.

