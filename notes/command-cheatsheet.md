# Command cheat sheet

## Networking and system

| Command | What it does |
| --- | --- |
| `ip -br a` | Brief list of network cards and their IPs |
| `ip route` | Routing table, including the default gateway |
| `ping -c 3 10.0.2.1` | Send 3 pings to test reachability |
| `curl -I https://site` | Fetch only the headers: a quick reachability test |
| `sudo ss -tlnp` | Listening TCP ports and the program that owns each |
| `sudo tcpdump -ni ens33 tcp port 22 -c 6` | Capture 6 packets on port 22 |
| `dig example.com` / `dig -x <ip>` | DNS lookup / reverse lookup |
| `timedatectl` | Clock, timezone and NTP sync status |
| `sudo date -s "1 hour ago"` | Move the clock back 1 hour |

## Services and logs

| Command | What it does |
| --- | --- |
| `systemctl is-active <service>` | One-word status |
| `sudo systemctl restart <service>` | Restart so the service rereads its config |
| `sudo journalctl -u <service> -b --no-pager` | A service's logs since boot |
| `grep -i <word> <file>` | Matching lines (`-c` counts, `-E` allows `a\|b`) |
| `tail -n 20 <file>` | Last 20 lines |
| `sudo tee -a <file> <<'EOF'` | Append a block of text to a root-owned file |
| `sudo sed -i 's/old/new/' <file>` | Replace text in a file |

## SSH and firewall

| Command | What it does |
| --- | --- |
| `ssh-keygen -t ed25519` | Create a key pair |
| `ssh-copy-id user@host` | Install my public key on a server |
| `sudo ufw status verbose` | Host firewall rules |
| `sudo ufw allow from 10.0.1.101 to any port 22 proto tcp` | SSH from one IP only |

## Docker

| Command | What it does |
| --- | --- |
| `docker ps` / `docker ps -a` | Running / all containers |
| `docker logs <name>` | A container's output |
| `docker compose up -d` | Start a multi-container app |

## Wazuh

| Command | What it does |
| --- | --- |
| `systemctl is-active wazuh-indexer wazuh-manager wazuh-dashboard filebeat` | Server health |
| `sudo grep "auth.log" /var/ossec/logs/ossec.log` | Is the agent reading auth.log? |
| `sudo grep -E "^status\|last_ack" /var/ossec/var/run/wazuh-agentd.state` | Is the agent connected? |
| `sudo grep <word> /var/ossec/logs/alerts/alerts.log` | Did the manager raise an alert? |
| `sudo filebeat test output` | Can Filebeat reach the indexer? |
| `GET _cat/indices/wazuh-alerts-*?v` | (Dev Tools) Daily alert indices and counts |
