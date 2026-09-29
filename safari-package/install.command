#!/bin/zsh

set -euo pipefail

package_dir="${0:A:h}"
packaged_project_path="$package_dir/7TV for Safari/7TV for Safari.xcodeproj"
repository_project_path="$package_dir/../safari-project/7TV for Safari/7TV for Safari.xcodeproj"
xcode_developer_dir="/Applications/Xcode.app/Contents/Developer"
install_dir="$HOME/Applications"
install_path="$install_dir/7TV for Safari.app"
build_dir=$(mktemp -d "${TMPDIR%/}/seven-tv-safari-install.XXXXXX")
built_app="$build_dir/Build/Products/Release/7TV for Safari.app"

cleanup() {
	if [[ "$build_dir" == "${TMPDIR%/}/seven-tv-safari-install."* && -d "$build_dir" ]]; then
		/bin/rm -rf -- "$build_dir"
	fi
}
trap cleanup EXIT

if [[ ! -d "/Applications/Xcode.app" || ! -x "$xcode_developer_dir/usr/bin/xcodebuild" ]]; then
	print -u2 -- "Full Xcode is required. Install it from https://apps.apple.com/app/xcode/id497799835"
	exit 1
fi

if [[ -d "$packaged_project_path" ]]; then
	project_path="$packaged_project_path"
	project_layout="downloaded package"
elif [[ -d "$repository_project_path" ]]; then
	project_path="${repository_project_path:A}"
	project_layout="source repository"
else
	print -u2 -- "The 7TV for Safari Xcode project was not found."
	print -u2 -- "Run this command from the extracted ZIP root or from safari-package inside the source repository."
	exit 1
fi

DEVELOPER_DIR="$xcode_developer_dir" xcodebuild -version >/dev/null

identity_line=$(security find-identity -v -p codesigning | awk '/Apple Development/ {print; exit}')
signing_identity=$(print -r -- "$identity_line" | awk '{print $2}')
team_id=$(print -r -- "$identity_line" | sed -E 's/.*\(([A-Z0-9]+)\)".*/\1/')

if [[ -z "$signing_identity" || -z "$team_id" || "$team_id" == "$identity_line" ]]; then
	print -u2 -- "No Apple Development identity was found."
	print -u2 -- "Open Xcode > Settings > Accounts, add your Apple Account, then use Manage Certificates > + > Apple Development."
	exit 1
fi

print -r -- "Using project from: $project_layout"
print -r -- "Building 7TV for Safari with your local development identity..."
DEVELOPER_DIR="$xcode_developer_dir" \
	xcodebuild \
	-project "$project_path" \
	-scheme "7TV for Safari" \
	-configuration Release \
	-derivedDataPath "$build_dir" \
	DEVELOPMENT_TEAM="$team_id" \
	CODE_SIGN_STYLE=Manual \
	CODE_SIGN_IDENTITY="$signing_identity" \
	PROVISIONING_PROFILE_SPECIFIER= \
	CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
	REGISTER_WITH_LAUNCH_SERVICES=NO \
	build

codesign --verify --deep --strict "$built_app"
"$package_dir/verify.command" "$built_app" --skip-registration

/bin/mkdir -p "$install_dir"
if [[ -d "$install_path" ]]; then
	backup_path="$install_dir/7TV for Safari.backup-$(date +%Y%m%d-%H%M%S).app"
	/bin/mv "$install_path" "$backup_path"
	print -r -- "Previous installation moved to: $backup_path"
fi

/usr/bin/ditto "$built_app" "$install_path"
codesign --verify --deep --strict "$install_path"
/usr/bin/open "$install_path"
"$package_dir/verify.command" "$install_path"

print -r -- "Installed: $install_path"
print -r -- "Next: Safari > Settings > Extensions > enable 7TV for Safari (Unofficial) and allow Twitch and Kick."
