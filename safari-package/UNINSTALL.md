# 🧹 Uninstall 7TV for Safari

[← Back to the package overview](README.md)

![Cleanup: Recoverable](https://img.shields.io/badge/cleanup-recoverable-22c55e)
![Xcode: Not required](https://img.shields.io/badge/Xcode-not_required-64748b)

The included uninstaller finds local **7TV for Safari** builds, unregisters
their Safari extensions, and moves the files to a timestamped folder in the
Trash.

> [!IMPORTANT]
> The cleanup is recoverable. Matching files are **moved to the Trash**, not
> permanently erased. The source repository and downloaded ZIP are left alone.

> [!WARNING]
> Safari closes during cleanup so it cannot keep an extension copy loaded.

## 📦 From the downloaded ZIP

1. Extract `7TV-for-Safari-Xcode.zip` if necessary.
2. Open Terminal.
3. Type `cd ` with a trailing space and drag the extracted
   `7TV-for-Safari-Xcode` folder into Terminal.
4. Press Return, then run:

```sh
./uninstall-all.command
```

## 🌿 From the source repository

Open Terminal in the repository root and run:

```sh
./safari-package/uninstall-all.command
```

Xcode and developer tools are not required for uninstallation.

## 🔍 What gets removed

| Item                               | Action                                |
| ---------------------------------- | ------------------------------------- |
| Installed app copies               | Moved to the recoverable Trash folder |
| Safari Web Extension registrations | Unregistered with macOS               |
| Matching Xcode build products      | Moved to the recoverable Trash folder |
| Matching temporary build copies    | Moved to the recoverable Trash folder |
| Repository and downloaded ZIP      | **Kept**                              |
| Unrelated Safari extensions        | **Kept**                              |

The script verifies each candidate using its 7TV manifest before moving it.
Similarly named apps that cannot be verified are skipped.

## ✅ Expected result

A complete cleanup ends with:

```text
PASS: no 7TV for Safari app or Safari extension registration remains.
```

Recoverable files are stored in:

```text
~/.Trash/7TV-for-Safari-uninstalled-YYYYMMDD-HHMMSS
```

## ♻️ Restore or finish cleanup

-   To restore something, open the timestamped folder in the Trash and move the
    desired app back manually.
-   To remove it permanently, empty the Trash yourself after reviewing the
    contents.
-   Reopen Safari after the command finishes.

> [!NOTE]
> Safari can briefly display a cached entry after its files and registration
> are gone. If an old 7TV row remains under **Safari > Settings > Extensions**,
> restart macOS once to clear that cached UI state.
