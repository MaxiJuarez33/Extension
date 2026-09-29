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

   ![Select a Personal Team for both targets](screenshots/02-signing.png)

6. At the top of Xcode select the **7TV for Safari** scheme and **My Mac**, then
   press the Run button.

   ![Select the app scheme, My Mac, and Run](screenshots/03-run.png)

   Wait for the app below. It must show the 7TV icon, an extension status, and
   **Open Safari Settings…**. A blank window means the build is not correct.

   ![Expected 7TV for Safari app](screenshots/04-ready.png)

7. Press **Open Safari Settings…**. Safari must open directly at
   **Settings > Extensions**. Enable **7TV for Safari (Unofficial)** and allow
   access to Twitch and Kick. If macOS asks whether the app may control Safari,
   choose **Allow**; this permission is used only to open that Safari panel.

First use: if Safari shows the extension as enabled (the extension icon is
blue) but the 7TV icon or emotes do not appear on an already-open Twitch or Kick
page, reload that page once. Safari only injects a newly enabled extension into
the page after a reload.

![Reload Twitch when 7TV is enabled but has not appeared yet](screenshots/05-reload-twitch.png)

Verification: open Twitch and Kick, confirm that 7TV emotes appear, reload each
page, then quit and reopen Safari. If Xcode reports that a bundle identifier is
unavailable, change both identifiers under Signing & Capabilities to a unique
prefix such as `local.yourname.seventv.safari` and
`local.yourname.seventv.safari.Extension`.

The team name in the screenshots is intentionally generic. Your own Personal
Team name will be different.
