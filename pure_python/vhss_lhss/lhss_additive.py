import sympy
from arithmetic.utils import *
from arithmetic.modp import *
from shamir_secre_sharing.wrapper import *


def H(element, prime):
    L = IntegersModP(prime)
    g = L(3)
    temp = g**element
    is_nr_prime = sympy.isprime(int(temp))
    while not is_nr_prime or temp == 2:
        element = element+1
        temp = g ** element
        is_nr_prime = sympy.isprime(int(temp))
        #print ("temp is {} - and is_nr_prime {}".format(temp, is_nr_prime))
    return temp


def random_Z_star(N):
    modR = IntegersModP(N)
    r = random_element(modR)
    while sympy.gcd(r, N) != 1 and (r == 0):
        r = random_element(modR)
    return int(r)


class LHSSAdditive(object):

    def __init__(self, modQ):
        self.partialeval = {}
        self.partialproof = {}
        self.modQ = modQ
        pass

    def setup(self, k_security, N, nr_clients):
        p_hat_prime, q_hat_prime = generate_random_primes(k_security, N)
        self.p_hat = 2 * p_hat_prime + 1  # this is prime thanks to how generate_random_primes works
        self.q_hat = 2 * q_hat_prime + 1  # this is prime thanks to how generate_random_primes works
        self.n_hat = self.p_hat * self.q_hat
        secret_key = (self.p_hat, self.q_hat)
        g = random_Z_star(self.n_hat)
        g_1 = random_Z_star(self.n_hat)
        h = []  # list denoted by []
        for i in range(1, nr_clients + 1):
            h.append(random_Z_star(self.n_hat))
        verification_key = (N, self.n_hat, g, g_1, h)
        print("secret key: {}".format(secret_key))
        print("verification key: {}".format(verification_key))
        return secret_key, verification_key

    def gen_secret_share_additive_with_linear_hom_sign(self, i, x_i, t, nr_servers, g):
        """
                i: index of the client
                x_i: secret input of the client i
                t: threshold (t + 1 reconstruct)
                nr_servers: Number of servers
                """
        shares = Protocol.generate_input_shamir_secret(x_i[0], t, nr_servers, self.modQ.p)
        return shares

    def partial_eval(self, j, shares_from_the_clients, nr_clients):
        self.partialeval[j]=0
        for i in range(1,nr_clients+1):
            self.partialeval[j]=self.partialeval[j]+int(shares_from_the_clients[i])
        #print ("partial eval is:",self.partialeval[j])
        return self.partialeval[j] #this is y_j of the paper

    def partial_proof(self, secret_key, verification_key, fid, x_i_R, i, q):
        """
        i: index of the client
        fid: Identifier of the dataset //to_check
        x_i_R: secret input of the client i + randomness from the client i
        """
        e = H(fid, q)  # q is the prime that define the field
        e_N = int(e) * int(verification_key[0])
        s_i = random.getrandbits(2048) % e_N  # s_i need to be in Z_eN (not referred in the paper)
        n_hat = int(verification_key[1])
        g = int(verification_key[2])
        g1 = int(verification_key[3])
        s_i_pow = pow(g, s_i, n_hat)  #g.powermod(s_i, n_hat)

        g1_pow = pow(g1, x_i_R, n_hat)# g1.powermod(x_i_R, n_hat)
        hi = int(verification_key[4][i - 1])
        phi = (secret_key[0] - 1) * (secret_key[1] - 1)

        right_hand_side = (s_i_pow * g1_pow) % n_hat
        right_hand_side = (hi * right_hand_side) % n_hat

        inverse_e_N = mod_inverse(int(e_N), int(phi))  # a^-1 mod phi
        x = pow(right_hand_side, inverse_e_N, n_hat)
        #x = right_hand_side.powermod(inverse_e_N, n_hat)
        # print("n_hat = {} - x = {} - e_N = {}  - right_hand_side = {} - phi =  {} - g = {} - hi = {} - g1 = {} - si = {} - x_i_r = {} - g1_pow = {}".format(n_hat, x, e_N, right_hand_side, phi,g,hi,g1, s_i, x_i_R, g1_pow))
        sigma_temp = (e, s_i, fid, x)
        return sigma_temp  # this is sigma_i of the pape

    def final_eval(self, nr_servers):
        finaleval = 0
        for j in range(1, nr_servers + 1):
            finaleval = finaleval + int(self.partialeval[j])
        # print ("final eval is:",finaleval)
        return finaleval

    def final_proof(self, verification_key, sigmas, nr_clients, q):
        f_hat = [1] * nr_clients
        fid = sigmas[0][2]
        e = H(fid, q)  # q is the prime that define the field

        e_N = int(e) * int(verification_key[0])

        n_hat = int(verification_key[1])
        g = int(verification_key[2])
        g1 = int(verification_key[3])
        R = IntegersModP(n_hat)

        prod_partial_proofs = 1
        for i in range(1, nr_clients + 1):
            sigma_temp = sigmas[i - 1]  # sigma_temp = (e, s_i, fid, x)
            prod_partial_proofs = R(prod_partial_proofs) * R(sigma_temp[3])  # this is the product of x_i_tildes of the paper, indices are always 1 so no need to add exponent
        # this is to compute s_prime
        sum_s_i = 0
        for i in range(1, nr_clients + 1):
            sigma_temp = sigmas[i - 1]  # sigma_temp = (e, s_i, fid, x)
            sum_s_i = sum_s_i + int(sigma_temp[1])

        s = sum_s_i % e_N
        # print("sum_s_i : {} , s: {}".format(sum_s_i, s))
        tmp = sum_s_i - s;

        s_prime = R(tmp) / R(e_N)

        # print("tmp: {} - s_prime: {} ".format(tmp, s_prime))

        low_part = R(pow(g, int(s_prime), n_hat))# R(g.powermod(s_prime, n_hat))
        # low_part=1

        x_tilda = int(prod_partial_proofs / low_part) % n_hat
        finalproof = (e, s, fid, x_tilda)  # sigma_temp[2]=fid

        return finalproof  # this is sigma in the paper

    # updated verify
    def verify(self, verification_key, finalproof, final_eval, q):
        # print("e: {}, N: {}".format(finalproof[0], verification_key[0]))
        e_N = int(finalproof[0]) * int(verification_key[0])  # e*N #finalproof[0] is basically e
        n_hat = int(verification_key[1])
        g = int(verification_key[2])
        g1 = int(verification_key[3])
        s = int(finalproof[1])
        x_tilda = int(finalproof[3])
        y_m = int(final_eval) % q
        prod_hj = 1

        for j in range(len(verification_key[4])):
            prod_hj = prod_hj * int(verification_key[4][j])  # product of h_js

        # print(y_m)

        g_power_s = pow(g, s, n_hat) #g.powermod(s, n_hat)
        g1_power_y = pow(g1, y_m, n_hat)#g1.powermod(y_m, n_hat);

        right_part = (g_power_s * prod_hj * g1_power_y) %n_hat

        # print("s: {} - g_power: {} - y: {} - g1_power_y:{}  - prod_hj: {} - right_part: {}".format(s, g_power_s, y_m,g1_power_y, prod_hj, right_part))

        left_part = pow(x_tilda, e_N, n_hat) #x_tilda.powermod(e_N, n_hat)
        # x_tilda^(e_N)
        #    print("x_tilda: {} - left_part: {}".format(x_tilda,left_part) )

        # print("right_part: {}  - left_part: {}".format(right_part, left_part))
        if left_part == right_part:
            print("Yey!")
            return y_m
        else:
            print("Nay :(")
            return 0

