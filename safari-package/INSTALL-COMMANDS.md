# Installation with commands

First install [Xcode](https://apps.apple.com/app/xcode/id497799835), open it
once, and add your Apple Account in **Xcode > Settings > Accounts**. Create an
**Apple Development** certificate under **Manage Certificates** if necessary.

Open Terminal, type `cd ` with a trailing space, drag the extracted
`7TV-for-Safari-Xcode` folder into Terminal, press Return, then run:

```sh
./install.command
./verify.command
```

The installer builds with the first local Apple Development identity, keeps a
timestamped backup of an existing installation, installs the app in
`~/Applications`, verifies its signature, and opens it. It never uploads or
exports the certificate.

Finally enable **7TV for Safari (Unofficial)** in **Safari > Settings >
Extensions** and allow Twitch and Kick. Confirm emotes on both sites, reload
both pages, then quit and reopen Safari once.

If the installer says that no Apple Development identity exists, return to
Xcode > Settings > Accounts > Manage Certificates, create one, and rerun the
same two commands.
