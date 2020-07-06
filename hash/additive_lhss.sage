import random
load("shamir_secret.sage")
load("hash.sage")

class LHSVHSSAdditive():

    def __init__(self):
        self.partialeval = {}
        self.partialproof = {}
        pass
    #updated setup
    def setup(self, k_security, N,nr_clients):
        p_hat_prime, q_hat_prime = generate_random_primes(k_security, N)
        #self.p_hat = p_hat_prime
        #self.q_hat = q_hat_prime
        self.p_hat=2*p_hat_prime+1#this is prime thanks to how generate_random_primes works
        self.q_hat=2*q_hat_prime+1#this is prime thanks to how generate_random_primes works
        self.n_hat = self.p_hat*self.q_hat
        secret_key = (self.p_hat, self.q_hat)
        g=random_Z_star(self.n_hat)
        g_1=random_Z_star(self.n_hat)
        h=[]#list denoted by []
        for i in range (1,nr_clients+1):
            h.append(random_Z_star(self.n_hat))
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
        polynomial_i = generate_random_polynomial(x_i, t)
        #print("Polynomial: ", polynomial_i)
        evaluation_theta, lambda_ijs, shares  = generate_points(polynomial_i, nr_servers)
        #print("evaluation_theta: {},  lambda_ijs: {}, shares: {}".format(evaluation_theta, lambda_ijs, shares))
        #shares = pre_computed_products
        return shares#, tau_i


    def partial_eval(self, j, shares_from_the_clients, nr_clients):
        self.partialeval[j]=0
        for i in range(1,nr_clients+1):
            self.partialeval[j]=self.partialeval[j]+Integer(shares_from_the_clients[i])
        #print ("partial eval is:",self.partialeval[j])
        return self.partialeval[j] #this is y_j of the paper


    def partial_proof(self, secret_key, verification_key, fid, x_i_R, i):
        """
        i: index of the client
        fid: Identifier of the dataset //to_check
        x_i_R: secret input of the client i + randomness from the client i
        """
        e = H(fid, q)#q is the prime that define the field
        e_N = Integer(e)*Integer(verification_key[0])
        s_i =mod(random.getrandbits(2048), e_N)#s_i need to be in Z_eN (not referred in the paper)
        n_hat = Integer(verification_key[1])
        g = Integer(verification_key[2])
        g1 = Integer(verification_key[3])
        s_i_pow =g.powermod(s_i, n_hat)
        g1_pow = g1.powermod(x_i_R, n_hat)
        hi = Integer(verification_key[4][i-1])
        phi =(secret_key[0]-1)*(secret_key[1]-1)

        right_hand_side = (s_i_pow*g1_pow).mod(n_hat)
        right_hand_side = (hi*right_hand_side).mod(n_hat)

        inverse_e_N = inverse_mod(Integer(e_N), Integer(phi))#a^-1 mod phi
        x = right_hand_side.powermod(inverse_e_N, n_hat)
        #print("n_hat = {} - x = {} - e_N = {}  - right_hand_side = {} - phi =  {} - g = {} - hi = {} - g1 = {} - si = {} - x_i_r = {} - g1_pow = {}".format(n_hat, x, e_N, right_hand_side, phi,g,hi,g1, s_i, x_i_R, g1_pow))
        sigma_temp=(e, s_i, fid, x)
        return sigma_temp #this is sigma_i of the pape



  #updated final_eval
    def final_eval(self,nr_servers):
        finaleval=0
        for j in range(1,nr_servers+1):
            finaleval=finaleval+Integer(self.partialeval[j])
        #print ("final eval is:",finaleval)
        return finaleval #this is y in the paper which corresponds to the sum of the secret inputs

    #updated final_proof
    #f_hat needs to be defined and f_hat=(1,...,1) and length is nr_clients
    #sigmas=(sigma_1,...,sigma_n) of the paper
    def final_proof(self, verification_key, sigmas, nr_clients):
        f_hat = [1]*nr_clients
        fid = sigmas[0][2]
        e = H(fid, q)#q is the prime that define the field

        e_N = Integer(e)*Integer(verification_key[0])

        n_hat = Integer(verification_key[1])
        g = Integer(verification_key[2])
        g1 = Integer(verification_key[3])
        R = Integers(n_hat)

        prod_partial_proofs=1
        for i in range(1,nr_clients+1):
            sigma_temp = sigmas[i-1] #sigma_temp = (e, s_i, fid, x)
            prod_partial_proofs=R(prod_partial_proofs)*R(sigma_temp[3])#this is the product of x_i_tildes of the paper, indices are always 1 so no need to add exponent
        #this is to compute s_prime
        sum_s_i=0
        for i in range(1, nr_clients+1):
            sigma_temp = sigmas[i-1] #sigma_temp = (e, s_i, fid, x)
            sum_s_i=sum_s_i+Integer(sigma_temp[1])


        s=(sum_s_i).mod(e_N)
        #print("sum_s_i : {} , s: {}".format(sum_s_i, s))
        tmp = sum_s_i-s;

        s_prime=R(tmp)/R(e_N)

        #print("tmp: {} - s_prime: {} ".format(tmp, s_prime))

        low_part = R(g.powermod(s_prime, n_hat))
        #low_part=1
        x_tilda = (prod_partial_proofs/low_part).mod(n_hat)
        finalproof = (e, s, fid, x_tilda) #sigma_temp[2]=fid

        return finalproof #this is sigma in the paper


    #updated verify
    def verify(self,verification_key, finalproof, final_eval, q):
        #print("e: {}, N: {}".format(finalproof[0], verification_key[0]))
        e_N = Integer(finalproof[0])*Integer(verification_key[0]) #e*N #finalproof[0] is basically e
        n_hat = Integer(verification_key[1])
        g = Integer(verification_key[2])
        g1 = Integer(verification_key[3])
        s =Integer(finalproof[1])
        x_tilda= Integer(finalproof[3])
        y_m = Integer(final_eval).mod(3911)
        prod_hj = 1

        for j in range(len(verification_key[4])):
            prod_hj = prod_hj*Integer(verification_key[4][j])#product of h_js

        #print(y_m)

        g_power_s = g.powermod(s, n_hat)
        g1_power_y = g1.powermod(y_m, n_hat);
        

        right_part = (g_power_s*prod_hj*g1_power_y).mod(n_hat)

        #print("s: {} - g_power: {} - y: {} - g1_power_y:{}  - prod_hj: {} - right_part: {}".format(s, g_power_s, y_m,g1_power_y, prod_hj, right_part))

        left_part=x_tilda.powermod(e_N, n_hat)
        #x_tilda^(e_N)
    #    print("x_tilda: {} - left_part: {}".format(x_tilda,left_part) )

        #print("right_part: {}  - left_part: {}".format(right_part, left_part))
        if left_part == right_part:
            print("Yey!")
            return y_m
        else:
            print("Nay :(")
            return 0
