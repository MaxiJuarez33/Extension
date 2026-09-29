# Instructions for AI assistants

Your task is to install and verify the unofficial 7TV Safari package on the
user's Mac. Work only inside this extracted package and `~/Applications/7TV for
Safari.app`. Do not modify unrelated browser, system, or upstream 7TV code.

## Non-negotiable safety rules

- Never request, read, store, transmit, or print the user's Apple Account
  password, two-factor code, private keys, or exported certificates.
- Never disable Gatekeeper, SIP, quarantine protection, or Safari security.
- Never upload files, create a GitHub release, push a branch, or open a PR.
- Do not install Homebrew, Node.js, Yarn, Git, or Command Line Tools. This
  package already contains compiled extension resources and requires the full
  Xcode app.
- If Xcode needs account login, license acceptance, or user confirmation, open
  the relevant Xcode screen and let the user complete it privately.

## Installation

1. Confirm `/Applications/Xcode.app` exists. If missing, direct the user to
   https://apps.apple.com/app/xcode/id497799835 and wait for installation.
2. Confirm Xcode has completed first launch:
   `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -version`.
3. Confirm an Apple Development signing identity exists:
   `security find-identity -v -p codesigning`.
4. Run `./install.command` from this package. Do not rewrite the script to
   bypass a failed prerequisite.
5. Run `./verify.command`.
6. Have the user enable **7TV for Safari (Unofficial)** in Safari Settings >
   Extensions and grant access to Twitch and Kick. With explicit UI-control
   authorization, an assistant may navigate there, but must not change
   unrelated extensions or settings.

## Required verification

- `codesign --verify --deep --strict ~/Applications/7TV\ for\ Safari.app`
- Read the extension's effective `CFBundleIdentifier`, then confirm `pluginkit`
  lists that exact identifier.
- Confirm the packaged manifest grants only `storage` and the Twitch, Kick, and
  YouTube host patterns; it must not contain `management`, `scripting`,
  `activeTab`, optional permissions, or duplicate dynamic registrations.
- Open Twitch and Kick, verify 7TV emotes, reload both pages, then quit and
  reopen Safari and verify again.
- Inspect Safari's extension errors only for this extension. The known Safari
  regressions that must not reappear are duplicate content-script ID,
  unsupported `management` permission, and messages sent to a missing tab.
- Do not fix unrelated Twitch, Kick, YouTube, Safari, dependency, or upstream
  7TV problems. Report them separately as out of scope.

## Failure handling

- `xcodebuild requires Xcode`: Xcode is missing or the active developer path is
  Command Line Tools. The included script sets `DEVELOPER_DIR`; do not change
  the global developer directory.
- No Apple Development identity: open Xcode > Settings > Accounts, let the user
  sign in, then use Manage Certificates > + > Apple Development.
- Bundle identifier unavailable: ask the user before changing identifiers, then
  change the app and extension identifiers together while preserving the
  `.Extension` suffix.
- Signature or manifest verification failure: stop. Do not install the app and
  report the exact failing check.
