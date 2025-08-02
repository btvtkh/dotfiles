import time as Time
import datetime as DateTime
from ignis import utils as Utils
from ignis import widgets as Widget

TIME_POLL_TIMEOUT = 60

def calc_timeout(real_timeout):
    return real_timeout - int(Time.time()) % real_timeout

def time_poll_callback(self):
    self.set_timeout(calc_timeout(TIME_POLL_TIMEOUT)*1000)

time_poll = Utils.Poll(
    timeout = TIME_POLL_TIMEOUT*1000,
    callback = time_poll_callback
)

class DateTimeWidget(Widget.Box):
    def __init__(self):

        def on_time_poll_changed(x):
            self.get_first_child().set_label(DateTime.datetime.now().strftime("%d %b, %a"))
            self.get_last_child().set_label(DateTime.datetime.now().strftime("%H:%M"))

        def setup(x):
            time_poll.connect("changed", on_time_poll_changed)

        super().__init__(
            css_classes = ["date-time-box"],
            child = [
                Widget.Label(
                    label = DateTime.datetime.now().strftime("%d %b, %a")
                ),
                Widget.Separator(),
                Widget.Label(
                    label = DateTime.datetime.now().strftime("%H:%M")
                )
            ],
            setup = setup
        )
