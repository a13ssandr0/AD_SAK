# Attack/Defence Swiss Army Knife

Easy to setup toolbox that includes **DestructiveFarm** and **caronte**
and automatically sets up the game vulnbox

## Startup

### 1. Clone the repository

```bash
git clone https://github.com/a13ssandr0/AD_SAK.git
```

### 2. Open docker-compose.yml and configure

- Set flag format finding `FLAG_FORMAT` and `DF_FLAG_FORMAT` and setting their value to the correct regular expression (regex) that matches the flag string.
- In `traffic_capture` set variables `USER` (usally root), `PASS` and `HOST`.
- In `destructivefarm` set the `DF_SYSTEM_TOKEN` and change the system protocol and the endpoints if required.

### 3. Start the containers
```bash
docker compose up -d
```

After startup you can find:
- `caronte` at `http://localhost:3333`
- `DestructiveFarm` at `http://localhost:5000`

NOTE!!!: DestructiveFarm persists the flags database
to avoid sending the same flags multiple times, 
**ALWAYS REMEMBER** to use the `Delete flags DB` button
in the web interface to clear the database.

## Scripts for DestructiveFarm

To launch the exploit find the script `start_sploit.py` inside `DestructiveFarm/client` like
```bash
./start_sploit.py sploit.py -u http://localhost:5000
# '-u http://localhost:5000' may be omitted but sometimes doesn't work
```
To write sploit.py refer to [exploit format](DestructiveFarm/docs/en/exploit_format.md))

