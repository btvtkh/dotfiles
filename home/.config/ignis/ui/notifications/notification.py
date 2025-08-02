from ignis import widgets as Widget

class ActionButton(Widget.Button):
    def __init__(self, action):

        def on_click(x):
            action.invoke()

        super().__init__(
            css_classes = ["action-button"],
            child = Widget.Label(
                label = action.label
            ),
            on_click = on_click
        )

class NotificationWidget(Widget.Box):
    def __init__(self, n):

        def on_close_click(x):
            n.close()

        super().__init__(
            css_classes = ["notification-box"],
            vertical = True,
            hexpand = True,
            child = [
                Widget.Box(
                    child = [
                        Widget.Icon(
                            image = n.icon and n.icon or "dialog-information-symbolic",
                            pixel_size = 48,
                            halign = "start",
                            valign = "start",
                        ),
                        Widget.Box(
                            vertical = True,
                            style = "margin-left: 0.75rem;",
                            child = [
                                Widget.Label(
                                    css_classes = ["summary-label"],
                                    ellipsize = "end",
                                    halign = "start",
                                    label = n.summary,
                                    visible = n.summary != "",
                                ),
                                Widget.Label(
                                    css_classes = ["body-label"],
                                    ellipsize = "end",
                                    halign = "start",
                                    label = n.body,
                                    visible = n.body != "",
                                ),
                            ],
                        ),
                        Widget.Button(
                            css_classes = ["close-button"],
                            halign = "end",
                            valign = "start",
                            hexpand = True,
                            child = Widget.Icon(
                                image = "window-close-symbolic",
                                pixel_size = 20
                            ),
                            on_click = on_close_click,
                        ),
                    ],
                ),
                Widget.Box(
                    css_classes = ["actions-box"],
                    homogeneous = True,
                    child = [ActionButton(action) for action in n.actions]
                )
            ]
        )
