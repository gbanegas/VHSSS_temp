from arithmetic.utils import *
from arithmetic.modp import *
from shamir_secre_sharing.wrapper import *


class VHSSAdditive(object):

    def __init__(self, modQ):
        self.partialeval = {}
        self.partialproof = {}
        self.modQ = modQ
        pass

    def gen_secret_share_additive_with_hash_functions(self, i, x_i, t, nr_servers, R_i, g):  # initiated as none will be none unless otherwise specified
        """
        i: index of the client
        x_i: secret input of the client i
        t: threshold (t + 1 reconstruct)
        nr_servers: Number of servers
        """
        tau_i = None
        prime = int(self.modQ.p)
        shares = Protocol.generate_input_shamir_secret(x_i[0], t, nr_servers, prime)
        exponent = x_i[0] + R_i
        print("exponent: {}".format(exponent))
        tau_i = g ** exponent
        return shares, tau_i

    def partial_eval(self, j, shares_from_the_clients, nr_clients):
        self.partialeval[j] = 0
        for i in range(1, nr_clients + 1):
            self.partialeval[j] = self.partialeval[j] + shares_from_the_clients[i]
        # print ("partial eval is:",self.partialeval[j])
        return self.partialeval[j]  # this is y_j of the paper

    def partial_proof(self, j, shares_from_the_clients, g, nr_clients):
        # y_j=self.partialeval[j] #I don't need it as input because it's "self." defined
        y_j = 0
        for i in range(1, nr_clients + 1):
            y_j = y_j + shares_from_the_clients[i]
        sigma_temp = g ** int(y_j)

        self.partialproof[j] = sigma_temp
        # print("Server j: {} - y_{} = {} proof = {}".format(j,j,y_j, self.partialproof[j]))
        # print ("partial proof is:", self.partialproof)
        return sigma_temp  # this is sigma_j of the paper

    def final_eval(self, nr_servers):
        finaleval = 0
        for j in range(1, nr_servers + 1):
            finaleval = finaleval + int(self.partialeval[j])
        # print ("final eval is:",finaleval)
        return finaleval  # this is y in the paper which coirresponds to the sum of the secret inputs

    def final_proof(self, nr_servers, g):
        finalproof = 1
        for j in range(1, nr_servers + 1):
            finalproof = finalproof * self.partialproof[j]
        return finalproof  # this is sigma in the paper

    def verify(self, tau_is, nr_clients, sigma, y, g):
        # PROD needs to be computed without the field and then reduced to the field
        prod = int(1)
        for i in range(1, nr_clients + 1):
            prod = prod * int(tau_is[i])

        y_mod = self.modQ(y)
        sigma = sigma % self.modQ.p

        hash_y = int(g) ** int(y) % self.modQ.p
        hash_y_mod = g ** int(y_mod) % self.modQ.p

        if ((sigma == hash_y) and (
                self.modQ(prod) == hash_y_mod)):  # Georgia doesn't agree with me but it is same comparison
            print(Color.B_Green, "Sum is correctly computed and equal to:", self.modQ(y), Color.B_Default)
            return 1
        else:
            print(Color.B_Red, "Fail, oups", Color.B_Default)
            return 0
