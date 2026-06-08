
https://roadmap.sh/projects/log-archive-tool


# 🗂️ Log Archive Tool

A lightweight Bash script that compresses and archives log files from a specified directory into timestamped `.tar.gz` files.

## 📋 Overview

This tool automates log archiving by:
- Validating the provided log directory
- Creating a dedicated archive directory (`~/log_archives`)
- Compressing logs into a timestamped archive
- Logging each archive operation to a record file

## 🚀 Usage

```bash
bash log_archive.sh <log_directory>
```

### Example

```bash
bash log_archive.sh /var/log
```

## ⚙️ How It Works

| Step | Function | Description |
|------|----------|-------------|
| 1 | `check_arguments` | Validates that a directory argument is provided and exists |
| 2 | `create_archive_dir` | Creates `~/log_archives` if it doesn't already exist |
| 3 | `generate_filename` | Generates a timestamped filename: `logs_archive_YYYYMMDD_HHMMSS.tar.gz` |
| 4 | `compress_logs` | Compresses all files in the log directory using `tar -czf` |
| 5 | `log_archive` | Appends an entry to `~/log_archives/archive_log.txt` |
| 6 | `notify_user` | Prints the archive path to the terminal |

## 📁 Output Structure

```
~/log_archives/
├── logs_archive_20250608_143022.tar.gz
├── logs_archive_20250609_091500.tar.gz
└── archive_log.txt
```

### `archive_log.txt` Sample

```
Logs from /var/log archived to /Users/you/log_archives/logs_archive_20250608_143022.tar.gz
Logs from /var/log archived to /Users/you/log_archives/logs_archive_20250609_091500.tar.gz
```

## ❗ Error Handling

- If no argument is provided → exits with a usage message
- If the specified directory does not exist → exits with an error message

## 🛠️ Requirements

- Bash
- `tar` (available by default on macOS and Linux)

## 📌 Notes

- Archives are stored in `~/log_archives`, not in the original log directory
- Each archive has a unique timestamp to prevent overwriting
- The script archives the **contents** of the given directory, not the directory itself

## 👩‍💻 Author

asiyeturedii — [GitHub](https://github.com/asiyeturedii)
