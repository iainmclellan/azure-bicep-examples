#!/usr/bin/env bash
set -euo pipefail
EXAMPLE="${1:?Usage: scripts/deploy.sh 01-storage resource-group [what-if|deploy]}"
RG="${2:?Resource group required}"
MODE="${3:-what-if}"
FILE="examples/$EXAMPLE/dev.bicepparam"
[[ -f "$FILE" ]] || { echo "Missing $FILE"; exit 1; }
case "$MODE" in
 what-if) az deployment group what-if --resource-group "$RG" --parameters "$FILE" ;;
 deploy) az deployment group create --resource-group "$RG" --parameters "$FILE" ;;
 *) echo 'Mode must be what-if or deploy'; exit 2 ;;
esac
