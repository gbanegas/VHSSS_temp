from abc import abstractmethod


class Client(object):

    def __init__(self, id_client, secret_input, t, g, r_i):
        self.i = id_client
        self.x_i = secret_input
        self.t = t
        self.g = g
        self.R_i = r_i
        pass

    @abstractmethod
    def generate_shares(self, nr_servers):
        pass

    @abstractmethod
    def get_tau_i(self):
        pass
