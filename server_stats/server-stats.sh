#!/bin/bash

# Görsel düzen için çizgi fonksiyonu
print_marquee() {
    echo "========================================================"
    echo "  $1"
    echo "========================================================"
}

# 1. Toplam CPU Kullanımı
get_cpu_usage() {
    print_marquee "TOTAL CPU USAGE"
    top -l 1 | grep "CPU usage" | awk '{print "Total CPU usage: " $3 + $5 "%"}'
    echo ""
}

# 2. Total Bellek (Memory) Kullanımı
# 2. Total Bellek (Memory) Kullanımı
get_memory_usage() {
    print_marquee "TOTAL MEMORY USAGE (Free vs Used)"
    
    awk -v total=$(sysctl hw.memsize | awk '{print $2}') -v free=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.') 'BEGIN {
        free_bytes = free * 4096
        total_gb = total / 1073741824
        free_percent = free_bytes * 100 / total
        used_percent = 100 - free_percent

        print "Total Memory: " total_gb " GB"
        print "Free Percent: " free_percent "%"
        print "Used Percent: " used_percent "%"
    }'
    echo ""
}

# 3. Total Disk Kullanımı
get_disk_usage() {
    print_marquee "TOTAL DISK USAGE (Free vs Used)"
    df -h / | awk 'NR==2 {
        print "Total Space: " $2
        print "Used Space:  " $3
        print "Free Space:  " $4
        print "Usage:       " $5
    }'
    echo ""
}

# 4. En Çok CPU Tüketen İlk 5 process
get_top_cpu_processes() {
    print_marquee "TOP 5 PROCESSES BY CPU USAGE"
    
    ps -eo pid,%cpu,command | sort -rnk 2 | head -n 6
    
    echo ""
}

# En Çok Memory (RAM) Tüketen İlk 5 process
get_top_mem_processes() {
    print_marquee "TOP 5 PROCESSES BY MEMORY USAGE"
    
    ps -eo pid,%mem,command | sort -rnk 2 | head -n 6
    
    echo ""
}

# 6. Esnetme Hedefleri (Stretch Goals - Opsiyonel)
get_extra_stats() {
    print_marquee "SYSTEM EXTRA STATS"
    
    printf "OS Version:      $(sw_vers -productVersion)\n" 
    echo "System Uptime:   $(uptime)"
    echo "Logged In Users: $(users)"
    
    echo ""
}

# ==============================================================================
# ANA ÇALISTIRICI (MAIN EXECUTION)
# ==============================================================================
clear
echo "STATION PERFORMANCE REPORT - $(date)"
echo ""
get_cpu_usage
get_memory_usage
get_disk_usage
get_top_cpu_processes
get_top_mem_processes
get_extra_stats

echo "========================================================"
echo "REPORT GENERATION COMPLETED"
echo "========================================================"