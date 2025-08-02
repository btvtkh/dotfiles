from ignis import widgets as Widget
from .date_time import DateTimeWidget
from .kb_layout import KbLayoutWidget
from .workspaces import WorkspacesWidget
from .tasks import TasksWidget
from .tray import TrayWidget

class Bar(Widget.Window):
    def __init__(self, monitor):
        super().__init__(
            monitor = monitor,
            namespace = f"Bar-{monitor}",
            anchor = ["left", "bottom", "right"],
            exclusivity = "exclusive",
            layer = "top",
            kb_mode = "none",
            css_classes = ["bar-window"],
            child = Widget.CenterBox(
                start_widget = Widget.Box(
                    child = [
                        WorkspacesWidget()
                    ]
                ),
                center_widget = Widget.Box(
                    child = [
                        TasksWidget()
                    ]
                ),
                end_widget = Widget.Box(
                    child = [
                        TrayWidget(),
                        KbLayoutWidget(),
                        DateTimeWidget()
                    ]
                )
            )
        )
