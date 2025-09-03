from typing import Optional
from flet.core.constrained_control import ConstrainedControl
from flet.core.control import Control
from flet import OptionalNumber
import json

class FletGNavBarButton(Control):
    """
    Represents a single button in a Google Navigation Bar (GNav) for Flet.

    Supports icons or network images, badges, haptic feedback, and full styling.

    Attributes:
        name (str): Button label text.
        icon_name (str): Icon name or URL (https://) for network image.
        color (Optional[str]): General fallback color.
        active (bool): Whether the button is active.
        haptic (bool): Enable haptic feedback.
        background_color (Optional[str]): Background color.
        icon_color (Optional[str]): Icon color when inactive.
        ripple_color (Optional[str]): Ripple effect color.
        hover_color (Optional[str]): Hover color.
        icon_active_color (Optional[str]): Icon color when active.
        text_color (Optional[str]): Text color.
        debug (bool): Enable debug visuals.
        gap (float): Space between icon and text.
        icon_size (float): Icon size.
        text_size (float): Text size.
        semantic_label (Optional[str]): Accessibility label.
        badge_text (Optional[str]): Badge text.
        badge_color (Optional[str]): Badge text color.
        badge_background_color (Optional[str]): Badge background color.
        badge_visible (bool): Show badge.
        opacity (OptionalNumber): Button opacity.
        tooltip (Optional[str]): Tooltip text.
        visible (bool): Visibility.
        disabled (bool): Disabled state.
    """

    def __init__(
        self,
        name: str,
        icon_name: str,
        color: Optional[str] = None,
        active: bool = False,
        haptic: bool = True,
        background_color: Optional[str] = None,
        icon_color: Optional[str] = None,
        ripple_color: Optional[str] = None,
        hover_color: Optional[str] = None,
        icon_active_color: Optional[str] = None,
        text_color: Optional[str] = "#FFFFFF",
        debug: bool = False,
        gap: float = 8,
        icon_size: float = 24,
        text_size: float = 14,
        semantic_label: Optional[str] = None,
        badge_text: Optional[str] = None,
        badge_color: Optional[str] = None,
        badge_background_color: Optional[str] = None,
        badge_visible: bool = False,
        opacity: OptionalNumber = 1,
        tooltip: Optional[str] = None,
        visible: bool = True,
    ):
        self._button_data = {}
        super().__init__(opacity=opacity, tooltip=tooltip, visible=visible)
        self._button_data.update({
            "text": name,
            "icon": icon_name,
            "active": active,
            "haptic": haptic,
            "backgroundColor": background_color or color,
            "iconColor": icon_color or color,
            "rippleColor": ripple_color,
            "hoverColor": hover_color,
            "iconActiveColor": icon_active_color,
            "textColor": text_color or color,
            "debug": debug,
            "gap": gap,
            "iconSize": icon_size,
            "textSize": text_size,
            "semanticLabel": semantic_label,
            "disabled": False,
            "badgeText": badge_text,
            "badgeColor": badge_color,
            "badgeBackgroundColor": badge_background_color,
            "badgeVisible": badge_visible,
        })
        self._set_attr_json("buttonData", self._button_data)

    def _get_control_name(self):
        return "flet_gnav_bar_button"

    def _get_button_data(self):
        return self._button_data

    # Properties for all fields
    @property
    def name(self) -> str:
        return self._button_data["text"]

    @name.setter
    def name(self, value: str):
        self._button_data["text"] = value
        self._set_attr_json("buttonData", self._button_data)

    @property
    def icon_name(self) -> str:
        """str: Icon name or URL (https://) for network image."""
        return self._button_data["icon"]

    @icon_name.setter
    def icon_name(self, value: str):
        """Sets icon name or network image URL."""
        if value.startswith("https://"):
            self._button_data["icon"] = {"type": "image", "src": value}
        else:
            self._button_data["icon"] = {"type": "icon", "name": value}
        self._set_attr_json("buttonData", self._button_data)

    @property
    def active(self) -> bool:
        return self._button_data["active"]

    @active.setter
    def active(self, value: bool):
        self._button_data["active"] = value
        self._set_attr_json("buttonData", self._button_data)

    @property
    def haptic(self) -> bool:
        return self._button_data["haptic"]

    @haptic.setter
    def haptic(self, value: bool):
        self._button_data["haptic"] = value
        self._set_attr_json("buttonData", self._button_data)

    @property
    def disabled(self) -> bool:
        return self._button_data["disabled"]

    @disabled.setter
    def disabled(self, value: bool):
        self._button_data["disabled"] = value
        self._set_attr_json("buttonData", self._button_data)

    @property
    def badge_visible(self) -> bool:
        return self._button_data["badgeVisible"]

    @badge_visible.setter
    def badge_visible(self, value: bool):
        self._button_data["badgeVisible"] = value
        self._set_attr_json("buttonData", self._button_data)

class FletGNavBar(ConstrainedControl):
    """
    Google Navigation Bar (GNav) container for multiple FletGNavBarButton instances.

    Supports selected index, badges, haptic feedback, tab styling, and network images.

    Attributes:
        tabs (list[FletGNavBarButton]): List of buttons.
        selected_index (int): Currently selected tab index.
        gap (float): Space between tabs.
        active_color (str): Active tab color.
        color (str): Inactive tab color.
        ripple_color (str): Ripple color on click.
        hover_color (str): Hover color.
        background_color (str): Nav bar background.
        tab_background_color (str): Background of individual tabs.
        tab_border_radius (float): Tab corner radius.
        icon_size (float): Tab icon size.
        text_size (float): Tab text size.
        debug (bool): Debug visuals.
        haptic (bool): Haptic feedback.
    """

    def __init__(
        self,
        tabs: Optional[list[FletGNavBarButton]] = None,
        selected_index: int = 0,
        gap: float = 8,
        active_color: Optional[str] = None,
        color: Optional[str] = None,
        ripple_color: Optional[str] = None,
        hover_color: Optional[str] = None,
        background_color: Optional[str] = None,
        tab_background_color: Optional[str] = None,
        tab_border_radius: Optional[float] = None,
        icon_size: Optional[float] = None,
        text_size: Optional[float] = None,
        debug: bool = False,
        haptic: Optional[bool] = None,
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.__tabs: list[FletGNavBarButton] = tabs or []
        self._update_tabs_attr()

        self.selected_index = selected_index
        self.gap = gap
        self.active_color = active_color
        self.color = color
        self.ripple_color = ripple_color
        self.hover_color = hover_color
        self.background_color = background_color
        self.tab_background_color = tab_background_color
        self.tab_border_radius = tab_border_radius
        self.icon_size = icon_size
        self.text_size = text_size
        self.debug = debug
        self.haptic = haptic

    def _update_tabs_attr(self):
        self._set_attr_json(
            "tabsData", [json.loads(btn._get_attr("buttonData")) for btn in self.__tabs]
        )

    def _get_control_name(self):
        return "flet_gnav_bar"

    @property
    def tabs(self) -> list[FletGNavBarButton]:
        return self.__tabs

    @tabs.setter
    def tabs(self, value: list[FletGNavBarButton]):
        self.__tabs = value or []
        self._update_tabs_attr()

    @property
    def selected_index(self) -> int:
        return self._get_attr("selectedIndex", data_type="int")

    @selected_index.setter
    def selected_index(self, value: int):
        self._set_attr("selectedIndex", value)

    @property
    def gap(self) -> float:
        return self._get_attr("gap", data_type="float")

    @gap.setter
    def gap(self, value: float):
        self._set_attr("gap", value)

    @property
    def active_color(self) -> Optional[str]:
        return self._get_attr("activeColor")

    @active_color.setter
    def active_color(self, value: Optional[str]):
        self._set_attr("activeColor", value)

    @property
    def color(self) -> Optional[str]:
        return self._get_attr("color")

    @color.setter
    def color(self, value: Optional[str]):
        self._set_attr("color", value)

    @property
    def ripple_color(self) -> Optional[str]:
        return self._get_attr("rippleColor")

    @ripple_color.setter
    def ripple_color(self, value: Optional[str]):
        self._set_attr("rippleColor", value)

    @property
    def hover_color(self) -> Optional[str]:
        return self._get_attr("hoverColor")

    @hover_color.setter
    def hover_color(self, value: Optional[str]):
        self._set_attr("hoverColor", value)

    @property
    def background_color(self) -> Optional[str]:
        return self._get_attr("backgroundColor")

    @background_color.setter
    def background_color(self, value: Optional[str]):
        self._set_attr("backgroundColor", value)

    @property
    def tab_background_color(self) -> Optional[str]:
        return self._get_attr("tabBackgroundColor")

    @tab_background_color.setter
    def tab_background_color(self, value: Optional[str]):
        self._set_attr("tabBackgroundColor", value)

    @property
    def tab_border_radius(self) -> Optional[float]:
        return self._get_attr("tabBorderRadius", data_type="float")

    @tab_border_radius.setter
    def tab_border_radius(self, value: Optional[float]):
        self._set_attr("tabBorderRadius", value)

    @property
    def icon_size(self) -> Optional[float]:
        return self._get_attr("iconSize", data_type="float")

    @icon_size.setter
    def icon_size(self, value: Optional[float]):
        self._set_attr("iconSize", value)

    @property
    def text_size(self) -> Optional[float]:
        return self._get_attr("textSize", data_type="float")

    @text_size.setter
    def text_size(self, value: Optional[float]):
        self._set_attr("textSize", value)

    @property
    def debug(self) -> bool:
        return self._get_attr("debug", data_type="bool")

    @debug.setter
    def debug(self, value: bool):
        self._set_attr("debug", value)

    @property
    def haptic(self) -> Optional[bool]:
        return self._get_attr("haptic", data_type="bool")

    @haptic.setter
    def haptic(self, value: Optional[bool]):
        self._set_attr("haptic", value)
        