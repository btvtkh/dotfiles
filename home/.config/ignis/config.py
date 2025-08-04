import os
from ignis import utils as Utils
from ignis.css_manager import CssManager, CssInfoPath
from ui import (
    Bar,
    Notifications,
    Launcher
)

css_manager = CssManager.get_default()

css_manager.apply_css(
    CssInfoPath(
        name = "main",
        path = os.path.expanduser("~/.config/ignis/style/index.scss"),
        compiler_function = lambda path: Utils.sass_compile(path = path)
    )
)

for monitor in range(Utils.get_n_monitors()):
    Bar(monitor)
    Notifications(monitor)

Launcher()
