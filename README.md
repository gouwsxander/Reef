# Reef

The macOS window manager that gives every app its own Alt-Tab. 

![Cover photo. Reef logo and UI.](./github-assets/reef-banner-1280-short.jpg)

[Download for macOS](https://getreef.app) · [GitHub Releases](https://github.com/gouwsxander/Reef/releases/latest) (Requires macOS 14.6+)

[How we made Reef (YouTube)](https://youtu.be/niRCi5zJvHU)

## Key Features

Reef lets you bind applications to number keys and cycle through their windows with an Alt-Tab-like interface.

We built Reef because we wanted a fast and simple window switcher for macOS.

- Bind applications to number keys to refocus to **any** window for that app
- Assign profiles for different sets of bindings
- Do your binding and profile management through the keyboard
- Customizable keyboard shortcuts


## Usage

### Binding
You should start by binding different applications to the number keys. You can do this:
- through **Preferences → Profiles** (accessed through the menu bar), or
- by selecting the application of your choice and then pressing <kbd>Ctrl</kbd> + <kbd>Option</kbd> + <kbd>Shift</kbd>.

### Profiles
You can also set your bindings up in different profiles.

For example, you may want two profiles:
- "Coding": Which binds your favourite editor, browser, and terminal
- "Browsing": Which binds your favourite web browser, messaging app, and music client

You can switch between profiles:
- using the menu bar, or
- by binding them to the number keys, and then pressing <kbd>Ctrl</kbd> + <kbd>Option</kbd> + <kbd>[0-9]</kbd>.

### Switching applications
Suppose you're in your coding profile, and have your editor bound to `0`.

To switch between apps and windows:
1. Hold <kbd>Control</kbd> and press <kbd>0</kbd> to open a panel showing each of your editor's windows.
2. Press <kbd>0</kbd> multiple times to select the specific window you want.
3. Release <kbd>Control</kbd> to switch to the selected window.

In this way, Reef gives every app its own 'Alt-Tab'.

By default, window switching is scoped to your current [macOS space](https://support.apple.com/en-ca/guide/mac-help/mh14112/mac). See **Customization** to switch across all of them.

### Customization

You can customize the modifiers for switching applications and profiles, and for binding different applications in **Reef Preferences → Shortcuts**.

Turn on **Preferences → General → Include windows from other Spaces** to list an app's windows from every desktop, labelled with the desktop they are on, and switch desktops to reach them.

Reef also pairs well with [Rectangle](https://github.com/rxhanson/Rectangle):
- Rectangle positions & re-arranges your windows
- Reef re-focuses your windows


## Installation

Download the latest release on [our website](https://getreef.app) or [GitHub](https://github.com/gouwsxander/Reef/releases/latest)

Simply: 
1) Download the `.zip` and unzip the file.
2) Drag `Reef.app` into your Applications folder.

Reef is free/pay-what-you-want. Use the link on our website to support us.

### Compatibility

Reef is compatible with **macOS 14.6 (Sonoma)** and onwards. 

You can find your macOS version from the ** → About This Mac** page.


## Development

Please share issues and feedback via the [GitHub issues page](https://github.com/gouwsxander/Reef/issues).

Feel free to submit pull requests, though we can't guarantee that we'll get to them.


## FAQ
<details>
<summary><b>Why is it called "Reef"?</b></summary>
<br>
The name comes from the starting sounds of the words "refocus" and "reframe". And, like a coral reef supports a diverse ecosystem, Reef supports your workspace—helping you navigate between windows quickly and easily.
</details>


## Related Projects
- [yabai](https://github.com/asmvik/yabai)
- [Aerospace](https://github.com/nikitabobko/AeroSpace?tab=readme-ov-file)
- [Rectangle](https://github.com/rxhanson/Rectangle)
- [AltTab for macOS](https://github.com/lwouis/alt-tab-macos/tree/master)
