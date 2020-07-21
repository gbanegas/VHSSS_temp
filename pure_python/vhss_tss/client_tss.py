
from abstract_class.client import *

class ClientTSS(Client):

    def __init__(self, id_client, secret_input, t, g, r_i, d_i, public_key, tss):
        Client.__init__(self, id_client, secret_input, t, g, r_i)
        self.d_i = d_i
        self.public_key = public_key
        self.vhss = tss

    def generate_shares(self, nr_servers, threshold, N, g):
      shares, shared_key_i, A_i, H_i  = self.vhss.gen_secret_share_additive_with_threshold_ss(self.i, self.x_i, self.t, self.d_i, self.R_i, nr_servers, threshold, N, g, self.public_key)
      self.shared_key = shared_key_i
      self.A = A_i
      self.H_i = H_i
      return shares, shared_key_i, A_i, H_i