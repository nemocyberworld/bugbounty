#!/bin/bash

read -p "Enter your target domain: " DOMAIN
OUTPUT_DIR="results/$DOMAIN"
mkdir -p "$OUTPUT_DIR"

WORDLIST="/usr/share/wordlists/dns.txt"
RESOLVERS="/etc/resolv.conf"
THREADS=50

log() {
    echo -e "[*] $1"
}

log "Starting subdomain enumeration for: $DOMAIN"

# Passive Enumeration
log "Running passive tools..."
amass enum -passive -d "$DOMAIN" -o "$OUTPUT_DIR/amass.txt"
subfinder -d "$DOMAIN" -o "$OUTPUT_DIR/subfinder.txt"
assetfinder --subs-only "$DOMAIN" > "$OUTPUT_DIR/assetfinder.txt"
sublist3r -d "$DOMAIN" -o "$OUTPUT_DIR/sublist3r.txt"
dnsrecon -d "$DOMAIN" -n 8.8.8.8 -j "$OUTPUT_DIR/dnsrecon.json"
theharvester -d "$DOMAIN" -b all -f "$OUTPUT_DIR/theharvester.xml"
sublert -d "$DOMAIN" > "$OUTPUT_DIR/sublert.txt"
shosubgo -d "$DOMAIN" -o "$OUTPUT_DIR/shosubgo.txt"
subdomainer -d "$DOMAIN" -o "$OUTPUT_DIR/subdomainer.txt"
subscraper -t "$DOMAIN" -o "$OUTPUT_DIR/subscraper.txt"
anubis -d "$DOMAIN" > "$OUTPUT_DIR/anubis.txt"
ct-exposer -d "$DOMAIN" -o "$OUTPUT_DIR/ct-exposer.txt"
ccrawldns "$DOMAIN" > "$OUTPUT_DIR/ccrawldns.txt"
dnssearch "$DOMAIN" > "$OUTPUT_DIR/dnssearch.txt"
domained -d "$DOMAIN" -o "$OUTPUT_DIR/domained.txt"
quickrecon -d "$DOMAIN" -o "$OUTPUT_DIR/quickrecon.txt"
lrod -d "$DOMAIN" -o "$OUTPUT_DIR/lrod.txt"
mildew -d "$DOMAIN" -o "$OUTPUT_DIR/mildew.txt"
netscout -d "$DOMAIN" -o "$OUTPUT_DIR/netscout.txt"
dns2geoip -d "$DOMAIN" > "$OUTPUT_DIR/dns2geoip.txt"
dnscobra -d "$DOMAIN" -o "$OUTPUT_DIR/dnscobra.txt"
bluto -d "$DOMAIN" -o "$OUTPUT_DIR/bluto.txt"
dripper -d "$DOMAIN" -o "$OUTPUT_DIR/dripper.txt"
graphinder -d "$DOMAIN" -o "$OUTPUT_DIR/graphinder.txt"
knock -d "$DOMAIN" -o "$OUTPUT_DIR/knock.txt"

# Permutation and Brute-force Enumeration
log "Running permutation and brute-force tools..."
altdns -i "$OUTPUT_DIR/amass.txt" -o "$OUTPUT_DIR/altdns_output.txt" -w "$WORDLIST" -r -s "$OUTPUT_DIR/altdns_resolved.txt"
puredns bruteforce "$WORDLIST" "$DOMAIN" --resolvers "$RESOLVERS" --write "$OUTPUT_DIR/puredns.txt"
dnscan -d "$DOMAIN" -w "$WORDLIST" -o "$OUTPUT_DIR/dnscan.txt"
dnsspider -d "$DOMAIN" -w "$WORDLIST" -o "$OUTPUT_DIR/dnsspider.txt"
syborg "$DOMAIN" -o "$OUTPUT_DIR/syborg.txt"
waldo -d "$DOMAIN" -w "$WORDLIST" -t "$THREADS" -o "$OUTPUT_DIR/waldo.txt"

# Aggregate and Deduplicate
log "Aggregating and deduplicating results..."
cat "$OUTPUT_DIR"/*.txt | sort -u > "$OUTPUT_DIR/all_subs.txt"

# Resolve Live Subdomains
log "Resolving livse subdomains..."
httpx -l "$OUTPUT_DIR/all_subs.txt" -threads "$THREADS" -o "$OUTPUT_DIR/live_subs.txt"

# Subdomain Takeover Checks
log "Checking for subdomain takeover opportunities..."
subjack -w "$OUTPUT_DIR/live_subs.txt" -t "$THREADS" -timeout 30 -ssl -v -o "$OUTPUT_DIR/subjack.txt"
subover -l "$OUTPUT_DIR/live_subs.txt" -o "$OUTPUT_DIR/subover.txt"
second-order -d "$DOMAIN" -l "$OUTPUT_DIR/live_subs.txt" -o "$OUTPUT_DIR/second_order.txt"

# Screenshotting Live Subdomains
log "Capturing screenshots of live subdomains..."
gowitness file -f "$OUTPUT_DIR/live_subs.txt" -P "$OUTPUT_DIR/screenshots" --threads "$THREADS"

log "[+] Enumeration complete. Live subdomains saved to: $OUTPUT_DIR/live_subs.txt"
log "[+] Subdomain takeover results saved to: $OUTPUT_DIR/subjack.txt, $OUTPUT_DIR/subover.txt, $OUTPUT_DIR/second_order.txt"
log "[+] Screenshots saved to: $OUTPUT_DIR/screenshots"
