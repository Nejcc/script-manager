import psutil
import time
import json
import os

# Path to the usage stats log file
LOG_FILE = os.path.expanduser("~/.usage_stats.json")

# Function to load usage stats from file
def load_usage_stats():
    if os.path.exists(LOG_FILE):
        with open(LOG_FILE, "r") as file:
            return json.load(file)
    return {}

# Function to save usage stats to file
def save_usage_stats(stats):
    with open(LOG_FILE, "w") as file:
        json.dump(stats, file, indent=4)

# Function to monitor running processes
def monitor_program_usage():
    # Load the current usage stats
    usage_stats = load_usage_stats()

    while True:
        try:
            # Get a list of currently running programs
            active_programs = [proc.name() for proc in psutil.process_iter(['name'])]

            # Update usage stats
            for program in active_programs:
                if program in usage_stats:
                    usage_stats[program] += 1
                else:
                    usage_stats[program] = 1

            # Save updated stats to the log file
            save_usage_stats(usage_stats)

            # Wait before checking again
            time.sleep(5)

        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    print("Monitoring program usage... Press Ctrl+C to stop.")
    try:
        monitor_program_usage()
    except KeyboardInterrupt:
        print("\nExiting program.")
