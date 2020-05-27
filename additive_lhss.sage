import random
load("vhss.sage")
load("hash.sage")

class LHSVHSSAdditive():

    def __init__(self):
        self.partialeval = {}
        self.partialproof = {}
        pass
    #updated setup
    def setup(self, k_security, N,nr_clients):
        p_hat_prime, q_hat_prime = generate_random_primes(k_security, N)
        self.p_hat=2*p_hat_prime+1#this is prime thanks to how generate_random_primes works
        self.q_hat=2*q_hat_prime+1#this is prime thanks to how generate_random_primes works
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

    #updated partial_proof
    #x_i_R is generated by the client, which is x_i + R_i
    def partial_proof(self, secret_key, verification_key, fid, x_i_R, i):
        """
        i: index of the client
        fid: Identifier of the dataset //to_check
        x_i_R: secret input of the client i + randomness from the client i 
        """
        e = H(fid, q)#q is the prime that define the field
        e_N = Integer(e)*Integer(verification_key[0])
        #s_i =mod(random.getrandbits(2048), e_N)#s_i need to be in Z_eN (not referred in the paper)
        s_i=3#this is to test temporarily
        right_hand_side=verification_key[2]^(s_i)*verification_key[4][i-1]*verification_key[3]^(x_i_R)
        phi =(secret_key[0]-1)*(secret_key[1]-1)
        print("e_N : {}, e: {}, verification_key: {}".format(e_N, e, verification_key[0]))
        inverse_e_N = inverse_mod(Integer(e_N), Integer(phi))#a^-1 mod phi
        x = right_hand_side^inverse_e_N
        sigma_temp=(e, s_i, fid, x)
        
        return sigma_temp #this is sigma_i of the pape



  #updated final_eval
    def final_eval(self,nr_servers):
        finaleval=0
        for j in range(1,nr_servers+1):
            finaleval=finaleval+int(self.partialeval[j])
        #print ("final eval is:",finaleval)
        return finaleval #this is y in the paper which corresponds to the sum of the secret inputs

    #updated final_proof
    #f_hat needs to be defined and f_hat=(1,...,1) and length is nr_clients
    #sigmas=(sigma_1,...,sigma_n) of the paper
    def final_proof(self, verification_key, sigmas, nr_clients):
        f_hat = [1]*nr_clients

        prod_partial_proofs=1
        for i in range(nr_clients+1):
            sigma_temp = sigmas[i-1] #sigma_temp = (e, s_i, fid, x)
            prod_partial_proofs=prod_partial_proofs*sigma_temp[3]#this is the product of x_i_tildes of the paper, indices are always 1 so no need to add exponent
        #this is to compute s_prime
        sum_s_i=0
        for i in range(nr_clients+1):
            sigma_temp = sigmas[i-1] #sigma_temp = (e, s_i, fid, x)
            sum_s_i=sum_s_i+sigma_temp[1]
        e_N = Integer(sigmas[0][0])*Integer(verification_key[0]) #e*N sigmas[0][0] is basically e
        
        s=(sum_s_i).mod(e_N)
        print("sum_s_i : {} , sigmas[0][0]: {}, verification_key[0]: {}, e_N: {}, s: {}".format(sum_s_i, sigmas[0][0], verification_key[0], e_N, s))
        s_prime=Integer(sum_s_i-s)/Integer(e_N)
        #until here is to compute s_prime
        #prod_hj_to_fj_pr=1
        #for i in range(nr_clients+1):
            #sigma_temp = sigmas[i-1] #sigma_temp = (e, s_i, fid, x)
            #prod_hj_to_fj_pr=prod_hj_to_fj_pr*(verification_key[4][i-1]^f_j_pr), we removed it because it is 0 in this case
        low_part = (verification_key[2]^s_prime)#*prod_hj_to_fj_pr
        #low_part=1
        x_tilda = (prod_partial_proofs/low_part).mod(verification_key[1])
        finalproof = (sigmas[0][0], s, sigmas[0][2], x_tilda) #sigma_temp[2]=fid
        
        return finalproof #this is sigma in the paper

      
    #updated verify
    def verify(self,verification_key, finalproof, y):
        print("finalproof[0]: {}, verification_key[0] : {}".format(finalproof[0], verification_key[0]))
        e_N = Integer(finalproof[0])*Integer(verification_key[0]) #e*N #finalproof[0] is basically e
        x_tilde=finalproof[3]
        prod_hj = 1
        for j in range(len(verification_key[4])):
            prod_hj = prod_hj*verification_key[4][j]#product of h_js
        right_part = (verification_key[2]^finalproof[1])*prod_hj*(verification_key[3]^y)
        left_part=x_tilde^(e_N)

        print("right_part: {}  - left_part: {}".format(right_part, left_part))
        if left_part == right_part:
            print("Yey!")
            return y
        else:
            print("Nay :(")
            return 0
def test():
    return "test"