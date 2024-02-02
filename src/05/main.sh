#!/bin/bash

file_path="$(pwd)/file.log"

#65.254.221.207 - - [03/Nov/2023:12:27:14 +0000] "DELETE /path/to/resource HTTP/1.1" 200 0 "-" "Safari"

function sort_resp_code() {
    awk '{print $9, $0}' "$file_path" | sort -k1,1n | cut -d ' ' -f2-
}

function unique_ip() {
    awk '{print $1}' "$file_path" | sort -u
}

function error_sort_resp_code() {
    awk '$9 >= 400 && $9 <= 600 {print}' "$file_path"
}

function unique_ip_error() {
    awk '$9 >= 400 && $9 <= 600 {print $1}' "$file_path" | sort -u
}

option="$1"

if [[ option -eq 1 ]]; then
    sort_resp_code
elif [[ option -eq 2 ]]; then
    unique_ip
elif [[ option -eq 3 ]]; then
    error_sort_resp_code
elif [[ option -eq 4 ]]; then
    unique_ip_error
elif [[ option -gt 4 || $# -gt 1 ]]; then
    echo "Error: use 1-4 or there are more than one arguments"
    exit 1
fi

