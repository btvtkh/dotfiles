from ignis.services.hyprland import HyprlandService
from ignis import widgets as Widget

hyprland = HyprlandService.get_default()

class TaskButton(Widget.Button):
    def __init__(self, window):

        def on_click(x):
            hyprland.send_command(f"dispatch focuswindow address:{window.get_address()}")
            hyprland.send_command("dispatch bringactivetotop")

        def on_middle_click(x):
            hyprland.send_command(f"dispatch killwindow address:{window.get_address()}")

        def on_workspace_id(x, y):
            self.set_visible(x.get_workspace_id() == hyprland.get_active_workspace().get_id())

        def on_active_workspace(x, y):
            self.set_visible(window.get_workspace_id() == x.get_active_workspace().get_id())

        def on_active_window(x, y):
            if window.get_address() == x.get_active_window().get_address():
                self.add_css_class("focused")
            else:
                self.remove_css_class("focused")

        def setup(x):
            window.connect("notify::workspace-id", on_workspace_id)
            hyprland.connect("notify::active-workspace", on_active_workspace)
            hyprland.connect("notify::active-window", on_active_window)

        super().__init__(
            css_classes = [
                "task-button",
                window.get_address() == hyprland.get_active_window().get_address() and "focused" or None
            ],
            child = Widget.Label(
                max_width_chars = 15,
                ellipsize = "end",
                label = window.get_initial_class()
            ),
            visible = window.get_workspace_id() == hyprland.get_active_workspace().get_id(),
            on_click = on_click,
            on_middle_click = on_middle_click,
            setup = setup
        )

class TasksWidget(Widget.Box):
    def __init__(self):

        def on_windows(x, y):
            self.set_child([
                TaskButton(w) for w in x.get_windows()
            ])

        def setup(x):
            hyprland.connect("notify::windows", on_windows)

        super().__init__(
            css_classes = ["tasks-box"],
            child = [
                TaskButton(w) for w in hyprland.get_windows()
            ],
            setup = setup
        )
