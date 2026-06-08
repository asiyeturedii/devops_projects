
#!/bin/bash


echo "Top 5 IP addresses with the most requests:"
awk '{print $1}' nginx-access.log | sort | uniq -c | sort -nr | head -5 | awk '{print $2, "-", $1, "requests"}'

echo "Top 5 most requested paths:"
awk '{print $7}' nginx-access.log | sort | uniq -c | sort -nr | head -5 | awk '{print $2, "-", $1, "requests"}'

echo "Top 5 most requested status codes:"
awk '{print $9}' nginx-access.log | sort | uniq -c | sort -nr | head -5 | awk '{print $2, "-", $1, "requests"}'

echo "Top 5 most requested user agents:"
awk -F'"' '{print $6}' nginx-access.log | sort | uniq -c | sort -nr | head -5 | awk '{count=$1; $1=""; print substr($0,2), "-", count, "requests"}'