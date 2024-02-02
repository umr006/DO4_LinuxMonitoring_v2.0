function delete_file_or_path() {
  if [ -f "$1" ]; then
    rm -f "$1"
    echo "Deleted: $1"
  elif [[ -d "$1" ]]; then
    rm -rf "$1"
    echo "Deleted: $1"
  fi
}
#2023-10-31 00:03:36 | Created: log/ddzz_311023/llsl_311023.x_t_ | Size: 50K
function delete_content_log_file() {
  if [ ! -f "$1" ]; then
    echo "Error: log file $1 not found"
    exit 1
  fi

  declare -A direct
  
  while read -r line; do 
    local file_path=$(echo "$line" | awk -F '|' '{print $2}' | awk '{print $2}')
    local cur_pwd=$(dirname "$file_path")

    if [[ -e "$file_path" ]]; then
      delete_file_or_path "$file_path"
    fi
    dir["$cur_pwd"] = 1
  done < "$1"

  for dir in "${!direct[@]}"; do
    if [[ -d "$dir" ]]; then
      delete_file_or_path "$dir"
    fi
  done

  rm -rf "$1"
}

function delete_by_time() {
  local start_time="$1"
  local end_time="$2"
  
  local start_timestamp=$(date -d "$start_time" +%s)
  local end_timestamp=$(date -d "$end_time" +%s)

  find / -not \( -path /bin -prune -o -path /sbin -prune \) -type f,d -printf "%Ts|%p\n" 2>/dev/null | while read -r line; do
  	local created_timestamp=$(echo "$line" | awk -F '|' '{print $1}')
    local file_path=$(echo "$line" | awk -F '|' '{print $2}')

    if [[ "$created_timestamp" -gt "$start_timestamp" && "$created_timestamp" -lt "$end_timestamp" ]]; then
      if [[ -e "$file_path" ]]; then
        delete_file_or_path "$file_path"
  	  fi
    fi
  done
}

function delete_by_name_mask() {
    local name_mask="$1"
    find / -not \( -path /bin -prune -o -path /sbin -prune \) -type f,d -name "${name_mask}*" 2>/dev/null | while read -r file_path; do
        if [[ -e "$file_path" ]]; then
            delete_path "$file_path"
        fi
    done
}


function main() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <method>"
    exit 1
  fi

  local method="$1"

  if [[ method -eq 1 ]]; then 
    echo "Enter the file path:"
    read -r log_file
    delete_content_log_file "$log_file"
  elif [[ method -eq 2 ]]; then
    echo "Enter the start time (Format: YYYY-MM-DD HH:MM)"
    read -r start_time
    echo "Enter the end time (Format: YYYY-MM-DD HH:MM)"
    read -r end_time
    delete_by_time "$start_time" "$end_time"
  elif [[ method -eq 3 ]]; then
    echo "Enter the name mask:"
    read -r name_mask
    delete_by_name_mask "$name_mask"
  else
    echo "Invalid method"
    exit 1
  fi
}

main "$@"
