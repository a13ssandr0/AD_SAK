FROM bash:latest

COPY pcapper.py /
COPY vm_init.sh /

ENV USER="root"

ENV IFACE="game"
ENV OUTDIR="/tmp/game_pcaps"
ENV INTERVAL="30"

CMD ["bash", "/vm_init.sh"]
