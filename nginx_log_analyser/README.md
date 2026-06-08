# Nginx Log Analyser
https://roadmap.sh/projects/nginx-log-analyser


A simple shell script to analyze nginx access logs from the command line.

## What it does

Reads an nginx access log file and outputs:

- **Top 5 IP addresses** with the most requests
- **Top 5 most requested paths**
- **Top 5 response status codes**
- **Top 5 user agents**

## Usage

```bash
./log-analyser.sh
```

Make sure `nginx-access.log` is in the same directory as the script.

## Example Output

```
Top 5 IP addresses with the most requests:
178.128.94.113 - 1087 requests
142.93.136.176 - 1087 requests
138.68.248.85 - 1087 requests
159.89.185.30 - 1086 requests
86.134.118.70 - 277 requests

Top 5 most requested paths:
/v1-health - 4560 requests
/ - 270 requests
/v1-me - 232 requests
/v1-list-workspaces - 127 requests
/v1-list-timezone-teams - 75 requests

Top 5 most requested status codes:
200 - 5740 requests
404 - 937 requests
304 - 621 requests
400 - 192 requests

Top 5 most requested user agents:
DigitalOcean Uptime Probe 0.22.0 (https://digitalocean.com) - 4347 requests
Mozilla/5.0 (Windows NT 10.0; Win64; x64) ... Chrome/129.0.0.0 Safari/537.36 - 513 requests
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ... Chrome/129.0.0.0 Safari/537.36 - 332 requests
Custom-AsyncHttpClient - 294 requests
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ... Chrome/128.0.0.0 Safari/537.36 - 282 requests
```

## How it works

Uses standard Unix tools chained together with pipes (`|`):

- `awk` — extract specific fields from each log line
- `sort` — group identical values together
- `uniq -c` — count occurrences
- `sort -nr` — sort numerically in descending order
- `head -5` — take only the top 5 results

## Requirements

- Bash
- Standard Unix tools (`awk`, `sort`, `uniq`, `head`)
