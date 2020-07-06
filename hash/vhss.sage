
load("utils.sage")


class VHSS():

    def __init__(self):
        pass

    def setup(self):
        print("TODO: setup")
        secret_key = 0
        verification_key = 0
        return secret_key, verification_key




    def gen_secret_share(self, security_param, i, x_i, t, nr_servers):
        """
        i: index of the client
        x_i: secret input of the client i
        t: threshold (t + 1 reconstruct)
        nr_servers: Number of servers
        """
        shares = {}
        tau_i = None
        polynomial_i = generate_random_polynomial(x_i, t)
        print("Polynomial: ", polynomial_i)
        evaluation_theta, lambda_ijs, pre_computed_shares  = generate_points(polynomial_i, nr_servers)
        print("evaluation_theta: {},  lambda_ijs: {}, pre_computed_shares: {}".format(evaluation_theta, lambda_ijs, pre_computed_shares))
        #print(evaluation_theta)
        #print(lambda_ijs)




        return shares, tau_i

    def partial_eval(self):
        print ("TODO: function")

    def partial_proof(self):
        print ("TODO: function")
