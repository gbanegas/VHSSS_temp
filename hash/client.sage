
load("additive_vhss.sage")
class Client():

    def __init__(self, i, x_i, t, g, R_i, vhss):
        self.i = i
        self.x_i = x_i
        self.t = t
        self.g = g
        self.R_i = R_i
        self.vhss = vhss



    def generate_shares(self, nr_servers):
        #vhss = VHSSAdditive() #Initialization of the class VHSSAdditive
        shares, tau_i  = self.vhss.gen_secret_share_additive_with_hash_functions( self.i, self.x_i, self.t, nr_servers, self.R_i, self.g)
        self.tau_i = tau_i
        return shares

    def get_tau_i(self):
        return self.tau_i
