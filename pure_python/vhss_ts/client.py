
from vhss_ts.params import *
from vhss_ts.tss import *

class ClientTS(object):

    def __init__(self, i, secret_input, private_key, public_key, r_i, tss):
        self.i = i
        self.secret_input = secret_input
        self.private_key = private_key
        self.public_key = public_key
        self.r_i = r_i
        self.tss = tss
        print("public_key: {}".format(public_key))

    def generate_shares(self, N):
        shares, shared_key, matrix_A, hash_H  = self.tss.gen_secret_share_additive_with_threshold_ss( self.secret_input, self.private_key, self.r_i, self.public_key)
        self.shared_key = shared_key
        self.matrix_A = matrix_A
        self.hash_H = hash_H
        return shares, shared_key, matrix_A, hash_H
