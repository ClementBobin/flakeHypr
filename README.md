# 🧊 flakeHypr (aka richendots)

My personal dotfiles from the flake template of hydenix

---

## Table of Contents

* [About](#about)
* [Features](#features)
* [Contents / Structure](#contents--structure)
* [Requirements](#requirements)
* [Installation](#installation)
* [Configuration](#configuration)
* [Usage](#usage)
* [Customization](#customization)
* [Modules](#modules)
* [Contributing](#contributing)
* [License](#license)
* [Roadmap / TODO](#roadmap--todo)

---

## About

flakeHypr is a personal setup for managing dotfiles and system configuration using **Nix flakes**.
It is heavily inspired by / based on the flake template by *hydenix*, with adaptations specific to my workflow and machine(s).
Some modules are specific to my system; you’re welcome to use parts of what you need as a reference.

---

## 🚀 Project Description

flakeHypr is an advanced Nix Flake configuration for the Hyprland Wayland compositor that enables highly customizable and reproducible desktop environments.

Hyprland is known for its dynamic tiling and eye-catching visual effects, while NixOS brings immutable infrastructure and declarative configuration to the desktop. This project blends both to provide a powerful, maintainable, and visually stunning setup.

---

## ✨ Key Features

| Feature |	Description |
| --- | --- |
| 🔧 Modular Structure |	Organized configuration modules for easy customization and maintenance |
| 🎨 Hyprland Integration |	Pre-configured with optimized Hyprland settings and visual enhancements |
| ⚡ Performance Optimized |	Lightweight and fast with efficient defaults |
| 🔄 Multi-System Support |	Works consistently across different NixOS systems |
| 🧩 Dependency Management |	Nix handles all dependencies and versioning |
| 🔐 Secure Defaults |	Privacy-conscious and security-hardened settings |

---

## 📁 Contents / Structure

Here’s a breakdown of what the repository contains:

```
├── .github/                # GitHub-specific configs (CI, templates, etc.)
├── hosts/                  # Host-specific configurations
├── modules/                # Reusable modules (services, UI, etc.)
├── flake.nix               # Main entry point / flake configuration
├── flake.lock              # Locked versions of all dependencies
├── info.txt                # Auxiliary information (purpose/details)
├── CHANGELOG.md            # Release notes & version history
├── TODO.md                 # Planned changes / to-dos
├── .gitignore              # Files/folders ignored by git
├── releaserc.json          # Release tooling configuration
└── LICENSE                 # Project license
```

---

## 💻 Requirements

To use flakeHypr, you’ll typically need:

- 🐧 Nix with flakes enabled

- 🧠 Basic understanding of NixOS and Hyprland

- 💾 System compatible with the modules used

- 🛠️ Ability to manage your system config (root/admin)

---

## 📦 Installation

Enable Flakes (if not already enabled):

```bash

echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nixos/configuration.nix
sudo nixos-rebuild switch

```

Clone the Repository:

```bash

git clone https://github.com/ClementBobin/flakeHypr.git
cd flakeHypr
```

Review Configuration (optional but recommended):
Examine the flake.nix and adjust system-specific settings as needed.

Install the Configuration:

```bash

sudo nixos-rebuild switch --flake .#your-hostname

```

Replace your-hostname with your actual system hostname.
Adjust the host name / module names to your particular setup.

---

## ⚙️ Configuration

* Each host has its own configuration under `hosts/`
* Shared modules are in `modules/`
* Settings / options for modules can be found in those module directories

You can enable, disable or modify modules for your machine by editing the appropriate host flake input(s).

---

## Usage

* To update dependencies: run `nix flake update` (this will update `flake.lock`)
* To switch system configuration or regenerate dotfiles: rebuild via the flake (using `nix build` / `nixos-rebuild` / `home-manager` etc., depending on target)
* For debugging: check logs for module failures / conflicts

---

## Customization

You’re welcome to:

* Use parts of this configuration for your setup
* Copy modules you like
* Adapt host configurations
* Extend modules with your own custom scripts, options, etc.

If you repurpose or redistribute, please retain or credit authorship where relevant.

---

## Modules

Some example modules included:

* Host-specific settings under `hosts/`
* UI, service, or environment modules under `modules/`
* Possibly modules for window manager, display, fonts, networking, etc. (depending on what’s in `modules/`)

---

## 🤝 Contributing

We welcome contributions to flakeHypr! Here's how you can help:

### 🐛 Reporting Bugs

Open an issue via GitHub
Include:
    - Your NixOS version
    - Relevant hardware details
    - Logs and config snippets

### 💡 Suggesting Features

Create an issue and label it enhancement

Clearly describe:
    - The use case
    - Suggested implementation or configuration options

---

## 📄 License

This project is licensed under the **GPL‑3.0 License**.

---

## Roadmap / TODO

Some upcoming or desired items include (see `TODO.md` for fuller list):

* Clean up / refactor host‑specific modules to be more generic
* Expand documentation for using / customizing modules
* Add testing or CI verification of configuration for different hosts
* Possibly package more modules for reuse by others

