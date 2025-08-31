from typing import Optional
from flet.core.constrained_control import ConstrainedControl
from flet.core.control import Control
from flet import OptionalNumber
import json

class FletGNavBarButton(Control):
    """
    Represents a button inside a Google Navigation Bar (GNav).

    Args:
        name (str): The text label of the button.
        icon_name (str): The name of the icon to display.
        color (Optional[str], optional): General color applied to multiple parts if no specific colors are set.
        active (Optional[bool], optional): Whether the button is active. Defaults to False.
        haptic (Optional[bool], optional): Whether to enable haptic feedback. Defaults to True.
        background_color (Optional[str], optional): Background color of the button.
        icon_color (Optional[str], optional): Color of the icon when inactive.
        ripple_color (Optional[str], optional): Color of the ripple effect.
        hover_color (Optional[str], optional): Color when hovered.
        icon_active_color (Optional[str], optional): Color of the icon when active.
        text_color (Optional[str], optional): Color of the button text. Defaults to white.
        debug (Optional[bool], optional): Enable debug visuals.
        gap (Optional[float], optional): Space between icon and text. Defaults to 8.
        icon_size (Optional[float], optional): Size of the icon. Defaults to 24.
        text_size (Optional[float], optional): Font size of the text. Defaults to 14.
        semantic_label (Optional[str], optional): Semantic label for accessibility tools.
        opacity (OptionalNumber, optional): Opacity of the button. Defaults to 1.
        tooltip (Optional[str], optional): Tooltip text on hover.
        visible (Optional[bool], optional): Whether the button is visible. Defaults to True.
    """

    def __init__(
        self,
        name: str,
        icon_name: str,
        color: Optional[str] = None,
        active: Optional[bool] = False,
        haptic: Optional[bool] = True,
        background_color: Optional[str] = None,
        icon_color: Optional[str] = None,
        ripple_color: Optional[str] = None,
        hover_color: Optional[str] = None,
        icon_active_color: Optional[str] = None,
        text_color: Optional[str] = "#FFFFFF",
        debug: Optional[bool] = False,
        gap: Optional[float] = 8,
        icon_size: Optional[float] = 24,
        text_size: Optional[float] = 14,
        semantic_label: Optional[str] = None,
        opacity: OptionalNumber = 1,
        tooltip: Optional[str] = None,
        visible: Optional[bool] = True,
    ):
        super().__init__(opacity=opacity, tooltip=tooltip, visible=visible)
        self._set_attr(
            "buttonData",
            json.dumps(
                {
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
                }
            ),
        )

    def _get_control_name(self):
        """Returns the control identifier for Flet runtime integration."""
        return "flet_gnav_bar_button"

class FletGNavBar(ConstrainedControl):
    """
    A Google Navigation Bar (GNav) container.

    Args:
        tabs (Optional[list[FletGNavBarButton]], optional): List of navigation bar buttons.
        selected_index (Optional[int], optional): Index of the currently selected tab.
        gap (Optional[float], optional): Default spacing between icon and text.
        active_color (Optional[str], optional): Default active element color.
        color (Optional[str], optional): Default inactive element color.
        ripple_color (Optional[str], optional): Ripple effect color.
        hover_color (Optional[str], optional): Hover effect color.
        background_color (Optional[str], optional): Bar background color.
        tab_background_color (Optional[str], optional): Background color of active tab.
        tab_border_radius (Optional[float], optional): Border radius for tab highlight. Defaults to 100.
        icon_size (Optional[float], optional): Default icon size.
        text_size (Optional[float], optional): Default text size.
        debug (Optional[bool], optional): Enables debug visuals.
        haptic (Optional[bool], optional): Enables haptic feedback on interaction.
        **kwargs: Additional keyword arguments for `ConstrainedControl`.
    """

    def __init__(
        self,
        tabs: Optional[list[FletGNavBarButton]] = None,
        selected_index: Optional[int] = 0,
        gap: Optional[float] = None,
        active_color: Optional[str] = None,
        color: Optional[str] = None,
        ripple_color: Optional[str] = None,
        hover_color: Optional[str] = None,
        background_color: Optional[str] = None,
        tab_background_color: Optional[str] = None,
        tab_border_radius: Optional[float] = None,
        icon_size: Optional[float] = None,
        text_size: Optional[float] = None,
        debug: Optional[bool] = False,
        haptic: Optional[bool] = None,
        **kwargs,
    ):
        super().__init__(**kwargs)

        self._tabs: list[FletGNavBarButton] = tabs or []
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
        """Updates internal attribute with serialized tab button data."""
        self._set_attr(
            "tabsData",
            json.dumps([json.loads(btn._get_attr("buttonData")) for btn in self._tabs]),
        )

    @property
    def tabs(self) -> list[FletGNavBarButton]:
        """List of navigation bar buttons (`FletGNavBarButton`)."""
        return self._tabs

    @tabs.setter
    def tabs(self, value: list[FletGNavBarButton]):
        self._tabs = value or []
        self._update_tabs_attr()

    def _get_control_name(self):
        """Returns the control identifier for Flet runtime integration."""
        return "flet_gnav_bar"

    @property
    def selected_index(self):
        """Currently selected tab index."""
        return self._get_attr("selectedIndex", data_type="int")

    @selected_index.setter
    def selected_index(self, value: Optional[int]):
        self._set_attr("selectedIndex", value)

    @property
    def gap(self):
        """Default gap between icons and text inside buttons."""
        return self._get_attr("gap", data_type="float")

    @gap.setter
    def gap(self, value: Optional[float]):
        self._set_attr("gap", value)

    @property
    def active_color(self):
        """Active color for icons/text when selected."""
        return self._get_attr("activeColor")

    @active_color.setter
    def active_color(self, value: Optional[str]):
        self._set_attr("activeColor", value)

    @property
    def on_change(self):
        """Event triggered when the selected tab changes."""
        return self._get_event_handler("change")

    @on_change.setter
    def on_change(self, handler):
        self._add_event_handler("change", handler)

    @property
    def color(self):
        """Default inactive color for icons/text."""
        return self._get_attr("color")

    @color.setter
    def color(self, value: Optional[str]):
        self._set_attr("color", value)

    @property
    def ripple_color(self):
        """Ripple effect color when tapping a tab."""
        return self._get_attr("rippleColor")

    @ripple_color.setter
    def ripple_color(self, value: Optional[str]):
        self._set_attr("rippleColor", value)

    @property
    def hover_color(self):
        """Hover effect color."""
        return self._get_attr("hoverColor")

    @hover_color.setter
    def hover_color(self, value: Optional[str]):
        self._set_attr("hoverColor", value)

    @property
    def background_color(self):
        """Background color of the navigation bar."""
        return self._get_attr("backgroundColor")

    @background_color.setter
    def background_color(self, value: Optional[str]):
        self._set_attr("backgroundColor", value)

    @property
    def tab_background_color(self):
        """Background color of the selected tab."""
        return self._get_attr("tabBackgroundColor")

    @tab_background_color.setter
    def tab_background_color(self, value: Optional[str]):
        self._set_attr("tabBackgroundColor", value)

    @property
    def tab_border_radius(self):
        """Corner radius for the selected tab highlight."""
        return self._get_attr("tabBorderRadius", data_type="float")

    @tab_border_radius.setter
    def tab_border_radius(self, value: Optional[float]):
        self._set_attr("tabBorderRadius", value)

    @property
    def icon_size(self):
        """Default icon size for all tabs."""
        return self._get_attr("iconSize", data_type="float")

    @icon_size.setter
    def icon_size(self, value: Optional[float]):
        self._set_attr("iconSize", value)

    @property
    def text_size(self):
        """Default text size for tab labels."""
        return self._get_attr("textSize", data_type="float")

    @text_size.setter
    def text_size(self, value: Optional[float]):
        self._set_attr("textSize", value)

    @property
    def debug(self):
        """Enable or disable debug visuals."""
        return self._get_attr("debug", data_type="bool")

    @debug.setter
    def debug(self, value: Optional[bool]):
        self._set_attr("debug", value)

    @property
    def haptic(self):
        """Enable or disable haptic feedback for tab interactions."""
        return self._get_attr("haptic", data_type="bool")

    @haptic.setter
    def haptic(self, value: Optional[bool]):
        self._set_attr("haptic", value)
        