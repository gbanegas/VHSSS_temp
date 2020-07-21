from abstract_class.client import *

class ClientLHSS(Client):

    def __init__(self, id_client, secret_input, t, g, r_i, vhss):
        Client.__init__(self, id_client, secret_input, t, g, r_i)
        self.vhss = vhss
        self.tau_i = 0

    def generate_shares(self, nr_servers):
        shares = self.vhss.gen_secret_share_additive_with_linear_hom_sign(self.i, self.x_i, self.t, nr_servers, self.g)
        return shares

    def get_tau_i(self):
        return 0
