import re
import gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio
from ignis import widgets as Widget
from ignis.services.hyprland import HyprlandService

hyprland = HyprlandService.get_default()

def launch_app(app):
    desktop_app_info = Gio.DesktopAppInfo.new(Gio.AppInfo.get_id(app))
    term_needed = Gio.DesktopAppInfo.get_string(desktop_app_info, "Terminal") == "true"
    term = Gio.AppInfo.get_default_for_uri_scheme('terminal')

    hyprland.send_command(f"dispatch exec {
        term_needed and
            term and f"{term.get_executable()} -e {app.get_executable()}"
        or
            re.search("^env", app.get_executable()) and
                re.sub("%a", "", app.get_commandline())
            or
                app.get_executable()
    }")

class AppButton(Widget.Button):
    def __init__(self, window, app):

        def on_click(x):
            launch_app(app)
            window.set_visible(False)

        super().__init__(
            css_classes = ["app-button"],
            child = Widget.Box(
                vertical = True,
                child = [
                    Widget.Label(
                        css_classes = ["app-name-label"],
                        halign = "start",
                        xalign = 0,
                        ellipsize = "end",
                        max_width_chars = 45,
                        label = app.get_name()
                    ),
                    Widget.Label(
                        css_classes = ["app-description-label"],
                        halign = "start",
                        xalign = 0,
                        ellipsize = "end",
                        max_width_chars = 45,
                        label = app.get_description()
                    )
                ]
            ),
            on_click = on_click
        )

class Launcher(Widget.Window):
    def __init__(self):

        self._apps_box = Widget.Box(
            vertical = True,
            spacing = 5
        )

        self._apps_scroll = Widget.Scroll(
            hexpand = True,
            child = self._apps_box
        )

        def hide(x):
            self.set_visible(False)

        def setup(x):
            self._apps_box.set_child([
                app.should_show() and AppButton(self, app) or None for app in Gio.AppInfo.get_all()
            ])

        super().__init__(
            namespace = "Launcher",
            anchor = ["right", "left", "top", "bottom"],
            layer = "top",
            kb_mode = "on_demand",
            popup = True,
            css_classes = ["launcher-window"],
            visible = False,
            child = Widget.Box(
                child = [
                    Widget.EventBox(
                        hexpand = True,
                        on_click = hide
                    ),
                    Widget.Box(
                        hexpand = False,
                        vertical = True,
                        child = [
                            Widget.EventBox(
                                vexpand = True,
                                on_click = hide,
                            ),
                            Widget.Box(
                                css_classes = ["main-box"],
                                child = [
                                    self._apps_scroll
                                ]
                            ),
                            Widget.EventBox(
                                vexpand = True,
                                on_click = hide,
                            )
                        ]
                    ),
                    Widget.EventBox(
                        hexpand = True,
                        on_click = hide
                    )
                ]
            ),
            setup = setup
        )
