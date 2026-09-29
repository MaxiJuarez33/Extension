#!/bin/zsh

set -euo pipefail

package_dir="${0:A:h}"
timestamp=$(/bin/date +%Y%m%d-%H%M%S)
trash_dir="$HOME/.Trash/7TV-for-Safari-uninstalled-$timestamp"
typeset -A seen_apps
typeset -A seen_extensions
typeset -a search_roots
app_count=0
extension_count=0

search_roots=(/Applications "$HOME/Applications" "$HOME/Library/Developer/Xcode/DerivedData" /private/tmp "${TMPDIR%/}" "$package_dir:h")

print -r -- "Closing 7TV for Safari and Safari..."
/usr/bin/pkill -x "7TV for Safari" 2>/dev/null || true
/usr/bin/osascript -e 'tell application "Safari" to quit' >/dev/null 2>&1 || true

/bin/mkdir -p "$trash_dir"

is_7tv_extension() {
	local extension_path="$1"
	local manifest_path="$extension_path/Contents/Resources/manifest.json"
	local manifest_name

	[[ -f "$manifest_path" ]] || return 1
	manifest_name=$(/usr/bin/plutil -extract name raw -o - "$manifest_path" 2>/dev/null || true)
	[[ "$manifest_name" == 7TV* ]]
}

is_empty_xcode_7tv_product() {
	local app_path="$1"
	local canonical_path="${app_path:A}"
	local first_payload

	[[ "$canonical_path" == */Build/Products/*/7TV\ for\ Safari.app ]] || return 1
	first_payload=$(/usr/bin/find "$app_path" \( -type f -o -type l \) -print -quit 2>/dev/null || true)
	[[ -z "$first_payload" ]]
}

is_empty_xcode_7tv_extension_product() {
	local extension_path="$1"
	local canonical_path="${extension_path:A}"
	local first_payload

	[[ "$canonical_path" == */Build/Products/*/7TV\ for\ Safari\ Extension.appex ]] || return 1
	first_payload=$(/usr/bin/find "$extension_path" \( -type f -o -type l \) -print -quit 2>/dev/null || true)
	[[ -z "$first_payload" ]]
}

unregister_extension() {
	local extension_path="$1"
	[[ -n "$extension_path" ]] || return 0
	local canonical_path="${extension_path:A}"

	[[ -z "${seen_extensions[$canonical_path]-}" ]] || return 0
	seen_extensions[$canonical_path]=1
	/usr/bin/pluginkit -r "$extension_path" >/dev/null 2>&1 || true
	print -r -- "Unregistered: $extension_path"
}

find_apps() {
	/usr/bin/mdfind -0 "kMDItemFSName == '7TV for Safari.app'cd" 2>/dev/null || true
	/usr/bin/find "${search_roots[@]}" -xdev \
		\( -path "$HOME/.Trash" -o -path "$HOME/.Trash/*" \) -prune -o \
		-type d -name "7TV for Safari.app" -print0 2>/dev/null
}

find_extensions() {
	/usr/bin/mdfind -0 "kMDItemFSName == '7TV for Safari Extension.appex'cd" 2>/dev/null || true
	/usr/bin/find "${search_roots[@]}" -xdev \
		\( -path "$HOME/.Trash" -o -path "$HOME/.Trash/*" \) -prune -o \
		-type d -name "7TV for Safari Extension.appex" -print0 2>/dev/null
}

# Remove every live or stale 7TV registration, including entries whose app has
# already disappeared from disk.
while IFS= read -r extension_path; do
	[[ -n "$extension_path" ]] || continue
	unregister_extension "$extension_path"
done < <(/usr/bin/pluginkit -mAvvv -p com.apple.Safari.web-extension 2>/dev/null | \
	/usr/bin/sed -n 's/^[[:space:]]*Path = //p' | /usr/bin/grep -F '7TV for Safari' || true)

# Find every containing app reported by Spotlight or located in Applications,
# Xcode output, temporary directories, and the package's parent directory. The
# manifest check prevents similarly named apps from being touched.
while IFS= read -r -d '' app_path; do
	[[ -d "$app_path" ]] || continue
	canonical_path="${app_path:A}"
	[[ "$canonical_path" != "$HOME/.Trash/"* ]] || continue
	[[ -z "${seen_apps[$canonical_path]-}" ]] || continue
	seen_apps[$canonical_path]=1

	extension_path="$app_path/Contents/PlugIns/7TV for Safari Extension.appex"
	is_7tv_extension "$extension_path" || is_empty_xcode_7tv_product "$app_path" || {
		print -u2 -- "Skipped unverified app: $app_path"
		continue
	}

	[[ -d "$extension_path" ]] && unregister_extension "$extension_path"
	(( ++app_count ))
	destination="$trash_dir/app-$app_count-7TV for Safari.app"
	/bin/mv "$app_path" "$destination"
	print -r -- "Moved to Trash: $app_path"
done < <(find_apps)

# Xcode also leaves standalone copies of the extension beside the app product.
while IFS= read -r -d '' extension_path; do
	[[ -d "$extension_path" ]] || continue
	canonical_path="${extension_path:A}"
	[[ "$canonical_path" != "$HOME/.Trash/"* ]] || continue
	[[ -z "${seen_extensions[$canonical_path]-}" ]] || continue
	is_7tv_extension "$extension_path" || is_empty_xcode_7tv_extension_product "$extension_path" || continue

	unregister_extension "$extension_path"
	(( ++extension_count ))
	destination="$trash_dir/extension-$extension_count-7TV for Safari Extension.appex"
	/bin/mv "$extension_path" "$destination"
	print -r -- "Moved to Trash: $extension_path"
done < <(find_extensions)

remaining_apps=""
remaining_extensions=""
typeset -A remaining_seen
while IFS= read -r -d '' app_path; do
	canonical_path="${app_path:A}"
	[[ -d "$app_path" ]] || continue
	[[ "$canonical_path" != "$HOME/.Trash/"* ]] || continue
	[[ -z "${remaining_seen[$canonical_path]-}" ]] || continue
	remaining_seen[$canonical_path]=1
	remaining_apps+="$canonical_path"$'\n'
done < <(find_apps)
while IFS= read -r -d '' extension_path; do
	canonical_path="${extension_path:A}"
	[[ -d "$extension_path" ]] || continue
	[[ "$canonical_path" != "$HOME/.Trash/"* ]] || continue
	[[ -z "${remaining_seen[$canonical_path]-}" ]] || continue
	remaining_seen[$canonical_path]=1
	remaining_extensions+="$canonical_path"$'\n'
done < <(find_extensions)
remaining_registrations=$(/usr/bin/pluginkit -mAvvv -p com.apple.Safari.web-extension 2>/dev/null | \
	/usr/bin/grep -E 'app\.seventv|7TV for Safari' || true)

if [[ -n "$remaining_apps" || -n "$remaining_extensions" || -n "$remaining_registrations" ]]; then
	print -u2 -- "Cleanup was incomplete. Remaining applications, extensions, or registrations:"
	[[ -z "$remaining_apps" ]] || print -u2 -r -- "$remaining_apps"
	[[ -z "$remaining_extensions" ]] || print -u2 -r -- "$remaining_extensions"
	[[ -z "$remaining_registrations" ]] || print -u2 -r -- "$remaining_registrations"
	exit 1
fi

if (( app_count == 0 && extension_count == 0 )); then
	/bin/rmdir "$trash_dir" 2>/dev/null || true
	print -r -- "No 7TV for Safari installations were found."
else
	print -r -- "Removed $app_count app copy/copies and $extension_count standalone extension copy/copies."
	print -r -- "Recoverable files are in: $trash_dir"
fi

print -r -- "PASS: no 7TV for Safari app or Safari extension registration remains."
print -r -- "Reopen Safari. If its old list is still cached, restart macOS once."
