load("vhss.sage")

class LHSVHSSAdditive():

    def __init__(self):
        self.partialeval = {}
        self.partialproof = {}
        pass
    
    def setup(self, k_security, N,nr_clients):
        self.p_hat, self.q_hat = generate_random_primes(k_security, N)
        self.n_hat = self.p_hat*self.q_hat
        secret_key = (self.p_hat, self.q_hat)
        g=random_Z_star(N)
        g_1=random_Z_star(N)
        h=[]#list denoted by []
        for i in range (1,nr_clients+1):
            h.append(random_Z_star(N))
        verification_key = (N,self.n_hat,g,g_1,h)
        print ("secret key: {}".format(secret_key))
        print ("verification key: {}".format(verification_key))
        return secret_key, verification_key

     #updated gen_secret_share
    def gen_secret_share_additive_with_linear_hom_sign(self, i, x_i, t, nr_servers, g): # initiated as none will be none unless otherwise specified
        """
        i: index of the client
        x_i: secret input of the client i
        t: threshold (t + 1 reconstruct)
        nr_servers: Number of servers
        """
        shares = {}
        #tau_i = None
        polynomial_i = generate_random_polynomial(x_i, t)
        print("Polynomial: ", polynomial_i)
        evaluation_theta, lambda_ijs, pre_computed_products  = generate_points(polynomial_i, nr_servers)
        print("evaluation_theta: {},  lambda_ijs: {}, pre_computed_shares: {}".format(evaluation_theta, lambda_ijs, pre_computed_products))
        #print(evaluation_theta)
        #print(lambda_ijs)
        shares = pre_computed_products
        #exponent = x_i[0] + int(R_i)
        #print("exponent: {}".format(exponent))
        #tau_i = FIELD(g^(exponent))
        return shares#, tau_i

    #updated partial_eval
    def partial_eval(self,j, shares_from_the_clients, nr_clients):
        self.partialeval[j]=0
        for i in range(1,nr_clients+1):
            self.partialeval[j]=self.partialeval[j]+shares_from_the_clients[i]
        #print ("partial eval is:",self.partialeval[j])
        return self.partialeval[j] #this is y_j of the paper


    def partial_proof(self,j, shares_from_the_clients,g, nr_clients):
        #y_j=self.partialeval[j] #I don't need it as input because it's "self." defined
        y_j = 0
        for i in range(1,nr_clients+1):
            y_j = y_j + shares_from_the_clients[i]
        sigma_temp = g^y_j


        self.partialproof[j] = sigma_temp
        #print("Server j: {} - y_{} = {} proof = {}".format(j,j,y_j, self.partialproof[j]))
        #print ("partial proof is:", self.partialproof)
        return sigma_temp #this is sigma_j of the paper

  #updated final_eval
    def final_eval(self,nr_servers):
        finaleval=0
        for j in range(1,nr_servers+1):
            finaleval=finaleval+int(self.partialeval[j])
        #print ("final eval is:",finaleval)
        return finaleval #this is y in the paper which coirresponds to the sum of the secret inputs


    def final_proof(self, nr_servers, g):
        finalproof=1
        for j in range(1, nr_servers+1):
            finalproof = finalproof*self.partialproof[j]

        #for j in range(1,nr_servers+1):
        #    finalproof=int(finalproof)*int(self.partialproof[j])
        #print ("final proof is:",finalproof)
        #finalproof = g^finaleval
        return finalproof #this is sigma in the paper

    def verify(self,tau_is,nr_clients,sigma,y):
        #PROD needs to be computed without the field and then reduced to the field
        prod=1
        for i in range(1,nr_clients+1):
            prod=prod*tau_is[i]
        print("prod: {}".format((prod)))
        y_mod = FIELD(y)


        hash_y = FIELD(g^((y)))
        hash_y_mod = FIELD(g^y_mod)

        print("hash_y: {}".format(hash_y))
        if ((sigma==FIELD(hash_y)) and (FIELD(prod)==hash_y_mod)):#Georgia doesn't agree with me but it is same comparison
            print (Color.B_Green,"Sum is correctly computed and equal to:",FIELD(y), Color.B_Default)
            return 1
        else:
            print (Color.B_Red,"Fail, oups", Color.B_Default)
            return 0
