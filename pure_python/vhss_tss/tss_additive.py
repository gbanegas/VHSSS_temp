import random, sympy
import numpy as np

from arithmetic.modp import *
from arithmetic.utils import *

from shamir_secre_sharing.shamir_secret import *
from shamir_secre_sharing.wrapper import *
from numpy.linalg import matrix_rank

def generate_random_matrix(rows, columns, rank):
    m = np.random.rand(rows, columns)
    while matrix_rank(m) != rank:
        m = np.random.rand(rows, columns)
    return m


class VHSS_TSS(object):

    def __init__(self, modQ):
        self.partialeval = {}
        self.partialproof = {}
        self.modQ = modQ

        pass

    def setup(self, k_security, p, q, nr_clients,
              threshold):  # threshold need to be smaller that the threshold t of the HSS.
        N = p * q  # p,q need to be safe primes
        p_prime = (p - 1) / 2
        q_prime = (q - 1) / 2
        phi_N = (p - 1) * (q - 1)  # (p-1)(q-1)=2p'*2q'=4p'q'in the paper it is p'*q' instead of 2*p'*q'
        N_prime = 2 * q_prime * p_prime  # this is just used by us to compute e.
        lower_bound = sympy.binomial(nr_clients, threshold)
        e = random.randint(lower_bound, N_prime)
        while gcd(e, N_prime) != 1:
            e = random.randint(lower_bound, N_prime)
        d = mod_inverse(e, N_prime)
        pk = e
        sk = d
        return pk, sk

    def gen_secret_share_additive_with_threshold_ss(self, i, x_i, t, d_i, R_i, nr_servers, threshold, N, g, public_key_i):
        # we add the e_i as input to be able to check that (public_key_i, det(A_i))=1.
        """
        i: index of the client
        x_i: secret input of the client i
        d_i: secret key of client i
        R_i: is such that R_i=PRG(i,file_i) which will be given I guess
        nr_servers: threshold t for the number of shares
        threshold: the one used at the setup
        """
        shares = {}
        H_i = None
        shares = Protocol.generate_input_shamir_secret(x_i[0], t, nr_servers)
        A_i_tmp = generate_random_matrix(nr_servers, threshold, threshold)
        print("A_i_tmp : {}".format(A_i_tmp))





        return shares, i, H_i

