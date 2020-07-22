import random, sympy
import numpy as np
from sympy import Matrix

from arithmetic.modp import *
from arithmetic.utils import *
from arithmetic.euclidean import *

from shamir_secre_sharing.shamir_secret import *
from shamir_secre_sharing.wrapper import *
from numpy.linalg import matrix_rank
from numpy.linalg import det


def generate_random_matrix(rows, columns, rank):
    # TODO: change 3911 to q
    m = np.random.randint(low=0, high=3911, size=(rows, columns))
    # print("m: {}".format(m))
    while matrix_rank(m) != rank:
        m = np.random.randint(low=0, high=3911, size=(rows, columns))
    return m


def generate_random_vector(d, t):
    vec = []
    for i in range(0, t):
        a = random.randint(1, d)
        vec.append(a)
    return vec


def adjugate(matrix, rows, columns):
    M = Matrix(matrix)
    #print("M: {}".format(M))
    m_adj = M.adjugate()
    c = [[i for i in range(rows)] for j in range(columns)]
    for i in range(rows):
        for j in range(columns):
            c[i][j] = m_adj[i,j]
    return c




class VHSS_TSS(object):

    def __init__(self, modQ):
        self.partialeval = {}
        self.partialproof = {}
        self.modQ = modQ

        pass

    def setup(self, k_security, p, q, nr_clients,
              threshold):  # threshold need to be smaller that the threshold t of the HSS.
        N = p * q  # p,q need to be safe primes
        p_prime = p - 1
        p_prime = int(p_prime / 2)
        q_prime = int((q - 1) / 2)
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

    def gen_secret_share_additive_with_threshold_ss(self, i, x_i, t, d_i, R_i, nr_servers, threshold, N, g,
                                                    public_key_i):
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
        shares = Protocol.generate_input_shamir_secret(x_i[0], t, nr_servers, self.modQ.p)
        # print("share: {} ".format(shares))
        A_i_tmp = generate_random_matrix(nr_servers, threshold, threshold)
        # print("A_i_tmp : {}".format(A_i_tmp))
        A_iS = A_i_tmp[0:threshold, 0:threshold]  # this is to create the \hat(t)x\hat(t) submatrix of A_i
        # print("A_is: {}".format(A_iS))
        delta_A_iS = det(A_iS)  # this is to compute the det of A_iS
        tmp = 2 * delta_A_iS
        gcd_pk_i_delta_AiS = gcd(int(tmp), int(public_key_i))
        # print("gcd : {}".format(gcd_pk_i_delta_AiS))

        while (gcd_pk_i_delta_AiS != 1):  # we make sure they are coprime before we go on.

            A_i_tmp = generate_random_matrix(nr_servers, threshold, threshold)
            A_iS = A_i_tmp[0:threshold, 0:threshold]  # this is to create the \hat(t)x\hat(t) submatrix of A_i
            delta_A_iS = det(A_iS)  # this is to compute the det of A_iS
            tmp = 2 * delta_A_iS
            gcd_pk_i_delta_AiS = gcd(int(tmp), int(public_key_i))
            # print("gcd : {}".format(gcd_pk_i_delta_AiS))

        vec_d = generate_random_vector(d_i, threshold)
        vec_d[0] = d_i

        omega = np.matmul(A_i_tmp, vec_d)
        print("Omega: {}".format(omega))
        # this gives us a vector omega=(shared_key_1,...,shared_key_m)
        # np.matmult is to do matrix multiplication
        # print("omega: {}".format(omega))

        shared_key_i = {}
        for j in range(1, nr_servers + 1):
            shared_key_i[j] = omega[j - 1]
        # now shared_key is a list of the shares of the d_i that will be given to the m servers

        exponent = x_i[0] + int(R_i) % (3910)
        H_i = g ** exponent  # this is the equivalent of \tau
        #print("H_i : {}".format(H_i))
        #print("A_i: {}".format(A_i_tmp))
        return shares, shared_key_i, A_i_tmp, H_i

    def partial_eval(self, j, shares_from_client, nr_clients):
        self.partialeval[j] = 0
        for i in range(1, nr_clients + 1):
            # print("shares_from_the_clients[i] : {}".format(shares_from_the_clients[i]))
            self.partialeval[j] = self.partialeval[j] + shares_from_client[i]
        return self.partialeval[j]

    def __partial_proof_i(self, shared_key_i, H_i, A_i, N, threshold,
                          public_key_i):  # shared_key_i is the list of the m shares of the secret key of each client i
        print("--- partial proof ----")
        #print("A_i = {}".format(A_i))
        A_iS = A_i[0:threshold, 0:threshold]  # this is to create the \hat(t)x\hat(t) submatrix of A_i
        #print("Ais: {}".format(A_iS))
        C_iS_adjugate = adjugate(A_iS, threshold, threshold)
       
        #print("C_iS: {}".format(C_iS_adjugate))
       
        sigma_i = {}
        for j in range(1, threshold + 1):
            #print("C_{}0 = {}".format((j-1), C_iS_adjugate[0][j-1]))
            #print("shared_key_i = {}".format(shared_key_i[j]))
            exponent = int(2 * C_iS_adjugate[0][j-1] * shared_key_i[j])
            #print("exponent: {}".format(exponent))
            sigma_i[j] = pow(H_i, exponent, N)
            #print("tmp: {}".format(tmp))
            #print("sigma_i[{}]: {}".format(j, sigma_i[j]))
        return sigma_i

    def partial_proof(self, omegas, H_is, A_is, N, threshold, nr_clients, public_keys):
        for i in range(0, nr_clients ):
            self.partialproof[i+1] = self.__partial_proof_i(omegas[i+1], H_is[i+1], A_is[i+1], N, threshold, public_keys[i+1])
        print("partial Proof: {}".format(self.partialproof))
        return self.partialproof

    def final_eval(self, nr_servers):
        finaleval = 0
        for j in range(1, nr_servers + 1):
            finaleval = finaleval + self.partialeval[j]
        return finaleval

    def __final_proof_i(self, public_key_i, H_i, sigma_i, A_i, N, threshold):
        print("Starting __final_proof__")
        bar_sigma_i = 1
        for j in range(1, threshold + 1):
            print("partial proof_i_{} : {}".format(j, sigma_i[j]))
            bar_sigma_i = bar_sigma_i * sigma_i[j]
        bar_sigma_i = bar_sigma_i % N
        A_iS = A_i[0:threshold, 0:threshold] 
        delta_A_iS = int(det(A_iS))

        tmp = 2 * delta_A_iS
        alpha, beta, lala = extendedEuclideanAlgorithm(tmp, public_key_i)

        test = tmp * alpha + beta * public_key_i
        print("test: {} - lala: {} -  alpha : {} -  beta: {}".format(test, lala, alpha, beta))

        tmp_1 = pow(bar_sigma_i, alpha, N)  #a^b mod N
        tmp_2 = pow(H_i, beta, N)

        final_sigma_i = (tmp_1) * (tmp_2)
        final_sigma_i = final_sigma_i % N
        return final_sigma_i

    def final_proof(self, public_keys, H_is, A_is, sigmas, threshold, N, nr_clients):
        final_proof = {}
        for i in range(1, nr_clients + 1):
            final_proof[i] = self.__final_proof_i(public_keys[i], H_is[i], self.partialproof[i], A_is[i], N, threshold)

        final_p = 1;
        for i in range(1, nr_clients + 1):
            tmp = int(final_proof[i])
            tmp = pow(tmp, public_keys[i], N) 
            final_p = (final_p * tmp) % N
       
        return final_p

    def verify(self, nr_clients, H_is, final_p, finaleval, g, N):
        prod = 1
        for i in range(1, nr_clients + 1):
            prod = prod * H_is[i]
        H_y = (int(g) ** int(finaleval)) % 3911
        prod = prod % 3911
        final_p = final_p % 3911
        print("y = {}".format(finaleval))
        print("prod = {} == {}  ^  H_y = {} == {}".format(prod, final_p, H_y, prod))
        if (H_y == prod) and (prod == final_p):
            print("yeahhh")
            return 1, finaleval
        else:
            return 0, finaleval
