#!/bin/bash

#38.19.78.205 - - [30/окт/2023:00:29:52 +0500] "PUT /path/to/resource HTTP/1.1" 403 0 "-" "Opera"
#105.55.15.88 - user [02/ноя/2023:00:17:34 +0500] "GET /example.html HTTP/1.1" 403 3 "http://www.example.com" Safari
#192.168.1.100 - john [10/Nov/2023:12:34:56 +0300] "GET /example.html HTTP/1.1" 200 1234 "http://www.example.com/referer-page.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.61 Safari/537.36"

declare -a response_codes=("200" "201" "400" "401" "403" "404" "500" "501" "502" "503")
declare -a user_agents=("Mozilla" "Google Chrome" "Opera" "Safari" "Internet Explorer" "Microsoft Edge" "Crawler and bot" "Library and net tool")
declare -a methods=("GET" "POST" "PUT" "PATCH" "DELETE")

for j in {1..5}; do
	file_name="log_file${j}.log"
	cnt=$(shuf -i 100-1000 -n 1)
	touch "$file_name"
	for ((i=1; i<cnt; i++)); do
		ip="$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1)"
		response_code="${response_codes[$(shuf -i 0-9 -n 1)]}"
		method="${methods[$(shuf -i 0-4 -n 1)]}"
		user_agents="${user_agents[$(shuf -i 0-7 -n 1)]}"
		date="$(date -d "today -${i} days" "+%d/%b/%Y:%H:%M:%S %z")"
		echo "$ip - user [$date] \"$method /example.html HTTP/1.1\" $response_code 3 \"http://www.example.com\" \"$user_agents\"" >> "$file_name"

	done
done