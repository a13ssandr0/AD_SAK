#!/usr/bin/env python3

import os
from pathlib import Path
from subprocess import CalledProcessError, run, check_output, Popen
from datetime import datetime
from time import sleep
from random import randrange

try:
    import requests
except ModuleNotFoundError:
    run("apt update", shell=True)
    run("apt install python3-requests", shell=True)
    import requests

try:
    import yaml
except ModuleNotFoundError:
    run("apt update", shell=True)
    run("apt install python3-yaml", shell=True)
    import yaml

try:
    check_output("command -v tcpdump", shell=True)
except CalledProcessError:
    run("apt update", shell=True)
    run("apt install tcpdump", shell=True)

colors = [
    "#e53935",
    "#d81b60",
    "#8e24aa",
    "#5e35b1",
    "#3949ab",
    "#1e88e5",
    "#039be5",
    "#00acc1",
    "#00897b",
    "#43a047",
    "#7cb342",
    "#9e9d24",
    "#f9a825",
    "#fb8c00",
    "#f4511e",
    "#6d4c41",
]
picked_colors = []


def pick_rand_col():
    rnd_idx = randrange(0, len(colors))
    col = colors[rnd_idx]
    if len(picked_colors) == len(colors):
        picked_colors.clear()

    if col in picked_colors:
        return pick_rand_col()
    else:
        return col


for file in Path.home().glob("*/*compose.y*ml"):
    service_name = file.parent.stem
    with open(file.absolute()) as stream:
        for name, settings in yaml.safe_load(stream).get("services", {}).items():
            for port in settings.get("ports", []):
                port = port.split(":")[0]
                print(
                    requests.put(
                        "http://localhost:3344/api/services",
                        json={
                            "port": int(port),
                            "name": f"{name}@{service_name}",
                            "color": pick_rand_col(),
                            "notes": "",
                        },
                    ).text
                )

outdir = Path(os.environ["OUTDIR"])
iface = os.environ.get("IFACE", "game")
interval = int(os.environ["INTERVAL"])

print("Starting capture on", os.environ)
print("Captures saved in", outdir)
print("Captures updated each", interval, "seconds")

try:
    while True:
        outfile = outdir.joinpath(f'capture_{datetime.now():"%Y_%m_%d__%H_%M_%S"}.pcap')
        print("Recording on", outfile)

        tcp_dump = Popen(["tcpdump", "-i", iface, "-w", str(outfile)])

        sleep(interval)

        tcp_dump.kill()
        tcp_dump.wait()

        print(
            requests.post(
                "http://localhost:3344/api/pcap/upload",
                files={"file": open(outfile, "rb"), "flush_all": (None, "false")},
            ).text
        )
except KeyboardInterrupt:
    print("Stopping capture.")
