from abstract_class.server import *

class ServerTSS(Server):

    def __init__(self, j, vhss):
        Server.__init__(self, j)
        self.vhss = vhss
        self.shared_keys = {}
        self.A_is = {}
        self.H_is = {}

    def set_share(self, i, share, shared_key, A_i, H_i):
        self.shares[i] = share
        self.shared_keys[i] = shared_key
        self.A_is[i] = A_i
        self.H_is = H_i


    def get_shares(self):
        return self.shares

    def get_id(self):
        return self.j