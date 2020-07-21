import math
from arithmetic.modp import *
from arithmetic.utils import *
from shamir_secre_sharing.wrapper import *


from vhss_hash.vhss_additive import *
from vhss_hash.client_hash import *
from vhss_hash.server_hash import *


def main_hash():
    q = 3911
    modQ = IntegersModP(q)
    print(modQ(3912) + modQ(3912111))
    t = 3
    nr_clients = 3
    g = 3
    nr_servers = t*nr_clients+1
    clients = []
    servers = []
    vahss = VHSSAdditive(modQ)
    R_is = 0
    for i in range(1, nr_clients + 1):  # Generation clients
        if (i != nr_clients):
            R_i = random_element(modQ)
            client = ClientHash(i, [3], t, g, R_i, vahss)
            print("R_i: {}".format(R_i))
            R_is = int(R_is) + int(R_i)
            clients.append(client)
        else:
            R_i = math.ceil(R_is / (q - 1)) * (q - 1) - R_is
            print("R_is: {}".format(R_is))
            print("ceil: {}".format(math.ceil(R_is / (q - 1))))
            print("ceil(R_is/(q-1))*(q-1)+R_is: {}".format(R_i))
            client = ClientHash(i, [3], t, g, R_i, vahss)
            clients.append(client)

    for j in range(1, nr_servers + 1):  # generation servers
        server = ServerHash(j, vahss)
        servers.append(server)

    tau_is = {}
    for client in clients:  # generation shares and tau_i
        shares = client.generate_shares(nr_servers)
        print(shares)
        tau_is[client.i] = client.tau_i
        print(Color.F_Cyan, "Client {} - tau_i = {}".format(client.i, client.tau_i), Color.F_Default)
        for j in range(1, nr_servers + 1):
            servers[j - 1].set_share(client.i, shares[j-1])

    for server in servers:
        print("Server: {} -  Shares: {} ".format(server.j, server.shares))
        y_j = vahss.partial_eval(server.j, server.shares, nr_clients)
        print("Partial Eval From Server {} = {}".format(server.j, y_j))
        sigma_j = vahss.partial_proof(server.j, server.shares, g, nr_clients)
        print("Partial Proof From Server {} = {}".format(server.j, sigma_j))

    sigma = vahss.final_proof(nr_servers, g)
    print("sigma: {}".format(sigma))

    y = vahss.final_eval(nr_servers)
    print(Color.F_Green, "y: {}".format(modQ(y)), Color.F_Default)
    result = vahss.verify(tau_is, nr_clients, sigma, y, g)
    print(Color.F_Green, "Result of Verification is: {}".format(result), Color.F_Default)


