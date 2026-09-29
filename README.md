<p align="center">
  <a href="https://7tv.app">
    <picture>
      <img src="public/icon/icon-128.png" height="128">
    </picture>
    <h1 align="center">7TV Web Extension</h1>
  </a>
</p>

<p align="center">
  <a aria-label="Chrome web store stable" href="https://chrome.google.com/webstore/detail/7tv/ammjkodgmmoknidbanneddgankgfejfh">
    <img src="https://img.shields.io/chrome-web-store/v/ammjkodgmmoknidbanneddgankgfejfh?label=Chrome%20Web%20Store%20Stable&style=for-the-badge">
  </a>
  <a aria-label="Rating" href="https://chrome.google.com/webstore/detail/7tv/ammjkodgmmoknidbanneddgankgfejfh/reviews">
    <img src="https://img.shields.io/chrome-web-store/rating/ammjkodgmmoknidbanneddgankgfejfh?style=for-the-badge">
  </a>
  <a aria-label="Users" href="https://chrome.google.com/webstore/detail/7tv/ammjkodgmmoknidbanneddgankgfejfh">
    <img src="https://img.shields.io/chrome-web-store/users/ammjkodgmmoknidbanneddgankgfejfh?style=for-the-badge">
  </a>
</p>

<p align="center">
  <a aria-label="Chrome web store nightly" href="https://chrome.google.com/webstore/detail/7tv/fphegifdehlodcepfkgofelcenelpedj">
    <img src="https://img.shields.io/chrome-web-store/v/fphegifdehlodcepfkgofelcenelpedj?label=Chrome%20Web%20Store%20Nightly&style=for-the-badge">
  </a>
  <a aria-label="Rating" href="https://chrome.google.com/webstore/detail/7tv/fphegifdehlodcepfkgofelcenelpedj/reviews">
    <img src="https://img.shields.io/chrome-web-store/rating/fphegifdehlodcepfkgofelcenelpedj?style=for-the-badge">
  </a>
  <a aria-label="Users" href="https://chrome.google.com/webstore/detail/7tv/fphegifdehlodcepfkgofelcenelpedj">
    <img src="https://img.shields.io/chrome-web-store/users/fphegifdehlodcepfkgofelcenelpedj?style=for-the-badge">
  </a>
</p>

<p align="center">
  <a aria-label="GitHub release" href="https://github.com/SevenTV/Extension/releases">
    <img src="https://img.shields.io/github/v/release/SevenTV/Extension?style=for-the-badge">
  </a>
  <a aria-label="GitHub contributors" href="https://github.com/SevenTV/Extension/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/SevenTV/Extension?style=for-the-badge">
  </a>
  <a aria-label="GitHub issues" href="https://github.com/SevenTV/Extension/issues">
    <img src="https://img.shields.io/github/issues/SevenTV/Extension?style=for-the-badge">
  </a>
  <a aria-label="GitHub pull requests" href="https://github.com/SevenTV/Extension/pulls">
    <img src="https://img.shields.io/github/issues-pr/SevenTV/Extension?style=for-the-badge">
  </a>
</p>

## 🍎 Safari support

> [!TIP]
> **Want to use 7TV on Safari today?** This fork includes a free, unofficial
> self-build package for macOS. It uses the real 7TV Web Extension code and
> guides you through signing the Safari container with your own Apple Account.
>
> **[Open the 7TV for Safari installation guide →](safari-package/README.md)**

![Safari: Unofficial self-build](https://img.shields.io/badge/Safari-unofficial_self--build-f59e0b?logo=safari)
![macOS: 12+](https://img.shields.io/badge/macOS-12%2B-0a84ff?logo=apple)
![Updated: 2026-09-29](https://img.shields.io/badge/updated-2026--09--29-64748b)

The Safari package is maintained on the fork's installation branch and is
separate from the minimal upstream contribution. No official 7TV release,
signature, or endorsement is implied.

Safari support was proposed upstream in
**[SevenTV/Extension#1265](https://github.com/SevenTV/Extension/pull/1265)**.
The proposal is currently closed and not merged. Users who want official Safari
support can review it and show interest constructively. Meanwhile, this fork's
maintainer intends to keep the self-build package current, provided the 7TV
team has no objection.

> [!IMPORTANT]
> A normal one-click Safari release still requires 7TV-owned Apple signing,
> notarization, release hosting, and an official update policy. Only the 7TV
> team can publish and maintain that as an official 7TV distribution.

## Development

### Safari

The native Safari Web Extension wrapper uses the same Twitch, Kick and YouTube
implementations as the other browser builds.

The ideal public distribution is a signed and notarized `7TV for Safari.app`
produced by 7TV. This repository currently contains the source build target and
does not ship that official binary.

Until an official release exists, this fork provides an **unofficial,
self-built Xcode package**. It requires full
[Xcode](https://apps.apple.com/app/xcode/id497799835) and a free Apple Account,
but no Node.js, Yarn, Homebrew, or Git. See the
[complete Safari installation guide](safari-package/README.md) for manual,
command, and AI-assisted setup.

Maintainers building or preparing an official release can use:

```sh
yarn build:safari
./script/build-safari-local.sh
```

See [SAFARI.md](SAFARI.md) for user installation, maintainer builds, and public
distribution requirements.

Generate the unofficial distributable ZIP with:

```sh
./script/package-safari-xcode.sh
```

### Building

-   make deps
-   make production

For a development/nightly (non-stable) build, set `BRANCH=nightly` in your environment variables.

Build output located in `dist/`.

### Contributing

This extension is configured to work with HMR (Hot Module Replacement), which makes development significantly faster and more enjoyable than the traditional methods for making web extensions. This allows the developer to see changes reflect in real-time, even while on a remote website.

#### Working Locally

We use [Vite](https://vitejs.dev/) as a primary tool for development and bundling.

Getting the extension to work locally is fast and easy, follow these steps:

-   Clone the repo: `git clone git@github.com:SevenTV/Extension.git`
-   Install dependencies: `make deps`
-   Run `yarn start`

The extension will now be compiled into its initial bundle, which may take up to twenty seconds. In dev mode, it is configured to connect to the vite server, which will start right after the bundle is complete.

The build files will be located in the `dist/` folder: add this folder as an unpacked extension via the chrome extensions page.

#### Extension Loader

This repository is adapted as a BrowserExtension. It uses a `manifest.json` and the [Extension API](https://developer.chrome.com/docs/extensions/reference/) to run inside a browser.

The site-specific content and logic, however, runs as a Site Script, sectioned off by origin under `src/sites`. The Extension Content Script (`src/content/content.ts`) acts as a Loader for the site script, which is where the actual logic for modifying websites is located.

We do not use Isolated Worlds as we must access internal values from the website, which is not possible under an Extension Isolated World (content script).

#### Extension Background / Service Worker

The background script sets up some extension API-specific listeners for matters such as permissions. It also takes care of cross-site settings synchronization, by maintaining a copy of IndexedDB inside the Extension Context and re-distributing the updated config nodes to sites.

#### Site Script

Most of the logic inside the Extension runs under the Site Script, located under `src/sites`. Each folder there corresponds to an origin, such as `twitch.tv` or `youtube.com`. A module system exists to neatly section off features into their own space.

The site script works with HMR (Hot Module Replacement) and any changes to components within will hot-update accordingly, making UI building very efficient.
