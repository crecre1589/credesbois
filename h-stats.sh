#!/usr/bin/env bash
# credesbois - HiveOS stats (inclus par l agent) : definit $khs et $stats.
_nm_f=/run/hive/credesbois.json
[[ -f $_nm_f ]] || _nm_f=/var/log/miner/credesbois/credesbois.json
khs=0
stats=
if [[ -f $_nm_f ]] && (( $(date +%s) - $(stat -c %Y "$_nm_f") < 60 )); then
  _nm_j=$(< "$_nm_f")
  khs=$(jq -r '.khs // 0' <<< "$_nm_j")
  # temperatures et ventilateurs depuis les stats GPU de HiveOS, dans l ordre des bus du mineur
  _nm_gs=/run/hive/gpu-stats.json
  _nm_temp='[]'; _nm_fan='[]'
  if [[ -f $_nm_gs ]]; then
    _nm_temp=$(jq -c --slurpfile g "$_nm_gs" '
      def hex2: ("0123456789abcdef" | split("")) as $d | (. / 16 | floor) as $h | (. % 16) as $l | $d[$h] + $d[$l];
      [.bus_numbers[] as $b | ($g[0].busids | map(split(":")[0] | ascii_downcase) | index($b | hex2)) as $i | if $i == null then 0 else ($g[0].temp[$i] | tonumber) end]' <<< "$_nm_j" 2>/dev/null)
    _nm_fan=$(jq -c --slurpfile g "$_nm_gs" '
      def hex2: ("0123456789abcdef" | split("")) as $d | (. / 16 | floor) as $h | (. % 16) as $l | $d[$h] + $d[$l];
      [.bus_numbers[] as $b | ($g[0].busids | map(split(":")[0] | ascii_downcase) | index($b | hex2)) as $i | if $i == null then 0 else ($g[0].fan[$i] | tonumber) end]' <<< "$_nm_j" 2>/dev/null)
  fi
  [[ -z $_nm_temp ]] && _nm_temp='[]'
  [[ -z $_nm_fan ]] && _nm_fan='[]'
  stats=$(jq -c --argjson t "$_nm_temp" --argjson f "$_nm_fan" '{hs, hs_units, temp: $t, fan: $f, uptime, ver, ar: .ar[0:2], algo, bus_numbers}' <<< "$_nm_j")
fi
