class ShamirSecret():

    def __init__(self):
        pass


    def gen_secret_share(self, security_param, i, x_i, t, nr_servers):
        """
        i: index of the client
        x_i: secret input of the client i
        t: threshold (t + 1 reconstruct)
        nr_servers: Number of servers
        """
        shares = {}
        polynomial_i = generate_random_polynomial(x_i, t)
        print("Polynomial: ", polynomial_i)
        evaluation_theta, lambda_ijs, pre_computed_shares  = generate_points(polynomial_i, nr_servers)
        print("evaluation_theta: {},  lambda_ijs: {}, pre_computed_shares: {}".format(evaluation_theta, lambda_ijs, pre_computed_shares))
        return shares
