# Installation with commands

First install [Xcode](https://apps.apple.com/app/xcode/id497799835), open it
once, and add your Apple Account in **Xcode > Settings > Accounts**. Create an
**Apple Development** certificate under **Manage Certificates** if necessary.

## From the downloaded ZIP

Open Terminal, type `cd ` with a trailing space, drag the extracted
`7TV-for-Safari-Xcode` folder into Terminal, press Return, then run:

```sh
./install.command
./verify.command
```

## From the source repository

Open Terminal in the repository root, then run:

```sh
cd safari-package
./install.command
./verify.command
```

The installer detects both layouts automatically. The repository path uses the
Xcode project in `safari-project`; it does not require moving or copying it into
`safari-package`.

The installer builds with the first local Apple Development identity, keeps a
timestamped non-runnable backup under
`~/Library/Application Support/7TV for Safari/Backups`, installs the app in
`~/Applications`, verifies its signature, and opens it. It never uploads or
exports the certificate.

Press **Open Safari Settings…** in the installed app. Safari must open directly
at **Settings > Extensions**. Enable **7TV for Safari (Unofficial)** and allow
Twitch and Kick. If macOS asks whether the app may control Safari, choose
**Allow**; this permission is used only to open that panel. Confirm emotes on
both sites, reload both pages, then quit and reopen Safari once.

If the installer says that no Apple Development identity exists, return to
Xcode > Settings > Accounts > Manage Certificates, create one, and rerun the
same two commands.
