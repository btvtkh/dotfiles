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

        self._date_label = Widget.Label()
        self._time_label = Widget.Label()

        def on_time_poll_changed(x):
            self._date_label.set_label(DateTime.datetime.now().strftime("%d %b, %a"))
            self._time_label.set_label(DateTime.datetime.now().strftime("%H:%M"))

        def setup(x):
            time_poll.connect("changed", on_time_poll_changed)
            self._date_label.set_label(DateTime.datetime.now().strftime("%d %b, %a"))
            self._time_label.set_label(DateTime.datetime.now().strftime("%H:%M"))

        super().__init__(
            css_classes = ["date-time-box"],
            child = [
                self._date_label,
                Widget.Separator(),
                self._time_label
            ],
            setup = setup
        )
