from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.callback import CallbackBase
from termcolor import colored
#| rc={3} >>\n

class CallbackModule(CallbackBase):

    '''
    This is the default callback interface, which simply prints messages
    to stdout when new callback events are received.
    '''

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'demo'

    def show(self, task, host, result, caption):
        buf = "------------------>|||{0} | {1} | {2} ".format(task, host, caption,
                                                     result.get('rc', 'n/a'))
        buf += result.get('stdout', '')
        buf += result.get('stderr', '')
        buf += result.get('msg', '')
        print(buf + "\n")

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self.show(result._task, result._host.get_name(), result._result, "FAILED")

    def v2_runner_on_ok(self, result):
        self.show(result._task, result._host.get_name(), result._result, "OK")

    def v2_runner_on_skipped(self, result):
        self.show(result._task, result._host.get_name(), result._result, "SKIPPED")

    def v2_runner_on_unreachable(self, result):
        self.show(result._task, result._host.get_name(), result._result, "UNREACHABLE")
