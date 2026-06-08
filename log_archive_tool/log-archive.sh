#!/bin/bash


check_arguments() {
    LOG_DIR="$1"
    if [ -z "$LOG_DIR" ]; then
        echo "No arguments provided. Please specify the log directory."
        exit 1
    fi

    if [ ! -d "$LOG_DIR" ]; then
        echo "Directory does not exist: $LOG_DIR"
        exit 1
    fi
}

create_archive_dir() {
    ARCHIVE_DIR="$HOME/log_archives"

    if [ ! -d "$ARCHIVE_DIR" ]; then
        mkdir -p "$ARCHIVE_DIR"
    fi
}

generate_filename() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S) 
    FILENAME="$ARCHIVE_DIR/logs_archive_$TIMESTAMP.tar.gz"
}

compress_logs() {
    tar -czf "$FILENAME" -C "$LOG_DIR" .
}

log_archive() {
    echo "Logs from $LOG_DIR archived to $FILENAME" >> $ARCHIVE_DIR/archive_log.txt
}

notify_user() {
     echo "Logs have been archived to: $FILENAME"
}


check_arguments "$1"
create_archive_dir
generate_filename
compress_logs
log_archive
notify_user