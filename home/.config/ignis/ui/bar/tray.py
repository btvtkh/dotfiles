import asyncio
from ignis import widgets as Widget
from ignis.services.system_tray import SystemTrayService

system_tray = SystemTrayService.get_default()

class TrayItem(Widget.Button):
    def __init__(self, item):

        def on_click(x):
            asyncio.create_task(item.activate_async())

        def on_right_click(x):
            if self.get_child().get_last_child().popup:
                self.get_child().get_last_child().popup()

        def on_removed(x):
            self.unparent()

        def setup(x):
            item.connect("removed", on_removed)

            if item.get_menu():
                self.get_child().append(item.get_menu().copy())

        super().__init__(
            css_classes = ["item-button"],
            child = Widget.Box(
                child = [
                    Widget.Icon(
                        image = item.bind("icon"),
                        pixel_size = 16
                    )
                ]
            ),
            on_click = on_click,
            on_right_click = on_right_click,
            setup = setup
        )

class TrayWidget(Widget.Box):
    def __init__(self):

        tray_visibile = False

        def on_click(x):
            nonlocal tray_visibile
            tray_visibile = not tray_visibile
            self.get_first_child().get_child().set_image(
                tray_visibile and "pan-end-symbolic" or "pan-start-symbolic"
            )
            self.get_last_child().set_reveal_child(tray_visibile)

        def on_added(x, y):
            self.get_last_child().get_child().append(TrayItem(y))

        def setup(x):
            system_tray.connect("added", on_added)

        super().__init__(
            css_classes = ["tray-box"],
            child = [
                Widget.Button(
                    css_classes = ["reveal-button"],
                    child = Widget.Icon(
                        image = tray_visibile and "pan-end-symbolic" or "pan-start-symbolic"
                    ),
                    on_click = on_click
                ),
                Widget.Revealer(
                    transition_type = "slide_left",
                    child = Widget.Box(),
                    reveal_child = tray_visibile,
                )
            ],
            setup = setup
        )
