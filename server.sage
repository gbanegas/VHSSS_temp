
load("additive_vhss.sage")


class Server():

    def __init__(self, j, vhss):
        self.j = j
        self.shares = {}
        self.vhss = vhss


    def set_share(self, i, share):
        self.shares[i] = share
