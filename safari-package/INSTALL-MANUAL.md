# Manual installation

1. Install the free [Xcode app](https://apps.apple.com/app/xcode/id497799835).
   Command Line Tools alone are not sufficient.
2. Open Xcode once, accept its license, then open **Xcode > Settings >
   Accounts** and add your Apple Account.
3. Select your account, click **Manage Certificates**, press **+**, and create
   an **Apple Development** certificate if none exists.
4. Open `7TV for Safari/7TV for Safari.xcodeproj` from this package.
5. Select the blue **7TV for Safari** project. Under **Signing & Capabilities**,
   select your **Personal Team** for both targets: **7TV for Safari** and
   **7TV for Safari Extension**.
6. At the top of Xcode select the **7TV for Safari** scheme and **My Mac**, then
   press the Run button. Wait until the app opens.
7. Open **Safari > Settings > Extensions**, enable **7TV for Safari
   (Unofficial)**, and allow access to Twitch and Kick.

Verification: open Twitch and Kick, confirm that 7TV emotes appear, reload each
page, then quit and reopen Safari. If Xcode reports that a bundle identifier is
unavailable, change both identifiers under Signing & Capabilities to a unique
prefix such as `local.yourname.seventv.safari` and
`local.yourname.seventv.safari.Extension`.
