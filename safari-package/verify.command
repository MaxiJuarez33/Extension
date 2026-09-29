#!/bin/zsh

set -euo pipefail

app_path="${1:-$HOME/Applications/7TV for Safari.app}"
registration_mode="${2:-}"
extension_path="$app_path/Contents/PlugIns/7TV for Safari Extension.appex"
manifest_path="$extension_path/Contents/Resources/manifest.json"
app_info_path="$app_path/Contents/Info.plist"
extension_info_path="$extension_path/Contents/Info.plist"
entitlements_path=$(mktemp "${TMPDIR%/}/seven-tv-safari-entitlements.XXXXXX")

cleanup() {
	/bin/rm -f -- "$entitlements_path"
}
trap cleanup EXIT

if [[ ! -d "$app_path" ]]; then
	print -u2 -- "Installation not found at: $app_path"
	exit 1
fi

codesign --verify --deep --strict --verbose=2 "$app_path"
codesign -d --entitlements :- "$app_path" 2>/dev/null > "$entitlements_path"

if [[ ! -f "$manifest_path" ]]; then
	print -u2 -- "The Safari extension manifest is missing."
	exit 1
fi

permissions=$(/usr/bin/plutil -extract permissions json -o - "$manifest_path" | tr -d '[:space:]')
hosts=$(/usr/bin/plutil -extract host_permissions json -o - "$manifest_path" | tr -d '[:space:]' | /usr/bin/sed 's#\\/#/#g')
manifest_name=$(/usr/bin/plutil -extract name raw -o - "$manifest_path")
manifest_description=$(/usr/bin/plutil -extract description raw -o - "$manifest_path")
app_name=$(/usr/bin/plutil -extract CFBundleDisplayName raw -o - "$app_info_path")
extension_name=$(/usr/bin/plutil -extract CFBundleDisplayName raw -o - "$extension_info_path")
usage_description=$(/usr/bin/plutil -extract NSAppleEventsUsageDescription raw -o - "$app_info_path")
automation_entitlement=$(/usr/libexec/PlistBuddy -c 'Print :com.apple.security.automation.apple-events' "$entitlements_path")
safari_scripting_target=$(/usr/libexec/PlistBuddy -c 'Print :com.apple.security.scripting-targets:com.apple.Safari:0' "$entitlements_path")

[[ "$permissions" == '["storage"]' ]] || { print -u2 -- "Unexpected extension permissions: $permissions"; exit 1; }
[[ "$hosts" == '["*://*.twitch.tv/*","*://*.kick.com/*","*://*.youtube.com/*"]' ]] || {
	print -u2 -- "Unexpected site access: $hosts"
	exit 1
}
[[ "$app_name" == '7TV for Safari (Unofficial)' ]] || { print -u2 -- "Unexpected app name: $app_name"; exit 1; }
[[ "$extension_name" == '7TV for Safari (Unofficial)' ]] || { print -u2 -- "Unexpected extension name: $extension_name"; exit 1; }
[[ "$manifest_name" == '7TV for Safari (Unofficial)' ]] || { print -u2 -- "Unexpected manifest name: $manifest_name"; exit 1; }
[[ "$manifest_description" == 'Unofficial Safari build of the 7TV Web Extension.' ]] || {
	print -u2 -- "Unexpected manifest description: $manifest_description"
	exit 1
}
[[ -n "$usage_description" ]] || { print -u2 -- "The Apple Events usage description is missing."; exit 1; }
[[ "$automation_entitlement" == true ]] || { print -u2 -- "The Apple Events entitlement is missing."; exit 1; }
[[ "$safari_scripting_target" == 'com.apple.Safari.show-extensions-preferences' ]] || {
	print -u2 -- "Unexpected Safari scripting entitlement: $safari_scripting_target"
	exit 1
}

for forbidden_key in optional_permissions optional_host_permissions; do
	if /usr/bin/plutil -extract "$forbidden_key" json -o - "$manifest_path" >/dev/null 2>&1; then
		print -u2 -- "Forbidden manifest key found: $forbidden_key"
		exit 1
	fi
done

extension_id=$(/usr/bin/plutil -extract CFBundleIdentifier raw -o - "$extension_path/Contents/Info.plist")
if [[ "$registration_mode" == "--skip-registration" ]]; then
	print -r -- "PASS: signature, permissions, and site access are valid."
	exit 0
fi

registered=false
for attempt in {1..10}; do
	if /usr/bin/pluginkit -mAvvv -p com.apple.Safari.web-extension 2>/dev/null | grep -Fq "$extension_id"; then
		registered=true
		break
	fi
	/bin/sleep 1
done

if [[ "$registered" != true ]]; then
	print -u2 -- "The signature and manifest are valid, but Safari has not registered the extension yet."
	print -u2 -- "Open the app once, then rerun this verification."
	exit 1
fi

print -r -- "PASS: signature, Safari registration, permissions, and site access are valid."
print -r -- "Manual check remaining: enable 7TV in Safari and verify Twitch and Kick before and after a Safari restart."
