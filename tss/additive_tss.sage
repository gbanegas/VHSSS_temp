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
        N_prime = 2*q_prime*p_prime#this is just used by us to compute e.
        lower_bound=binomial(nr_clients, threshold)
        e = Integer(random.randint(lower_bound,N_prime))
        while gcd(e, N_prime) != 1:
              e = random.randint(lower_bound,N_prime)
        d = inverse_mod(e, N_prime)
        pk = e
        sk = d
        return pk, sk

    def gen_secret_share_additive_with_threshold_ss(self, i, x_i, t, d_i, R_i, nr_servers, threshold, N, g, public_key_i):
    #we add the e_i as input to be able to check that (public_key_i, det(A_i))=1.
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
        evaluation_theta, lambda_ijs, pre_computed_products  = generate_points(polynomial_i, nr_servers)
        shares = pre_computed_products #These are the shares of x_i

        A_i_tmp = random_matrix(FIELD, nr_servers, threshold, algorithm='echelonizable', rank=threshold) #create a random matrix with full rank
        A_i = matrix(nr_servers, threshold) #Create a zero matrix
        for i in range(0,nr_servers):
              for j in range(0,threshold):
                  A_i[i,j] = Integer(A_i_tmp[i][j])          
        A_iS = A_i[0:threshold, 0:threshold] #this is to create the \hat(t)x\hat(t) submatrix of A_i
        delta_A_iS = A_iS.determinant()#this is to compute the det of A_iS
        tmp = 2*delta_A_iS
        gcd_pk_i_delta_AiS = gcd(tmp, public_key_i)
      
        while( gcd_pk_i_delta_AiS != 1):#we make sure they are coprime before we go on.
            A_i_tmp = random_matrix(FIELD, nr_servers, threshold, algorithm='echelonizable', rank=threshold)
            for i in range(0,nr_servers):
              for j in range(0,threshold):
                  A_i[i,j] = Integer(A_i_tmp[i][j])
            A_iS = A_i[0:threshold, 0:threshold] #this is to create the \hat(t)x\hat(t) submatrix of A_i
            delta_A_iS = A_iS.determinant()#this is to compute the det of A_iS
            tmp = 2*delta_A_iS
            gcd_pk_i_delta_AiS = gcd(tmp, public_key_i)
        
        
        print("gcd_pk_i_delta_AiS {}".format(gcd_pk_i_delta_AiS))
        print ("A_iS : {}".format(A_iS))

        
        
        #A_i= A_i[0:threshold, 0:threshold]
        print ("A_i : {}".format(A_i))
        vec_d_tmp = random_vector(FIELD, threshold)
        l = [0]*threshold
        for i in range(0,threshold):
            l[i] = Integer(vec_d_tmp[i])
        l[0] = d_i #because d=(d_i,r_2,..,r_\hat(t))
        vec_d = vector(l)

        omega = A_i*vec_d #this gives us a vector omega=(shared_key_1,...,shared_key_m)

        shared_key_i = {}
        for j in range(1, nr_servers+1):
            shared_key_i[j]=omega[j-1]
        #now shared_key is a list of the shares of the d_i that will be given to the m servers

        exponent = x_i[0] + int(R_i)
        H_i = FIELD(g^(exponent)) #this is the equivalent of \tau


        return shares, shared_key_i, A_i, H_i



    def partial_eval(self, j, shares_from_clients, nr_clients):
        #print("shares_from_clients: {}".format(shares_from_clients))
        self.partialeval[j] = 0
        # print("shares_from_clients: {}".format(shares_from_clients))
        for i in range(1,nr_clients+1):
            #print("shares_from_the_clients[i] : {}".format(shares_from_the_clients[i]))
            self.partialeval[j]=self.partialeval[j]+shares_from_clients[i]

        return self.partialeval[j] #this is y_j of the paper


    def __partial_proof_i(self, shared_key_i, H_i, A_i, N,threshold, public_key_i):#shared_key_i is the list of the m shares of the secret key of each client i
        A_iS= A_i[0:threshold, 0:threshold] #this is to create the \hat(t)x\hat(t) submatrix of A_i
        C_iS_adjugate = A_iS.adjugate()
        sigma_i={}
        for j in range(1,threshold+1):
            exponent = 2*C_iS_adjugate[j-1][0]*shared_key_i[j]
            tmp = Integer(H_i).powermod(exponent, N)

            sigma_i[j]=(tmp).mod(N)
        ######### this section is for testing
        #we have added public_key_i as input which is not normally necessary
        sigma_bar = 1
        for sigma in sigma_i.values():
            sigma_bar = sigma_bar*sigma
        delta_A_iS = A_iS.determinant()
        tmp = 2*delta_A_iS
      
        print("sigma_bar: {} - delta_A_iS: {}".format(sigma_bar, delta_A_iS))
        lala ,alpha,beta = xgcd(tmp, public_key_i)
        result_tmp = sigma_bar.powermod(alpha,N) 
        print("result_tmp 1 : {}".format(result_tmp))
        result_tmp = result_tmp * Integer(H_i).powermod(beta, N)
        print("result_tmp 2 : {}".format(result_tmp))
        result_tmp=(result_tmp).mod(N)
        print("result_tmp 3 : {}".format(result_tmp))
        print("result_tmp : {} - {}".format(result_tmp, sigma_i))
        
        ######### this section is for testing
        return sigma_i  #this is the partial proof that the coalition of the servers produce for each client i


    def partial_proof(self, omegas, H_is, A_is, N, threshold,nr_clients, public_keys):
        for i in range(1, nr_clients+1):
            self.partialproof[i] = self.__partial_proof_i(omegas[i], H_is[i], A_is[i], N, threshold, public_keys[i])
        return self.partialproof

    def final_eval(self,nr_servers):
        finaleval=0
        for j in range(1,nr_servers+1):
            finaleval=finaleval+self.partialeval[j]
        return finaleval #this is y in the paper which corresponds to the sum of the secret inputs


    def __final_proof_i(self, public_key_i, H_i, sigma_i, A_i, N,threshold):
        bar_sigma_i = 1
        for j in range(1,threshold+1):
            bar_sigma_i = bar_sigma_i*sigma_i[j]
        bar_sigma_i=(bar_sigma_i).mod(N)
        A_iS= A_i[0:threshold, 0:threshold] #this is to create the \hat(t)x\hat(t) submatrix of A_i
        delta_A_iS = A_iS.determinant()

        tmp = 2*delta_A_iS
        lala ,alpha,beta = xgcd(tmp, public_key_i)
        
        test=tmp*alpha+beta*public_key_i
        print("test: {} - lala: {} -  alpha : {} -  beta: {}".format(test,lala,alpha, beta))


        tmp_1 = bar_sigma_i.powermod(alpha, N)

        tmp_2 = Integer(H_i).powermod(beta, N)

        final_sigma_i=(tmp_1)*(tmp_2)

        tmp=Integer(final_sigma_i)
        final_sigma_i=(tmp).mod(N)
        return final_sigma_i


    def final_proof(self, public_keys, H_is, A_is, sigmas, threshold, N):
        final_proof = {}
        for i in range(1, nr_clients+1):
            final_proof[i] = self.__final_proof_i(public_keys[i], H_is[i], sigmas[i], A_is[i], N, threshold)

        final_p = 1;
        for i in range(1, nr_clients+1):
            #final_p = final_p * (final_proof[i].powermod(public_keys[i],N))
            tmp = Integer(final_proof[i])
            tmp = tmp.powermod(public_keys[i], N)
            #tmp=(tmp^public_keys[i])
            final_p = (final_p * tmp).mod(N)
        #final_p = final_p.mod(N)
        final_p = FIELD(final_p)
        return final_p


    def verify(self, nr_clients, H_is, final_p, finaleval):
        prod=1
        for i in range(1,nr_clients+1):
            prod=prod*H_is[i]
        H_y = g^finaleval
        print("prod = {} == {}  ^  H_y = {} == {}".format(prod, final_p, H_y, prod))
        if (H_y==prod) and (prod==final_p):
            print("yeahhh")
            return 1
        else:
            return 0
