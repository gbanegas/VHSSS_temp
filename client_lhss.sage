load("additive_lhss.sage")
class Client():

    def __init__(self, i, x_i, t, g, lhss):
        self.i = i
        self.x_i = x_i
        self.t = t
        self.g = g
        self.lhss = lhss



    def generate_shares(self, nr_servers):
        #lhss = LHSSAdditive() #Initialization of the class LHSSAdditive
        shares, tau_i  = self.lhss.gen_secret_share_additive_with_linear_hom_sign( self.i, self.x_i, self.t, nr_servers, self.g)
        return shares
