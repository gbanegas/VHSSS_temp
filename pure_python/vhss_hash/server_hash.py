from abstract_class.server import *

class ServerHash(Server):

    def __init__(self, i, vhss):
        Server.__init__(self, i)
        self.vhss = vhss