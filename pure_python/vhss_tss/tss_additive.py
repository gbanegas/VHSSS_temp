import random, sympy
import numpy as np

from arithmetic.modp import *
from arithmetic.utils import *

from shamir_secre_sharing.shamir_secret import *
from shamir_secre_sharing.wrapper import *
from numpy.linalg import matrix_rank
from numpy.linalg import det

def generate_random_matrix(rows, columns, rank):
  #TODO: change 3911 to q 
    m = np.random.randint(low=0,high=3911,size=(rows,columns) )
    #print("m: {}".format(m))
    while matrix_rank(m) != rank:
        m = np.random.randint(low=0,high=3911,size=(rows,columns) )
    return m
def generate_random_vector(t):
   vec = np.random.randint(low=0,high=3911,size=t )
   return vec



class VHSS_TSS(object):

    def __init__(self, modQ):
        self.partialeval = {}
        self.partialproof = {}
        self.modQ = modQ

        pass

    def setup(self, k_security, p, q, nr_clients, threshold):  # threshold need to be smaller that the threshold t of the HSS.
        N = p * q  # p,q need to be safe primes
        p_prime = (p - 1) / 2
        q_prime = (q - 1) / 2
        phi_N = (p - 1) * (q - 1)  # (p-1)(q-1)=2p'*2q'=4p'q'in the paper it is p'*q' instead of 2*p'*q'
        N_prime = 2 * q_prime * p_prime  # this is just used by us to compute e.
        lower_bound = sympy.binomial(nr_clients, threshold)
        print("lower bound: {}".format(lower_bound))
        e = random.randint(lower_bound, N_prime)
        while sympy.gcd(e, N_prime) != 1:
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
        H_i = None
        print("--- Starting Generation Shares --- ")
        shares = Protocol.generate_input_shamir_secret(x_i[0], t, nr_servers)
        print("share: {} ".format(shares))
        A_i_tmp = generate_random_matrix(nr_servers, threshold, threshold)
        print("A_i_tmp : {}".format(A_i_tmp))
        A_iS = A_i_tmp[0:threshold, 0:threshold] #this is to create the \hat(t)x\hat(t) submatrix of A_i
        print("A_is: {}".format(A_iS))
        delta_A_iS = det(A_iS)#this is to compute the det of A_iS
        tmp = 2*delta_A_iS
        gcd_pk_i_delta_AiS = sympy.gcd(tmp, public_key_i)
        print("gcd : {}".format(gcd_pk_i_delta_AiS))

        while( gcd_pk_i_delta_AiS != 1):#we make sure they are coprime before we go on.
            print("gcd : {}".format(gcd_pk_i_delta_AiS))
            A_i_tmp = generate_random_matrix(nr_servers, threshold, threshold)
            print("A_i_tmp : {}".format(A_i_tmp))

            A_iS = A_i_tmp[0:threshold, 0:threshold] #this is to create the \hat(t)x\hat(t) submatrix of A_i
            print("A_is: {}".format(A_iS))
            delta_A_iS = det(A_iS)#this is to compute the det of A_iS
            tmp = 2*delta_A_iS
            gcd_pk_i_delta_AiS = sympy.gcd(tmp, public_key_i)
        
        vec_d = generate_random_vector(threshold)
        vec_d[0] = d_i  
        
        A_i=A_i_tmp
        omega = np.matmul(A_i,vec_d)
         #this gives us a vector omega=(shared_key_1,...,shared_key_m)
         #np.matmult is to do matrix multiplication
        print("omega: {}".format(omega))

        shared_key_i = {}
        for j in range(1, nr_servers+1):
            shared_key_i[j] = omega[j-1]
        #now shared_key is a list of the shares of the d_i that will be given to the m servers

        exponent = x_i[0] + int(R_i) % 3911
        H_i = pow(g, exponent) #this is the equivalent of \tau
        print("H_I : {}".format(H_i))
       
        return shares, shared_key_i, A_i, H_i

