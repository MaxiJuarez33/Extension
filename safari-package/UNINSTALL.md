# Uninstall 7TV for Safari

The uninstaller removes every detected local build of **7TV for Safari** and
its Safari extension registrations. It closes Safari and moves matching files
to a timestamped folder in the Trash; it does not permanently delete them.

Xcode and developer tools are not required for uninstallation.

## From the downloaded ZIP

Extract `7TV-for-Safari-Xcode.zip`. Open Terminal, type `cd ` with a trailing
space, drag the extracted `7TV-for-Safari-Xcode` folder into Terminal, and press
Return. Then run:

```sh
./uninstall-all.command
```

## From the source repository

Open Terminal in the repository root and run:

```sh
./safari-package/uninstall-all.command
```

## Expected result

A successful cleanup ends with:

```text
PASS: no 7TV for Safari app or Safari extension registration remains.
```

Removed files are recoverable from a folder named
`7TV-for-Safari-uninstalled-YYYYMMDD-HHMMSS` in the Trash. The source
repository and downloaded ZIP are not removed.

Reopen Safari after the command finishes. If Safari still displays cached 7TV
entries in **Safari > Settings > Extensions**, restart macOS once.
