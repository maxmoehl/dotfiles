#!/usr/bin/env bash
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>
# <swiftbar.schedule>* * * * *</swiftbar.schedule>

set -euo pipefail

url=$(jq -r '.url' ~/.config/litellm.json)
token=$(jq -r '.key' ~/.config/litellm.json)

if ! response=$(curl -fsS -H "Authorization: Bearer $token" "$url/user/info" 2>/dev/null); then
  echo "n/a"
else
  spend=$(echo "$response" | jq '.user_info.spend // -1')
  budget=$(echo "$response" | jq '.user_info.max_budget // -1')

  printf '$ %.2f (%.1f%%)\n' "$spend" $(echo "scale=4; ($spend / $budget) * 100" | bc)
fi
