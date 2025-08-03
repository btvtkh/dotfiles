from ignis import widgets as Widget
from ignis import utils as Util
from ignis.services.notifications import NotificationService
from .notification import NotificationWidget

notifications = NotificationService.get_default()

class NotificationPopup(Widget.Box):
    def __init__(self, window, n):

        def on_closed(x):

            def close():
                self.unparent()
                if len(notifications.get_notifications()) == 0:
                    window.set_visible(False)

            def animate_outer():
                self.get_first_child().set_reveal_child(False)
                Util.Timeout(
                    self.get_first_child().get_transition_duration(),
                    close
                )

            def animate_inner():
                self.get_first_child().get_child().set_reveal_child(False)
                Util.Timeout(
                    self.get_first_child().get_child().get_transition_duration(),
                    animate_outer
                )

            animate_inner()

        def setup(x):
            n.connect("closed", on_closed)

        super().__init__(
            halign = "end",
            child = [
                Widget.Revealer(
                    transition_type = "slide_down",
                    child = Widget.Revealer(
                        transition_type = "slide_left",
                        child = NotificationWidget(n)
                    )
                )
            ],
            setup = setup
        )

class Notifications(Widget.Window):
    def __init__(self, monitor):

        def on_notified(x, n):
            popup = NotificationPopup(self, n)

            def open():
                self.set_visible(True)
                self.get_child().prepend(popup)

            def animate_inner():
                popup.get_first_child().get_child().set_reveal_child(True)

            def animate_outer():
                open()
                popup.get_first_child().set_reveal_child(True)
                Util.Timeout(
                    popup.get_first_child().get_transition_duration(),
                    animate_inner
                )

            animate_outer()

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
                vertical = True,
                valign = "start"
            ),
            setup = setup
        )
