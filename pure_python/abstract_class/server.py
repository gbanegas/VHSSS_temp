from abc import ABC, abstractmethod


class Server(ABC):

    def __init__(self, j):
        self.j = j
        self.shares = {}
        pass

    def set_share(self, i, share):
        self.shares[i] = share
