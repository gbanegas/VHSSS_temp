import math
from arithmetic.modp import *
from arithmetic.utils import *
from shamir_secre_sharing.wrapper import *

from vhss_tss.tss_additive import *
from vhss_tss.client_tss import *


def main_tss():
    print("------ starting TSS ----")
    q_field_for_secret_sharing = 3911
    modQ = IntegersModP(q_field_for_secret_sharing)
    t = 4
    g = 3
    nr_clients = 5
    threshold = 3
    nr_servers= 4+2
    clients = []
    servers = []
    security = 64
    p, q = generate_safe_primes(security)
    N = p * q
    print("p: {} - q: {}".format(p, q))
    print("N: {}".format(N))
    
    tss = VHSS_TSS(modQ)
    R_is = 0
    for i in range(1, nr_clients + 1):  # Generation clients
      public_key, private_key = tss.setup(security, p, q, nr_clients, threshold)
      if (i != nr_clients):
          R_i = random_element(modQ)
          client = ClientTSS(i, [3], t, g, R_i, private_key, public_key,tss)
          print("R_i: {}".format(R_i))
          R_is = int(R_is) + int(R_i)
          clients.append(client)
      else:
          R_i = math.ceil(R_is / (q - 1)) * (q - 1) - R_is
          print("R_is: {}".format(R_is))
          print("ceil: {}".format(math.ceil(R_is / (q - 1))))
          print("ceil(R_is/(q-1))*(q-1)+R_is: {}".format(R_i))
            #client = ClientHash(i, [3], t, g, R_i, vahss)
          client = ClientTSS(i, [3], t, g, R_i, private_key, public_key, tss)
          clients.append(client)

    for client in clients:
      shares, shared_key_i, A_i, H_i = client.generate_shares(nr_servers, threshold, N, g)




