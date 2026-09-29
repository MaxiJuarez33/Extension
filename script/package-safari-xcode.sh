#!/bin/zsh

set -euo pipefail

repo_dir="${0:A:h:h}"
output_dir="${1:-$repo_dir/safari-build}"
stage_dir=$(mktemp -d "${TMPDIR%/}/seven-tv-safari-package.XXXXXX")
package_dir="$stage_dir/7TV-for-Safari-Xcode"
archive_path="$output_dir/7TV-for-Safari-Xcode.zip"
checksum_path="$archive_path.sha256"

cleanup() {
	if [[ "$stage_dir" == "${TMPDIR%/}/seven-tv-safari-package."* && -d "$stage_dir" ]]; then
		/bin/rm -rf -- "$stage_dir"
	fi
}
trap cleanup EXIT

cd "$repo_dir"

if ! npx --no-install yarn@1.22.22 --version >/dev/null 2>&1; then
	print -u2 -- "Pinned Yarn 1.22.22 is not available locally. Refusing to download build tools implicitly."
	exit 1
fi

if [[ ! -x node_modules/.bin/vite || ! -x node_modules/.bin/vue-tsc ]]; then
	print -u2 -- "Dependencies are missing. Install the reviewed lockfile before packaging."
	exit 1
fi

npx --no-install yarn@1.22.22 check --integrity --ignore-scripts
npx --no-install yarn@1.22.22 build:safari

/bin/mkdir -p "$package_dir"
/usr/bin/ditto "$repo_dir/safari-project/7TV for Safari" "$package_dir/7TV for Safari"
/usr/bin/rsync -a --delete "$repo_dir/dist/" "$package_dir/7TV for Safari/7TV for Safari Extension/Resources/"
/usr/bin/plutil -replace name -string "7TV for Safari (Unofficial)" \
	"$package_dir/7TV for Safari/7TV for Safari Extension/Resources/manifest.json"
/usr/bin/plutil -replace description -string "Unofficial Safari build of the 7TV Web Extension." \
	"$package_dir/7TV for Safari/7TV for Safari Extension/Resources/manifest.json"
/usr/bin/sed -i '' \
	's/INFOPLIST_KEY_CFBundleDisplayName = "7TV for Safari";/INFOPLIST_KEY_CFBundleDisplayName = "7TV for Safari (Unofficial)";/' \
	"$package_dir/7TV for Safari/7TV for Safari.xcodeproj/project.pbxproj"
/usr/bin/sed -i '' \
	's/INFOPLIST_KEY_CFBundleDisplayName = "7TV for Safari Extension";/INFOPLIST_KEY_CFBundleDisplayName = "7TV for Safari (Unofficial)";/' \
	"$package_dir/7TV for Safari/7TV for Safari.xcodeproj/project.pbxproj"
/usr/bin/sed -i '' -E \
	'/^[[:space:]]*DEVELOPMENT_TEAM = [A-Z0-9]+;$/d' \
	"$package_dir/7TV for Safari/7TV for Safari.xcodeproj/project.pbxproj"
/usr/bin/ditto "$repo_dir/safari-package/README.md" "$package_dir/README.md"
/usr/bin/ditto "$repo_dir/safari-package/INSTALL-MANUAL.md" "$package_dir/INSTALL-MANUAL.md"
/usr/bin/ditto "$repo_dir/safari-package/INSTALL-COMMANDS.md" "$package_dir/INSTALL-COMMANDS.md"
/usr/bin/ditto "$repo_dir/safari-package/UNINSTALL.md" "$package_dir/UNINSTALL.md"
/usr/bin/ditto "$repo_dir/safari-package/install.command" "$package_dir/install.command"
/usr/bin/ditto "$repo_dir/safari-package/verify.command" "$package_dir/verify.command"
/usr/bin/ditto "$repo_dir/safari-package/uninstall-all.command" "$package_dir/uninstall-all.command"
/usr/bin/ditto "$repo_dir/safari-package/screenshots" "$package_dir/screenshots"
/usr/bin/ditto "$repo_dir/LICENSE.md" "$package_dir/LICENSE.md"
/bin/chmod +x "$package_dir/install.command" "$package_dir/verify.command" "$package_dir/uninstall-all.command"

/usr/bin/find "$package_dir" -name xcuserdata -type d -prune -exec /bin/rm -rf -- {} +

if rg -n -i "BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|api[_-]?key[[:space:]]*[:=]|password[[:space:]]*[:=]|juarezmaxi|gmail\.com|U67H3G7YT6|8240EB54" "$package_dir"; then
	print -u2 -- "Refusing to package possible credentials or personal signing data."
	exit 1
fi

/bin/mkdir -p "$output_dir"
/bin/rm -f -- "$archive_path" "$checksum_path"
(cd "$stage_dir" && COPYFILE_DISABLE=1 /usr/bin/ditto -c -k --norsrc --keepParent "7TV-for-Safari-Xcode" "$archive_path")
(cd "$output_dir" && /usr/bin/shasum -a 256 "${archive_path:t}" >"${checksum_path:t}")

print -r -- "$archive_path"
print -r -- "$checksum_path"
