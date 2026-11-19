#!/usr/bin/env bash
# credesbois - HiveOS : construit la config depuis la feuille de vol.
# Variables HiveOS : $CUSTOM_TEMPLATE (adresse[.worker]), $CUSTOM_URL (pool), $CUSTOM_USER_CONFIG (arguments), $WORKER_NAME.
_nm_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_nm_conf="${CUSTOM_CONFIG_FILENAME:-$_nm_here/credesbois.conf}"
case "$_nm_conf" in /*) ;; *) _nm_conf="$_nm_here/$_nm_conf";; esac
# Pool URL : 1re URL = principale ; une 2e URL (champ Pool URL HiveOS, separee par espace/retour ligne) = secours.
# Le prefixe stratum+tcp:// est garde : credesbois en deduit le protocole (suprnova/7801-7805/stratum = stratum, sinon Aria).
read -r -a _nm_urls <<< "$(tr ',;\n\r\t' '     ' <<< "$CUSTOM_URL")"
_nm_pool="${_nm_urls[0]%/}"
[[ -z $_nm_pool ]] && _nm_pool="neb.ariabrain.com:3370"
_nm_backup="${_nm_urls[1]%/}"
# secours dans "Extra config arguments" : --backup HOTE:PORT (ou --backup=HOTE:PORT), prioritaire sur la 2e URL
_nm_extra=""
read -r -a _nm_args <<< "$CUSTOM_USER_CONFIG"
for ((_i = 0; _i < ${#_nm_args[@]}; _i++)); do
  case "${_nm_args[_i]}" in
    --backup|--pool2) _nm_backup="${_nm_args[_i + 1]}"; _i=$((_i + 1));;
    --backup=*|--pool2=*) _nm_backup="${_nm_args[_i]#*=}";;
    *) _nm_extra+="${_nm_extra:+ }${_nm_args[_i]}";;
  esac
done
_nm_tpl="${CUSTOM_TEMPLATE:-$CUSTOM_WALLET}"; _nm_wallet="${_nm_tpl%%.*}"
_nm_worker="${WORKER_NAME:-rig}"
[[ $_nm_tpl == *.* ]] && _nm_worker="${_nm_tpl#*.}"
[[ $_nm_worker == *%* ]] && _nm_worker="${WORKER_NAME:-rig}"
{
  echo "WALLET=\"$_nm_wallet\""
  echo "POOL=\"$_nm_pool\""
  echo "WORKER=\"$_nm_worker\""
  echo "BACKUP=\"$_nm_backup\""
  echo "EXTRA=\"$_nm_extra\""
} > "$_nm_conf"
echo "credesbois/h-config: conf=$_nm_conf adresse=${_nm_wallet:-VIDE} pool=$_nm_pool secours=${_nm_backup:-aucun} worker=$_nm_worker"
