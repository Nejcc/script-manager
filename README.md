
# Script Manager

A comprehensive, user-friendly **Bash Script Manager** that allows you to create, manage, execute, and schedule scripts with ease. This project is designed to enhance productivity and streamline the workflow for managing shell scripts.

---

## Features

- **Create Scripts**: Use blank or predefined templates to create scripts effortlessly.
- **Search Scripts**: Quickly search by name, description, or author.
- **Execute Scripts**: Run scripts with optional logging and timeout functionality.
- **Duplicate Scripts**: Make copies of existing scripts.
- **View Metadata**: Check details like name, description, author, version, and more.
- **Assign Categories**: Organize scripts into categories for better management.
- **Schedule Scripts**: Set up cron jobs to automate execution.
- **Export Metadata**: Export all script details to a JSON file for documentation or analysis.
- **Delete Old Logs**: Clean up outdated logs to save space.
- **Setup Wizard**: Configure directories and settings via an interactive wizard.

---

## Requirements

- **Bash**: Ensure your system supports Bash scripts.
- **Dialog**: Install `dialog` for interactive CLI menus.
  ```bash
  sudo pacman -S --noconfirm dialog
  ```

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/script-manager.git
   cd script-manager
   ```

2. Make the main script executable:
   ```bash
   chmod +x script_manager.sh
   ```

3. Run the script:
   ```bash
   ./script_manager.sh
   ```

---

## Usage

1. **Main Menu**:
   - Select from options like creating new scripts, searching, exporting metadata, and more.

2. **Script Management**:
   - View, edit, execute, duplicate, schedule, or delete a selected script.

3. **Setup Wizard**:
   - Configure directories for scripts and logs via the setup wizard.

---

## File Structure

```
.
├── src/                # Directory for storing your scripts
├── logs/               # Directory for storing log files
├── templates/          # Directory for predefined script templates
├── backup/             # Directory for backup files
├── script_manager.sh   # Main script
├── script_metadata.json # Exported metadata
├── README.md           # Documentation
└── .gitignore          # Git ignore rules
```

---

## Contribution

Contributions are welcome! If you have ideas or improvements, please open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License. See `LICENSE` for more details.

---

## Support

For any questions or support, please contact [info@after.si](mailto:info@after.si).
