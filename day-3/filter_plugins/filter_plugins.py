from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible import errors

def get_mongo_src(arg, a, b, c):
    result = "is not available for current conditions"
    if a == "RedHat":
        a = "rhel"
    d = a + b
    for i in range(len(arg)):
        arg[i] = arg[i].split('-')
        if d in arg[i][3]:
            if c in arg[i][4]:
                result = '-'.join(arg[i])
    return result

class FilterModule(object):
    def filters(self):
        return {
            'get_mongo_src': get_mongo_src
        }
