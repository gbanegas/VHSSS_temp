import sympy, random
from vhss_ts.params import *

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
    # print("M: {}".format(M))
    m_adj = M.adjugate()
    c = [[i for i in range(rows)] for j in range(columns)]
    for i in range(rows):
        for j in range(columns):
            c[i][j] = m_adj[i, j]
    return c


class TSS(object):

    def __init__(self, modQ):
        self.partial_proof_value_sigma = {}
        self.partial_eval_values = {}
        self.modQ = modQ

    def key_gen(self, p, q):
        p_prime = p - 1
        p_prime = int(p_prime / 2)
        q_prime = int((q - 1) / 2)
        N_prime = 2 * q_prime * p_prime  # this is just used by us to compute e.
        lower_bound = sympy.binomial(Params.NR_CLIENTS, Params.THRESHOLD)
        e = random.randint(lower_bound, N_prime)
        while gcd(e, N_prime) != 1:
            e = random.randint(lower_bound, N_prime)
        d = mod_inverse(e, N_prime)
        pk = e
        sk = d
        return pk, sk

    def gen_secret_share_additive_with_threshold_ss(self, secret_input, private_key, random_e, public_key):
        H_i = None
        print("--- Starting Generation Shares --- ")
        shares = Protocol.generate_input_shamir_secret(secret_input[0], Params.THRESHOLD_CLIENTS, Params.NR_SERVERS,
                                                       self.modQ.p)

        matrix_A_i_tmp = generate_random_matrix(Params.NR_SERVERS, Params.THRESHOLD, Params.THRESHOLD)
        matrix_A_iS = matrix_A_i_tmp[0:Params.THRESHOLD,
                      0:Params.THRESHOLD]  # this is to create the \hat(t)x\hat(t) submatrix of A_i
        delta_A_iS = det(matrix_A_iS)  # this is to compute the det of A_iS
        tmp = 2 * delta_A_iS
        gcd_pk_i_delta_AiS = gcd(tmp, public_key)

        while (gcd_pk_i_delta_AiS != 1):  # we make sure they are coprime before we go on.
            matrix_A_i_tmp = generate_random_matrix(Params.NR_SERVERS, Params.THRESHOLD, Params.THRESHOLD)
            matrix_A_iS = matrix_A_i_tmp[0:Params.THRESHOLD,
                          0:Params.THRESHOLD]  # this is to create the \hat(t)x\hat(t) submatrix of A_i
            delta_A_iS = det(matrix_A_iS)  # this is to compute the det of A_iS
            tmp = 2 * delta_A_iS
            gcd_pk_i_delta_AiS = gcd(tmp, public_key)
            # print("gcd : {}".format(gcd_pk_i_delta_AiS))

        vec_d = generate_random_vector(private_key, Params.THRESHOLD)
        vec_d[0] = private_key

        omega = np.matmul(matrix_A_i_tmp, vec_d)
        shared_key_i = {}
        for j in range(1, Params.NR_SERVERS + 1):
            shared_key_i[j] = omega[j - 1]

        exponent = secret_input[0] + int(random_e) % (3910)
        H_i = Params.G ** exponent  # this is the equivalent of \tau
        return shares, shared_key_i, matrix_A_i_tmp, H_i

    def partial_eval(self, j, shares_from_client):
        self.partial_eval_values[j] = 0
        for i in range(1, Params.NR_CLIENTS + 1):
            self.partial_eval_values[j] = self.partial_eval_values[j] + shares_from_client[i]
        return self.partial_eval_values[j]

    def final_eval(self):
        final_eval = 0
        for j in range(1, Params.NR_SERVERS + 1):
            final_eval = final_eval + self.partial_eval_values[j]
        return final_eval

    def partial_proof(self, omegas, hash_Hs, matrix_As, N):
        print(" - partial_proof - ")
        for i in range(1, Params.NR_CLIENTS+1):
            self.partial_proof_value_sigma[i] = TSS.__partial_proof__(omegas[i], hash_Hs[i], matrix_As[i], N)
        print("self.partial_proof_value_sigma: {}".format(self.partial_proof_value_sigma))

    @staticmethod
    def __partial_proof__(omega, hash_H, matrix_A, N):
        matrix_a_s = matrix_A[0:Params.THRESHOLD, 0:Params.THRESHOLD]
        matrix_c_s_adjugate = adjugate(matrix_a_s, Params.THRESHOLD, Params.THRESHOLD)

        sigma_i = {}
        for j in range(1, Params.THRESHOLD + 1):
            tmp_val = matrix_c_s_adjugate[0][j - 1]
            print("tmp_val: {}".format(tmp_val))
            print("omega[j]: {}".format(omega[j]))
            exponent = int(2 * tmp_val * omega[j])
            print("exponent: {}".format(exponent))
            sigma_i[j] = pow(hash_H, exponent, N)
        
        return sigma_i

    def final_proof(self, public_keys, hash_Hs, matrix_As, N):
        print("public_keys: {}".format(public_keys))
        sigma_i = {}
        for i in range(1, Params.NR_CLIENTS+1):
            sigma_i[i] = TSS.__final_proof__(public_keys[i], hash_Hs[i], matrix_As[i], self.partial_proof_value_sigma[i], N)


        final_proof_value = 1
        for i in range(1, Params.NR_CLIENTS+1):
            print("public_keys[i]: {}".format(public_keys[i]))
            print("sigma_i[i]: {}".format(sigma_i[i]))
            final_proof_value = final_proof_value * pow(sigma_i[i], public_keys[i], N)
        print("final_proof_value: {}".format(final_proof_value))
        return final_proof_value

    @staticmethod
    def __final_proof__(public_key, hash_h, matrix_A, sigma, N):
        sigma_bar = 1
        for j in range(1, Params.THRESHOLD+1):
            sigma_bar = sigma_bar * sigma[j]
        sigma_bar = sigma_bar % N

        matrix_a_is = matrix_A[0:Params.THRESHOLD, 0:Params.THRESHOLD]
        detal_a_is = int(det(matrix_a_is))
        tmp = 2 * detal_a_is
        alpha, beta, _ = extended_euclidean_algorithm(tmp, public_key)
        print("alpha: {}".format(alpha))
        print("beta: {}".format(beta))
        print("rest: {}".format(_))

        sigma_tmp_1 = pow(sigma_bar, alpha, N)
        sigma_tmp_2 = pow(hash_h, beta, N)

        sigma = (sigma_tmp_1 * sigma_tmp_2) % N
        return sigma

    @staticmethod
    def verify(hash_Hs, sigma, y):
        prod = 1
        for i in range(1, Params.NR_CLIENTS+1):
            prod = prod * hash_Hs[i]

        prod = prod % 3911
        sigma = sigma 
        H_y = (int(Params.G) ** int(y)) % 3911

        print("y = {}".format(y))
        print("prod = {} == {}  ^  H_y = {} == {}".format(prod, sigma, H_y, prod))
        if (H_y == prod) and (prod == sigma):
            print("yeahhh")
            return 1, y
        else:
            return 0, y

