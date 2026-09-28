# 7TV for Safari

This project packages the official 7TV extension as a Safari Web Extension.
The Safari build keeps the upstream site implementations and statically
supports the same three sites:

-   site access: Twitch, Kick and YouTube
-   extension permission: local extension storage
-   no Chrome extension-management permission
-   no runtime registration; all three content-script matches are declared once
-   no automatic download of build tools

## Installing a public release

End users should receive a signed and notarized disk image. Installation is a
normal macOS flow:

1. Open the downloaded `7TV for Safari.dmg`.
2. Drag `7TV for Safari.app` to Applications.
3. Open the app once.
4. Enable 7TV in Safari Settings > Extensions.
5. Allow access to Twitch, Kick and YouTube when Safari asks.

No terminal, Xcode, Homebrew, Node.js, or build command is required. A public
release is not available until the publisher signs and notarizes it with an
Apple Developer ID. An unsigned or locally signed build is not an acceptable
substitute for general distribution because Gatekeeper will reject or warn
about it.

## Maintainer build

The wrapper app and extension use the App Sandbox and hardened runtime. The
wrapper has no file-selection or outgoing-network entitlement. Extension pages
use a restrictive content security policy.

Build the locally signed macOS application with:

```sh
./script/build-safari-local.sh
```

The script checks the reviewed lockfile, compiles the Safari variant, signs it
with an existing Apple Development identity, verifies the nested signature, and
checks the final permissions. It does not install or replace the application
automatically, and it does not register its temporary Xcode build with Launch
Services.

The result is a locally signed development build for maintainers. Creating the
user-facing disk image additionally requires a Developer ID Application
certificate, Apple notarization, release ownership, and an update policy. Local
development signing does not require publishing through the Mac App Store, but
it cannot produce a generally distributable release.
