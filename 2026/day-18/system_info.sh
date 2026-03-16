#!/bin/bash
set -euo pipefail

print_header() {
    echo ""
    echo "============================================"
    echo "  $1"
    echo "============================================"
}

system_info() {
    print_header "HOSTNAME & OS INFO"
    echo "Hostname : $(hostname)"
    echo "OS       : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
    echo "Kernel   : $(uname -r)"
}

uptime_info() {
    print_header "UPTIME"
    uptime -p
}

disk_usage() {
    print_header "TOP 5 DISK USAGE"
    df -h --output=source,size,used,avail,pcent,target | head -6
}

memory_usage() {
    print_header "MEMORY USAGE"
    free -h
}

top_processes() {
    print_header "TOP 5 CPU-CONSUMING PROCESSES"
    ps aux --sort=-%cpu | awk 'NR==1 || NR<=6 {printf "%-10s %-6s %-6s %s\n", $1, $2, $3, $11}'
}

main() {
    echo "System Info Report — $(date)"
    system_info
    uptime_info
    disk_usage
    memory_usage
    top_processes
    echo ""
    echo "Report complete."
}

main
