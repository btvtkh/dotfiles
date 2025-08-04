from ignis import widgets as Widget
from ignis.services.hyprland import HyprlandService

hyprland = HyprlandService.get_default()
keyboard = hyprland.get_main_keyboard()

class KbLayoutWidget(Widget.Button):
    def __init__(self):

        self._kb_label = Widget.Label()

        def on_click(x):
            keyboard.switch_layout("next")

        def on_keyboard_active_keymap(x, y):
            self._kb_label.set_label(x.get_active_keymap()[:2])

        def setup(x):
            keyboard.connect("notify::active-keymap", on_keyboard_active_keymap)
            self._kb_label.set_label(keyboard.get_active_keymap()[:2])

        super().__init__(
            css_classes = ["kb-layout-button"],
            child = self._kb_label,
            on_click = on_click,
            setup = setup
        )


