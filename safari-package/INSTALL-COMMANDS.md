# ⌨️ Installation with commands

[← Back to the package overview](README.md) · [Use the visual guide instead →](INSTALL-MANUAL.md)

![Requires: Xcode](https://img.shields.io/badge/requires-Xcode-0a84ff?logo=xcode)
![Platform: macOS 12+](https://img.shields.io/badge/macOS-12%2B-0a84ff?logo=apple)
![Updated: 2026-09-29](https://img.shields.io/badge/updated-2026--09--29-64748b)

This is the shortest repeatable setup. The included scripts build, install, and
verify the Safari app without modifying the source package.

> [!IMPORTANT]
> This is an **unofficial Safari build of the real 7TV Web Extension**. The
> installer does not download a substitute extension or send your certificate
> anywhere. It uses the included 7TV resources and signs them locally.

## ✅ One-time preparation

1. Install the full [Xcode app](https://apps.apple.com/app/xcode/id497799835).
2. Open Xcode once and accept Apple's license.
3. Add your Apple Account in **Xcode > Settings > Accounts**.
4. Under **Manage Certificates**, create an **Apple Development** certificate
   if none exists.

> [!WARNING]
> The standalone Command Line Tools package is not enough. The script requires
> the full Xcode app at `/Applications/Xcode.app`.

## 📦 From the downloaded ZIP

1. Extract `7TV-for-Safari-Xcode.zip`.
2. Open Terminal.
3. Type `cd ` —including the trailing space— and drag the extracted
   `7TV-for-Safari-Xcode` folder into Terminal.
4. Press Return, then run:

```sh
./install.command
./verify.command
```

## 🌿 From the source repository

Open Terminal in the repository root and run:

```sh
cd safari-package
./install.command
./verify.command
```

The installer detects the ZIP and repository layouts automatically.

## 🔍 What the installer does

| Step            | Action                                                                                                                            |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **1. Detect**   | Finds the packaged or repository Xcode project and the first local Apple Development identity.                                    |
| **2. Isolate**  | Copies the project to a temporary build directory; it does not rewrite your checkout or extracted ZIP.                            |
| **3. Build**    | Uses the full Xcode toolchain to compile and locally sign the containing app and extension.                                       |
| **4. Verify**   | Checks the signature, exact permissions, site access, unofficial names, and Safari Settings entitlement.                          |
| **5. Install**  | Places the app at `~/Applications/7TV for Safari.app`.                                                                            |
| **6. Preserve** | Moves a previous installation to a timestamped, non-runnable backup under `~/Library/Application Support/7TV for Safari/Backups`. |
| **7. Register** | Opens the app and confirms Safari registered the extension.                                                                       |

> [!NOTE]
> The script never uploads or exports your Apple certificate. It does not use
> `sudo`, install package managers, or download build tools.

## 🧩 Enable 7TV in Safari

1. In the installed app, press **Open Safari Settings…**.
2. The app closes and Safari opens **Settings > Extensions**.
3. Enable **7TV for Safari (Unofficial)**.
4. Allow website access to **Twitch** and **Kick**.
5. If macOS asks whether the app may control Safari, choose **Allow**. The
   permission is restricted to opening this Settings panel.

## 🔄 First launch: reload once

> [!TIP]
> If the extension icon is blue but the 7TV button or emotes do not appear on
> an already-open Twitch or Kick page, **reload that page once**.

![Reload Twitch when 7TV is enabled but has not appeared yet](screenshots/05-reload-twitch.png)

## ✅ Expected verification

The final command should report:

```text
PASS: signature, Safari registration, permissions, and site access are valid.
```

Then verify the browser behavior:

-   [ ] 7TV emotes render on Twitch.
-   [ ] 7TV emotes render on Kick.
-   [ ] Both sites still work after a page reload.
-   [ ] The extension returns after quitting and reopening Safari.

## 🤖 AI-assisted installation

Give the extracted folder or repository to your coding assistant and use this
prompt:

> Read `INSTALL-COMMANDS.md`, install 7TV for Safari, run every included
> verification, confirm the installed signature and Safari registration, and
> do not publish or upload anything.

The assistant may complete the build and verification, but macOS can still ask
you to approve an Apple Account, certificate, or Safari permission dialog.

## 🛠️ Troubleshooting

<details>
<summary><strong>No Apple Development identity was found</strong></summary>

Open **Xcode > Settings > Accounts > Manage Certificates**, create an **Apple
Development** certificate, and run the same two commands again.

</details>

<details>
<summary><strong>xcodebuild says Command Line Tools are active</strong></summary>

Install and open the full Xcode app. The included script explicitly uses
`/Applications/Xcode.app/Contents/Developer`; you do not need to change the
system-wide `xcode-select` setting.

</details>

<details>
<summary><strong>7TV is enabled but missing from Twitch or Kick</strong></summary>

Reload the page once and confirm Safari granted access to that website. If the
problem remains, quit and reopen Safari, then run `./verify.command` again.

</details>

## 🧹 Remove it later

Use the recoverable procedure in [UNINSTALL.md](UNINSTALL.md).
