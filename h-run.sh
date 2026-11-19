#!/usr/bin/env bash
# credesbois - HiveOS : un seul processus pour tous les GPU.
cd "$(dirname "$0")" || exit 1
source h-manifest.conf
unset LD_LIBRARY_PATH   # le runtime CUDA est lie statiquement ; seul le pilote est utilise
LOGDIR="$(dirname "$CUSTOM_LOG_BASENAME")"
mkdir -p "$LOGDIR" 2>/dev/null
[[ -w $LOGDIR ]] || { LOGDIR="$(pwd)"; CUSTOM_LOG_BASENAME="$LOGDIR/credesbois"; }
LOG="${CUSTOM_LOG_BASENAME}.log"
for c in "$CUSTOM_CONFIG_FILENAME" "$(pwd)/credesbois.conf"; do
  [[ -n $c && -f $c ]] && { source "$c"; CONF_READ="$c"; break; }
done
if [[ -z $WALLET || $WALLET == *%* || $WALLET != neb1* ]]; then
  echo "credesbois : pas d adresse NEB valide (config ${CONF_READ:-introuvable}). Mettre l adresse neb1... dans la feuille de vol." | tee -a "$LOG"
  sleep 15; exit 1
fi
STATS=/run/hive/credesbois.json
[[ -d /run/hive ]] || STATS="$LOGDIR/credesbois.json"
# relance automatique si le processus se termine (sans boucle folle)
while true; do
  BK=(); [[ -n $BACKUP ]] && BK=(--backup "$BACKUP")
  echo "credesbois/h-run : adresse $WALLET, pool $POOL, secours ${BACKUP:-aucun}, worker $WORKER, extra '$EXTRA'" | tee -a "$LOG"
  ./credesbois -u "$WALLET" -o "$POOL" "${BK[@]}" -w "$WORKER" --stats "$STATS" $EXTRA 2>&1 | tee -a "$LOG"
  RC=${PIPESTATUS[0]}
  if [[ $RC == 3 ]]; then
    echo "credesbois/h-run : verification d integrite echouee (binaire modifie ou corrompu) : reinstallez le paquet officiel. Nouvel essai dans 5 min" | tee -a "$LOG"
    sleep 300
  else
    echo "credesbois/h-run : le mineur s est arrete (code $RC), relance dans 10 s" | tee -a "$LOG"
    sleep 10
  fi
done
