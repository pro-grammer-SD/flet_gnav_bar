# Introduction

FletGnavBar for Flet.

## Examples

```
import flet as ft
from flet_gnav_bar import FletGNavBar, FletGNavBarButton

def main(page: ft.Page):
    page.title = "Flet GNavBar Demo"
    page.vertical_alignment = ft.MainAxisAlignment.END

    gnav = FletGNavBar(
        gap=8,
        selected_index=0,
        tabs=[
            FletGNavBarButton(name="Home", icon_name="home", color="#2FB14F"),
            FletGNavBarButton(name="Search", icon_name="search", color="#118DA3"),
            FletGNavBarButton(name="Profile", icon_name="user", color="#E6E21F"),
        ]
    )
    page.add(gnav)

ft.app(target=main)

ft.app(main)
```

## Classes

[FletGnavBar](FletGnavBar.md)
