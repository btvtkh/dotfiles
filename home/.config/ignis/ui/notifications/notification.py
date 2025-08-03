import time as Time
from ignis import widgets as Widget

UrgencyMap = {
    "-1": "not-provided",
    "0": "low",
    "1": "normal",
    "2": "critical"
}

class ActionButton(Widget.Button):
    def __init__(self, action):

        def on_click(x):
            action.invoke()

        super().__init__(
            css_classes = ["action-button"],
            hexpand = True,
            child = Widget.Label(
                halign = "center",
                ellipsize = "end",
                max_width_chars = 15,
                hexpand = True,
                label = action.label
            ),
            on_click = on_click
        )

class NotificationWidget(Widget.Box):
    def __init__(self, n):

        def on_close_click(x):
            n.close()

        super().__init__(
            css_classes = [
                "notification-box",
                f"{UrgencyMap[str(n.urgency)]}"
            ],
            vertical = True,
            child = [
                Widget.Box(
                    css_classes = ["header-box"],
                    child = [
                        Widget.Label(
                            css_classes = ["app-name-label"],
                            halign = "start",
                            ellipsize = "end",
                            label = n.app_name or "Unknown"
                        ),
                        Widget.Label(
                            css_classes = ["time-label"],
                            hexpand = True,
                            halign = "end",
                            label = Time.strftime('%H:%M', Time.gmtime(n.time))
                        ),
                        Widget.Button(
                            css_classes = ["close-button"],
                            on_click = on_close_click,
                            child = Widget.Icon(
                                image = "window-close-symbolic"
                            )
                        )
                    ]
                ),
                Widget.Separator(),
                Widget.Box(
                    css_classes = ["content-box"],
                    child = [
                        n.icon and Widget.Icon(
                            css_classes = ["icon-image"],
                            valign = "start",
                            image = n.icon
                        ) or None,
                        Widget.Box(
                            vertical = True,
                            child = [
                                Widget.Label(
                                    css_classes = ["summary-label"],
                                    halign = "start",
                                    ellipsize = "end",
                                    xalign = 0,
                                    label = n.summary
                                ),
                                Widget.Label(
                                    css_classes = ["body-label"],
                                    use_markup = True,
                                    wrap = True,
                                    wrap_mode = "char",
                                    halign = "start",
                                    justify = "fill",
                                    ellipsize = "end",
                                    xalign = 0,
                                    lines = 4,
                                    label = n.body
                                )
                            ]
                        )
                    ]
                ),
                len(n.actions) > 0 and Widget.Box(
                    css_classes = ["actions-box"],
                    child = [
                        ActionButton(action) for action in n.actions
                    ]
                )
            ]
        )
