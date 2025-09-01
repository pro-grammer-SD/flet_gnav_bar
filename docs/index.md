# Introduction

## FletGNavBar 🌟

Custom **Google Navigation Bar (GNav) control** for Flet apps, built on Flutter's [`google_nav_bar`](https://pub.dev/packages/google_nav_bar) package.

[![PyPI Version](https://img.shields.io/pypi/v/flet_gnav_bar.svg)](https://pypi.org/project/flet_gnav_bar/)
[![Flutter Package](https://img.shields.io/pub/v/google_nav_bar.svg)](https://pub.dev/packages/google_nav_bar)
[![License](https://img.shields.io/github/license/pro-grammer-SD/flet_gnav_bar)](https://github.com/pro-grammer-SD/flet_gnav_bar/blob/main/LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/pro-grammer-SD/flet_gnav_bar/python-package.yml)](https://github.com/pro-grammer-SD/flet_gnav_bar/actions)

---

## Features

- Fully compatible with **Flet**.
- Supports **tabs with icons, labels, and optional badges**.
- Customizable **colors, active/inactive states, ripple, and hover effects**.
- Works on **desktop, web, and mobile** targets.

---

## Installation

### Git dependency

Add to your `pyproject.toml`:

```toml
dependencies = [
  "flet_gnav_bar @ git+https://github.com/pro-grammer-SD/flet_gnav_bar",
  "flet>=0.28.3",
]
```

### PyPI dependency

If published on PyPI:

```toml
dependencies = [
  "flet_gnav_bar",
  "flet>=0.28.3",
]
```

Build your app:

```bash
flet build macos -v
```

---

## Example Usage

```python
import flet as ft
from flet_gnav_bar import FletGNavBar, FletGNavBarButton

def main(page: ft.Page):
    gnav = FletGNavBar(
        selected_index=0,
        tabs=[
            FletGNavBarButton(name="Home", icon_name="home", color="#2FB14F", badge="5"),
            FletGNavBarButton(name="Search", icon_name="search", color="#118DA3"),
            FletGNavBarButton(name="Profile", icon_name="user", color="#E6E21F", badge="!")
        ]
    )

    gnav.on_change = lambda _: print("Selected index:", gnav.selected_index)
    page.add(gnav)

ft.app(target=main)
```

---

## Documentation

Full documentation is available [here](https://pro-grammer-SD.github.io/flet_gnav_bar/).

---
