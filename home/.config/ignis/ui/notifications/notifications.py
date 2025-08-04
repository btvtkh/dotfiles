from ignis import widgets as Widget
from ignis import utils as Util
from ignis.services.notifications import NotificationService
from .notification import NotificationWidget

notifications = NotificationService.get_default()

class NotificationPopup(Widget.Box):
    def __init__(self, window, n):

        self._outer = Widget.Revealer(transition_type = "slide_down")
        self._inner = Widget.Revealer(transition_type = "slide_left")

        def on_closed(x):
            def close():
                self.unparent()
                if len(notifications.get_notifications()) == 0:
                    window.set_visible(False)

            def animate_outer():
                self._outer.set_reveal_child(False)
                Util.Timeout(
                    self._outer.get_transition_duration(),
                    close
                )

            def animate_inner():
                self._inner.set_reveal_child(False)
                Util.Timeout(
                    self._inner.get_transition_duration(),
                    animate_outer
                )

            animate_inner()

        def setup(x):
            n.connect("closed", on_closed)
            self._inner.set_child(NotificationWidget(n))
            self._outer.set_child(self._inner)
            self.set_child([self._outer])

        super().__init__(
            halign = "end",
            setup = setup
        )

class Notifications(Widget.Window):
    def __init__(self, monitor):

        self._notifications_box = Widget.Box(vertical = True, valign = "start")

        def on_notified(x, n):
            popup = NotificationPopup(self, n)

            def open():
                self.set_visible(True)
                self._notifications_box.prepend(popup)

            def animate_inner():
                popup._inner.set_reveal_child(True)

            def animate_outer():
                open()
                popup._outer.set_reveal_child(True)
                Util.Timeout(
                    popup._outer.get_transition_duration(),
                    animate_inner
                )

            animate_outer()

        def setup(x):
            self.set_child(self._notifications_box)
            notifications.connect("notified", on_notified)

            for n in notifications.get_notifications():
                on_notified(notifications, n)

        super().__init__(
            monitor = monitor,
            namespace = f"Notifications-{monitor}",
            anchor = ["top", "right", "bottom"],
            layer = "top",
            dynamic_input_region = True,
            visible = False,
            css_classes = ["notifications-window"],
            setup = setup
        )
