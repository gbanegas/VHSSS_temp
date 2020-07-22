

class ServerTS(object):

    def __init__(self, j):
        self.j = j
        self.shares = {}

    def set_share(self, i, share):
        self.shares[i] = share
