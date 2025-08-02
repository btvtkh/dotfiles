from ignis import widgets as Widget
from ignis import utils as Util
from ignis.services.notifications import NotificationService
from .notification import NotificationWidget

notifications = NotificationService.get_default()

class NotificationPopup(Widget.Box):
    def __init__(self, window, n):

        self._inner = Widget.Revealer(
            transition_type = "slide_left",
            child = NotificationWidget(n)
        )

        self._outer = Widget.Revealer(
            transition_type = "slide_down",
            child = self._inner
        )

        def on_closed(x):
            def destroy():
                self.unparent()
                if len(notifications.get_notifications()) == 0:
                    window.set_visible(False)

            def close_outer():
                self._outer.set_reveal_child(False)
                Util.Timeout(
                    self._outer.get_transition_duration(),
                    destroy
                )

            self._inner.set_reveal_child(False)
            Util.Timeout(
                self._outer.get_transition_duration(),
                close_outer
            )

        def setup(x):
            n.connect("closed", on_closed)

        super().__init__(
            child = [self._outer],
            halign = "end",
            setup = setup
        )

class Notifications(Widget.Window):
    def __init__(self, monitor):

        def on_notified(x, n):
            self.set_visible(True)

            popup = NotificationPopup(self, n)
            self.get_child().prepend(popup)

            popup._outer.set_reveal_child(True)

            def open_inner():
                popup._inner.set_reveal_child(True)

            Util.Timeout(
                popup._outer.get_transition_duration(),
                open_inner
            )

        def setup(x):
            notifications.connect("notified", on_notified)

            ns = notifications.get_notifications()
            for i in range(len(ns)):
                n = ns[i]
                on_notified(notifications, n)

        super().__init__(
            monitor = monitor,
            namespace = f"Notifications-{monitor}",
            anchor = ["top", "right", "bottom"],
            layer = "top",
            dynamic_input_region = True,
            visible = False,
            css_classes = ["notifications-window"],
            child = Widget.Box(
                css_classes = ["notifications-box"],
                vertical = True,
                valign = "start"
            ),
            setup = setup
        )
