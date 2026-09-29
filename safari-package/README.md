# 7TV for Safari — unofficial installer

This package builds the existing 7TV extension locally and installs it as a
Safari Web Extension. It is an independent, unofficial build and is not a 7TV
release.

Requirements:

- macOS 12 or later
- [Xcode from the Mac App Store](https://apps.apple.com/app/xcode/id497799835)
- a free Apple Account added to Xcode

Choose exactly one installation guide:

- [Manual installation](INSTALL-MANUAL.md) — use only Xcode and Finder.
- [Command installation](INSTALL-COMMANDS.md) — works from the downloaded ZIP
  and from `safari-package` in the source repository.

The manual guide includes screenshots for signing, running, and confirming the
containing app before Safari is changed.

For AI-assisted installation, give the extracted folder to the assistant and
say: **“Read `AGENTS.md`, install this package, and run every required
verification.”** `CLAUDE.md` redirects Claude to the same instructions.

The package already contains the compiled 7TV web extension. Node.js, Yarn,
Homebrew, Git, and the Xcode Command Line Tools package are not required.

Keep the installed app in `~/Applications`. Removing it also removes the
extension from Safari. A free Personal Team may require rebuilding periodically;
run the same installation again if Safari stops accepting the development
signature.

To remove every local 7TV for Safari build and registration, follow
[UNINSTALL.md](UNINSTALL.md). The same uninstaller works from this downloaded
package and from the source repository.
