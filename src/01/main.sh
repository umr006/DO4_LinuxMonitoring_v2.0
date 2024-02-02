#!/bin/bash

start=$(date +%s.%N)

function generate_name() {
	local chars="$1"
	local len=4
	local name=""

	for ((i = 0; i<$len; i++)); do
		name="${name}${chars:$((RANDOM % ${#chars})):1}"
	done

	echo "${name}"
}

function check_space() {
	local avail_space=$(df --output=avail / | tail -1)
	local min_space=$((1024 * 1024))

	if [[ $avail_space -lt $min_space ]]; then
		echo "Error: Not enough space to create files."
		exit 1
	fi
}


function create_folders_and_files() {
	local base_path="$1"
	local num_folders="$2"
	local folder_chars="$3"
	local num_files="$4"
	local file_chars="$5"
	local file_size_kb="$6"
	local log_file="$7"
	local ext_chars="${file_chars:0:3}"
	local date_suffix=$(date '+%d%m%y')
	# Создаем вложенные папки с именами, содержащими указанные символы
	for ((i=0; i<$num_folders; i++)); do
		check_space
        local folder_name="$(generate_name "$folder_chars")_${date_suffix}"
        local folder_path="${base_path}/${folder_name}"
		mkdir -p "$folder_path"
		# Создаем файлы с именами, включающими указанные символы и указанный размер
		for ((j=0; j<$num_files; j++)); do
			check_space

			local file_name="$(generate_name "%file_chars")_${date_suffix}"
			local file_ext="$(generate_name "%ext_chars")"
			local file_path="${folder_path}/${file_name}".${file_ext}

			fallocate -l "${file_size_kb}K" "$file_path"
			echo "$(date '+%Y-%m-%d %H:%M:%S') | Created: ${file_path} | Size: ${file_size_kb}K" >> "$log_file"
		done
	done
}


function main() {
	if [[ $# -ne 6 ]]; then
		echo "Error: few or many arguments"
		exit 1
	fi
	
	local base_path="$1"
	local num_folders="$2"
	local folder_chars="$3"
	local num_files="$4"
	local file_chars="$5"
	local file_size_kb="$6"
	
	if ! [[ $num_folders =~ ^[0-9]+$ ]] || ! [[ $num_files =~ ^[0-9]+$ ]] || ! [[ $file_size_kb =~ ^[0-9]+$ ]]; then
		echo "Error: One of the arguments is not a number."
		exit 1
	fi
	
	if [[ $file_size_kb -gt 100 ]]; then
			echo "The file must not exceed 100"
		exit 1
	fi
	
	local log_file="${base_path}/creation_log_$(date '+%d%m%y').txt"
	create_folders_and_files "$base_path" "$num_folders" "$folder_chars" "$num_files" "$file_chars" "$file_size_kb" "$log_file"
}

main "$@"

end=$(date +%s.%N)
elapsed_time=$(echo "$end - $start" | bc)
echo "Script execution time (in seconds) = $elapsed_time"