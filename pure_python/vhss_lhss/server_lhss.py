from abstract_class.server import *

class ServerLHSS(Server):

    def __init__(self, i, vhss):
        Server.__init__(self, i)
        self.vhss = vhss

    def get_shares(self):
        return  self.shares