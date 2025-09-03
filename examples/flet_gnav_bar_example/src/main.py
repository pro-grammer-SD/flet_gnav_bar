import flet as ft
from flet_gnav_bar import FletGNavBar, FletGNavBarButton

def main(page: ft.Page):
    page.title = "Flet GNavBar Demo"
    page.vertical_alignment = ft.MainAxisAlignment.END

    counter = 0

    gnav = FletGNavBar(
        tabs=[
            FletGNavBarButton(name="Home", icon_name="home", color="#2FB14F"),
            FletGNavBarButton(name="Search", icon_name="search", color="#118DA3"),
            FletGNavBarButton(name="Hearts", icon_name="heart", color="#C71720"),
            FletGNavBarButton(name="Profile", icon_name="https://sooxt98.space/content/images/size/w100/2019/01/profile.png", color="#E6E21F"),
        ]
    )

    def on_tab_change(e):
        nonlocal counter
        counter += 1
        print("Current index:", gnav.selected_index)

        for tab in gnav.tabs:
            if tab.name == "Hearts":
                if gnav.selected_index == gnav.tabs.index(tab):
                    tab.badge_visible = False
                else:
                    tab.badge_text = f"{counter}+"
                    tab.badge_visible = True
                tab._set_attr_json("buttonData", tab._button_data)

    gnav.on_change = on_tab_change
    page.add(gnav)

ft.app(target=main)
