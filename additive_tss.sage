import random
class  VHSS_TSS():

    def __init__(self):
        pass

    def setup(self, k_security, p,q,nr_clients,threshold):#threshold need to be smaller that the threshold t of the HSS.
        N = p*q #p,q need to be safe primes
        p_prime=(p-1)/2
        q_prime=(q-1)/2
        phi_N=(p-1)*(q-1)#(p-1)(q-1)=2p'*2q'=4p'q'in the paper it is p'*q' instead of 2*p'*q'
        N_prime = q_prime*p_prime#this is just used by us to compute e.
        lower_bound=binomial(nr_clients, threshold)
        e = random.randint(lower_bound,N_prime)
        print("e: {}".format(e))
        d = inverse_mod(e, N_prime)
        pk = e
        sk = d
        return pk, sk

    def gen_secret_share_additive_with_threshold_ss(self, i, x_i, t, d_i, R_i, nr_servers, threshold, g):"""
        i: index of the client
        x_i: secret input of the client i
        d_i: secret key of client i
        R_i: is such that R_i=PRG(i,file_i) which will be given I guess
        nr_servers: threshold t for the number of shares
        threshold: the one used at the setup
        """
        shares = {}
        H_i = None
        polynomial_i = generate_random_polynomial(x_i, t)
        print("Polynomial: ", polynomial_i)
        evaluation_theta, lambda_ijs, pre_computed_products  = generate_points(polynomial_i, nr_servers)
        print("evaluation_theta: {},  lambda_ijs: {}, pre_computed_shares: {}".format(evaluation_theta, lambda_ijs, pre_computed_products))
        shares = pre_computed_products #These are the shares of x_i 
 
        A_i = random_matrix(FIELD, nr_servers, threshold, algorithm='echelonizable', rank=nr_servers)

        vec_d = random_vector(FIELD, threshold)
        vec_d[0] = FIELD(d_i) #because d=(d_i,r_2,..,r_\hat(t))

        omega = A_i*vec_d #this gives us a vector omega=(shared_key_1,...,shared_key_m)
        shared_key = {}
        for j in range(1, nr_servers+1):
            shared_key[j]=omega[j-1]
        #now shared_key is a list of the shares of the d_i that will be given to the m servers

        exponent = x_i[0] + int(R_i)
        print("exponent: {}".format(exponent))
        H_i = FIELD(g^(exponent)) #this is the equivalent of \tau

        
        return shares, shared_key, A_i, H_i
       
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
