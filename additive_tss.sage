import random
class  VHSS_TSS():

    def __init__(self):
        self.partialeval = {}
        self.partialproof = {}
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

    def gen_secret_share_additive_with_threshold_ss(self, i, x_i, t, d_i, R_i, nr_servers, threshold, g):
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
        polynomial_i = generate_random_polynomial(x_i, t)
        print("Polynomial: ", polynomial_i)
        evaluation_theta, lambda_ijs, pre_computed_products  = generate_points(polynomial_i, nr_servers)
        print("evaluation_theta: {},  lambda_ijs: {}, pre_computed_shares: {}".format(evaluation_theta, lambda_ijs, pre_computed_products))
        shares = pre_computed_products #These are the shares of x_i 
 
        A_i = random_matrix(FIELD, nr_servers, threshold, algorithm='echelonizable', rank=threshold)

        vec_d = random_vector(FIELD, threshold)
        vec_d[0] = FIELD(d_i) #because d=(d_i,r_2,..,r_\hat(t))

        omega = A_i*vec_d #this gives us a vector omega=(shared_key_1,...,shared_key_m)
        shared_key_i = {}
        for j in range(1, nr_servers+1):
            shared_key_i[j]=omega[j-1]
        #now shared_key is a list of the shares of the d_i that will be given to the m servers

        exponent = x_i[0] + int(R_i)
        print("exponent: {}".format(exponent))
        H_i = FIELD(g^(exponent)) #this is the equivalent of \tau

        
        return shares, shared_key_i, A_i, H_i
    
    

    def partial_eval(self, j, shares_from_clients, nr_clients):
        self.partial_eval[j] = 0
        for i in range(1,nr_clients+1):
            self.partialeval[j]=self.partialeval[j]+Integer(shares_from_the_clients[i])
        
        return self.partialeval[j] #this is y_j of the paper
        

    def __partial_proof_i(self, shared_key_i, H_i, A_i, N,threshold):#shared_key_i is the list of the m shares of the secret key of each client i 
        A_iS= A_i[0:threshold, 0:threshold] #this is to create the \hat(t)x\hat(t) submatrix of A_i
        C_iS_adjugate = A_iS.adjugate()
        sigma_i={}
        print("C_adjugate: {} ".format(C_iS_adjugate))
        for j in range(1,threshold+1):
            print("j: {} ".format(j))
            tmp = Integer(H_i^(2*C_iS_adjugate[j-1][0]*shared_key_i[j]))
            print("tmp: {} - type: {} - N: {}".format(tmp, type(tmp), N))

            sigma_i[j]=(tmp).mod(N)
        print("sigma_i: {}".format(sigma_i))
        return sigma_i  #this is the partial proof that the coalition of the servers produce for each client i 
      

    def partial_proof(self, omegas, H_is, A_is, N, threshold,nr_clients):
        for i in range(1, nr_clients+1):
            self.partialproof[i] = self.__partial_proof_i(omegas[i], H_is[i], A_is[i], N, threshold)
        return self.partialproof

    def final_eval(self,nr_servers):
        finaleval=0
        for j in range(1,nr_servers+1):
            finaleval=finaleval+Integer(self.partialeval[j])
        return finaleval #this is y in the paper which corresponds to the sum of the secret inputs
        
  
    def __final_proof_i(self, public_key_i, H_i, sigma_i, A_i, N,threshold):
        bar_sigma_i = 1
        for j in range(1,threshold+1):
            bar_sigma_i = bar_sigma_i*sigma_i[j]
        bar_sigma_i=(bar_sigma_i).mod(N)
        A_iS= A_i[0:threshold, 0:threshold] #this is to create the \hat(t)x\hat(t) submatrix of A_i
        delta_A_iS = A_iS.determinant()
        tmp = 2*delta_A_iS
        _ , alpha, beta = xgcd(tmp, public_key_i)
        final_sigma_i=(bar_sigma_i^alpha)*(H_i^beta)
        final_sigma_i=(final_sigma_i).mod(N)
        return final_sigma_i


    def final_proof(self, public_keys, H_is, A_is, sigmas, threshold, N):
        final_proof = {}
        for i in range(1, nr_clients+1):
            final_proof[i] = self.__final_proof_i(public_keys[i], H_is[i], sigmas[i], A_is[i], N, threshold)

        final_p = 1;
        for i in range(1, nr_clients+1):
            final_p = final_p * (Integer(final_proof[i]).powermod(public_keys[i], N))
        return final_p    
    

    def verify(self):
        #TODO: all method
        pass
