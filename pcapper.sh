#!/bin/bash

# Verifica dipendenze
command -v tcpdump &>/dev/null || { echo "tcpdump non trovato"; exit 1; }

mkdir -p "$OUTDIR"

echo "Avvio cattura su $IFACE — file ruotati ogni ${INTERVAL}s in $OUTDIR"
echo "Premi Ctrl+C per fermare."

# Gestione segnale: termina tcpdump corrente prima di uscire
cleanup() {
    echo -e "\nArresto cattura."
    [[ -n "$TCPDUMP_PID" ]] && kill "$TCPDUMP_PID" 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

while true; do
    OUTFILE="$OUTDIR/capture_$(date +'%Y_%m_%d__%H_%M_%S').pcap"

    echo "[$(date '+%H:%M:%S')] Scrittura su: $OUTFILE"

    # Avvia tcpdump in background per INTERVAL secondi
    tcpdump -i "$IFACE" -w "$OUTFILE" &
    TCPDUMP_PID=$!

    sleep "$INTERVAL"

    kill "$TCPDUMP_PID" 2>/dev/null
    wait "$TCPDUMP_PID" 2>/dev/null

    curl -X POST "http://localhost:3344/api/pcap/upload" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@$OUTFILE" \
    -F "flush_all=false"
done