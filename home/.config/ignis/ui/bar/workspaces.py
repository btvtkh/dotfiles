from ignis.services.hyprland import HyprlandService
from ignis import widgets as Widget

hyprland = HyprlandService.get_default()

class WorkspaceButton(Widget.Button):
    def __init__(self, workspace):

        def on_click(x):
            workspace.switch_to()

        def on_active_workspace(x, y):
            if workspace.get_id() == x.get_active_workspace().get_id():
                self.add_css_class("focused")
            else:
                self.remove_css_class("focused")

        def setup(x):
            hyprland.connect("notify::active-workspace", on_active_workspace)

        super().__init__(
            css_classes = [
                "workspace-button",
                workspace.get_id() == hyprland.get_active_workspace().get_id() and "focused" or None
            ],
            child = Widget.Label(
                label = workspace.get_name()
            ),
            on_click = on_click,
            setup = setup
        )

class WorkspacesWidget(Widget.Box):
    def __init__(self):

        def on_workspaces(x, y):
            self.set_child([WorkspaceButton(i) for i in x.get_workspaces()])

        def setup(x):
            hyprland.connect("notify::workspaces", on_workspaces)

        super().__init__(
            css_classes = ["workspaces-box"],
            child = [WorkspaceButton(i) for i in hyprland.get_workspaces()],
            setup = setup
        )
