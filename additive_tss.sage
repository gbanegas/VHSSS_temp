import random
class  VHSS_TSS():

    def __init__(self):
        pass

    def setup(self, k_security, p,q,nr_clients,threshold):#threshold need to be smaller that the threshold t of the HSS.
        N = p*q #p,q need to be safe primes
        p_prime=(p-1)/2
        q_prime=(q-1)/2
        phi=(p-1)*(q-1)#in the paper it is p'*q' instead of 2*p'*q'
        lower_bound=binomial(nr_clients, threshold)
        e = random.randint(lower_bound,N)
        print("e: {}".format(e))
        d = inverse_mod(e, phi)
        pk = e
        sk = d
        return pk, sk

    def gen_secret_share_additive_with_threshold_ss(self):
        #TODO:
        pass

    def partial_eval(self):
        #TODO: all method
        pass

    def partial_proof(self):
        #TODO: all method
        pass

    def final_eval(self):
        #TODO: all method
        pass

    def final_proof(self):
        #TODO: all method
        pass

    def verify(self):
        #TODO: all method
        pass
