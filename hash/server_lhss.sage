load("additive_lhss.sage")

class Server():

    def __init__(self, j, lhss):
        self.j = j
        self.shares = {}
        self.lhss = lhss


    def set_share(self, i, share):
        self.shares[i] = share
    
    def get_shares(self):
        return self.shares
