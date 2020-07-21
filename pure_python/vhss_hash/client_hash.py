

from abstract_class.client import *

class ClientHash(Client):

    def __init__(self, id_client, secret_input, t, g, r_i, vhss):
        Client.__init__(self, id_client, secret_input, t, g, r_i)
        self.vhss = vhss
        self.tau_i = 0

    def generate_shares(self, nr_servers):
        shares, tau_i = self.vhss.gen_secret_share_additive_with_hash_functions(self.i, self.x_i, self.t, nr_servers, self.R_i, self.g)
        self.tau_i = tau_i
        return shares

    def get_tau_i(self):
        return self.tau_i
