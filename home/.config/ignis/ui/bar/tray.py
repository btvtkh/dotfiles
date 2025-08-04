import asyncio
from ignis import widgets as Widget
from ignis.services.system_tray import SystemTrayService

system_tray = SystemTrayService.get_default()

class TrayItem(Widget.Button):
    def __init__(self, item):

        self._item_box = Widget.Box()
        self._item_icon = Widget.Icon(pixel_size = 16)
        self._item_menu = item.get_menu().copy()

        def on_icon(x, y):
            self._item_icon.set_image(x.get_icon())

        def on_click(x):
            asyncio.create_task(item.activate_async())

        def on_right_click(x):
            if self._item_menu:
                self._item_menu.popup()

        def on_removed(x):
            self.unparent()

        def setup(x):
            item.connect("notify::icon", on_icon)
            item.connect("removed", on_removed)

            self._item_icon.set_image(item.get_icon())
            self._item_box.set_child([self._item_icon, self._item_menu])


        super().__init__(
            css_classes = ["item-button"],
            child = self._item_box,
            on_click = on_click,
            on_right_click = on_right_click,
            setup = setup
        )

class TrayWidget(Widget.Box):
    def __init__(self):

        self._tray_visibile = False
        self._reveal_button_icon = Widget.Icon()
        self._items_revealer = Widget.Revealer(transition_type = "slide_left")
        self._items_box = Widget.Box()

        def on_click(x):
            self._tray_visibile = not self._tray_visibile
            self._reveal_button_icon.set_image(
                self._tray_visibile and "pan-end-symbolic" or "pan-start-symbolic"
            )
            self._items_revealer.set_reveal_child(self._tray_visibile)

        def on_added(x, y):
            self._items_box.append(TrayItem(y))

        def setup(x):
            system_tray.connect("added", on_added)
            self._reveal_button_icon.set_image(
                self._tray_visibile and "pan-end-symbolic" or "pan-start-symbolic"
            )
            self._items_revealer.set_child(self._items_box)
            self._items_revealer.set_reveal_child(self._tray_visibile)
            self.set_child([
                Widget.Button(
                    css_classes = ["reveal-button"],
                    child = self._reveal_button_icon,
                    on_click = on_click
                ),
                self._items_revealer
            ])

        super().__init__(
            css_classes = ["tray-box"],
            setup = setup
        )
