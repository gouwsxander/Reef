# Reef

The macOS window manager that gives every app its own alt-tab. 

Reef lets you bind applications to number keys and cycle through their windows all through the keyboard.

We built Reef because we wanted a _minimal_ window manager.

https://github.com/user-attachments/assets/931d81af-4c67-4257-9edc-33fa976596eb


## Key Features

- Bind applications to number keys to refocus to **any** window for that app
- Assign profiles for different sets of bindings
- Do your binding and profile management through the keyboard
- Customizable keyboard shortcuts


## Usage

### Binding
You should start by binding different applications to the number keys. You can do this
- through Preferences > Profiles (accessed through the menu bar), or
- by selecting the application of your choice and then pressing ctrl + option + shift.

### Profiles
You can also set your bindings up in different profiles.

For example, you may want two profiles:
- "Coding": Which binds your favourite editor, browser, and terminal
- "Browsing": Which binds your favourite browser, messaging app, and music client

You can switch between profiles
- using the menu bar, or
- by binding them to the number keys, and then pressing `Control` + `Option` + `[Number]`.

### Switching applications
Suppose you're in the coding profile, and have your editor bound to `0`.

To switch between apps and windows:
1. Hold `Control` and press `0` to open a panel showing each of your editor's windows.
2. Press `0` multiple times to select the specific window you want.
3. Release `Control` to switch to that window.

Reef gives every app its own 'alt-tab'.

Note that window switching is scoped to your current Desktop.

### Customization

You can customize the modifiers for switching applications and profiles, and for binding different applications in Preferences > Shortcuts.

Reef also works well [Rectangle](https://github.com/rxhanson/Rectangle) to manage your workflow. 

Rectangle allows you to position your windows via shortcuts. Reef allows you to re-focus.


## Installation

The latest release can be downloaded from the release page [here](https://github.com/gouwsxander/Reef/releases).

Simply: 
1) Download the latest `.zip` and unzip the file.
2) Drag `Reef.app` into your Applications folder.


### Support Us
If you'd like to support our project, consider downloading the app through our `polar.sh` with the button below.

[![Polar](https://img.shields.io/badge/Support-Polar-blue?logo=polar&logoColor=white)](https://buy.polar.sh/polar_cl_IF5QroqZydcaTqJ6orukn9Zls48tlu4CPsSCo3Ymxoy)



### Compatibility

Reef is compatible with `MacOS 14.6 (Sonoma)` and onwards. 

You can find your MacOS version in your `About this Mac` page.

<img width="291" height="127" alt="image" src="https://github.com/user-attachments/assets/ef0c821e-9615-4ef9-af84-954d49d41978" />



## Development

Reef is currently in open Beta and we're applying the finishing touches for `version 1` release mid March. 

Stay tuned :)

Open Beta users can share issues and feeback in the issues page with us [here](https://github.com/gouwsxander/Reef/issues).


## FAQ
<details>
<summary><b>Why Reef?</b></summary>
<br>
The name comes from the starts of refocus and reframe. And, like a coral reef supports a diverse ecosystem, Reef supports your workspace—helping you navigate between windows quickly and easily.
</details>

## Related Projects
- [yabai](https://github.com/asmvik/yabai)
- [Aerospace](https://github.com/nikitabobko/AeroSpace?tab=readme-ov-file)
- [Rectangle](https://github.com/rxhanson/Rectangle)
- [alt-tab](https://github.com/lwouis/alt-tab-macos/tree/master)
