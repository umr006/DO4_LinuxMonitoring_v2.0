#!/bin/bash

function check_space() {
    local available_space=$(df --output=avail / | tail -1)
    local min_space=$((1024 * 1024))
    
    if [[ $available_space -lt $min_space ]]; then
        echo "Error: Not enough space to create files. Aborting."
        exit 1
    fi
}

function generate_name() {
    local chars="$1"
    local min_length=5
    local name=""
    
    for ((i=0; i<$min_length; i++)); do
        name="${name}${chars:$((RANDOM % ${#chars})):1}"
    done
    
    echo "${name}"
}


function dot_in_str() {
	string="$1"
	for ((i=0; i<${#string}; i++)); do
		if [ "${string:i:1}" == "." ]; then
			echo "$i"
			break
		fi
	done
}

function create_folders_and_files() {
	local folder_chars="$1"
	local file_chars="$2"
	local ext_chars="${file_chars:$(dot_in_str "$filechars"):3}"
	local file_size_mb="$3"
	local log_file="$4"
	local data_suffix=$(date '+%d%m%y')


	for ((i=0; i<100; i++)); do
		check_space

		local folder_name="$(generate_name "$folder_chars")_${data_suffix}"
		local folder_path="$(pwd)/log/${folder_name}"
		mkdir -p "$folder_path"

		local num_files=$((RANDOM % 100 + 1))

		for ((j=0; j<$num_files; j++)); do 
			check_space

			local file_name="$(generate_name "$file_chars")_${data_suffix}"
			local file_ext="$(generate_name "$ext_chars")"
			local file_path="${folder_size_mb}/${file_name}.${file_ext}"

			truncate -s "${file_size_mb}M" "$file_path"

			echo "$(date '+%Y-%m-%d %H:%M:%S') | Created: ${file_path} | Size: ${file_size_mb}M" >> "$log_file"

		done

	done

}


function main() {
	if [[ $# -ne 3 ]]; then
		echo "Error: few or many arguments"
		exit 1
	fi

	local folder_chars="$1"
	local file_chars="$2"
	local file_size_mb="$3"

	if ! [[ $file_size_mb =~ ^[0-9]+$ ]]; then
		echo "Error: $3 is not a number" 
		exit 1
	fi


	if [[ $file_size_mb -gt 100 ]]; then 
		echo "Error: the file must not exceed 100mb"
		exit 1
	fi

	local log_file="$(pwd)/log/create_log_$(date '+%d%m%y').txt"
	local start_time=$(date '+%Y-%m-%d %H:%M:%S')
	local start_seconds=$(date +%s)

	create_folders_and_files "$folder_chars" "$file_chars" "$folder_size_mb" "$log_file"

	local end_time=$(date '+%Y-%m-%d %H:%M:%S')
	local end_seconds=$(date +%s)
    local total_time=$((end_seconds - start_seconds))

    echo "Start time: $start_time" >> "$log_file"
    echo "End time: $end_time" >> "$log_file"
    echo "Total running time: ${total_time} seconds" >> "$log_file"
    
    echo "Start time: $start_time"
    echo "End time: $end_time"
    echo "Total running time: ${total_time} seconds"
}

main "$@"