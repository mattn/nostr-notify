#!/bin/bash

relay=wss://yabu.me
base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

echo '' | nak req -stream -k 1 -s now ${relay} 2> /dev/null | while read -r LINE; do
  pubkey=$(echo "${LINE}" | jq -r '.pubkey')
  content=$(echo "${LINE}" | jq -r '.content')
  if [ ! -e "${base_dir}/profiles/${pubkey}.json" ]; then
    echo '' | nak req -k 0 -a "${pubkey}" -l 1 ${relay} > "${base_dir}/profiles/${pubkey}.json" 2> /dev/null
  fi
  if [ ! -e "${base_dir}/profiles/${pubkey}.png" ]; then
    curl -s -o "${base_dir}/profiles/${pubkey}.tmp" "$(cat "${base_dir}/profiles/${pubkey}.json" | jq -r '.content | fromjson | .picture')"
    gm convert "${base_dir}/profiles/${pubkey}.tmp" -resize 200x200 "${base_dir}/profiles/${pubkey}.png" > /dev/null 2>&1
    rm -f "${base_dir}/profiles/${pubkey}.tmp"
  fi
  display_name=$(cat "${base_dir}/profiles/${pubkey}.json" | jq -r '.content | fromjson | .display_name')
  notify-send -h string:x-canonical-private-synchronous:nostr -c im -h int:transient:1 -h "string:image-path:${base_dir}/profiles/${pubkey}.png" "${display_name}" "${content}"
done
