import math
from arithmetic.modp import *
from arithmetic.utils import *
from shamir_secre_sharing.wrapper import *

from vhss_tss.tss_additive import *
from vhss_tss.client_tss import *
from vhss_tss.server_tss import *


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
    omegas = {}
    H_is = {}
    A_is = {}
    public_keys = {}
    
    tss = VHSS_TSS(modQ)

    for j in range(1, nr_servers + 1):
        server = ServerTSS(j, tss)
        servers.append(server)
    R_is = 0
    for i in range(1, nr_clients + 1):  # Generation clients
      public_key, private_key = tss.setup(security, p, q, nr_clients, threshold)
      public_keys[i] = public_key
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
      omegas[client.get_id()] = shared_key_i
      A_is[client.get_id()] = A_i
      H_is[client.get_id()] = H_i

      for server in servers:
          server.set_share(client.get_id(), shares[server.get_id()-1], shared_key_i, A_i, H_i)

    partial_evals = []
    for j in range(1, nr_servers+1):
        partial_eval = tss.partial_eval(j, servers[j-1].get_shares(), nr_clients)
        partial_evals.append(partial_eval)

    print("partial_evals: {}".format(partial_evals))
    final_eval = tss.final_eval(nr_servers)
    print("final_eval : {}".format(final_eval))

    partial_proofs = tss.partial_proof(omegas, H_is, A_is, N, threshold, nr_clients, public_keys)
    print("partial_proofs = {}".format(partial_proofs))

    final_proof_test = tss.final_proof(public_keys, H_is, A_is, partial_proofs, threshold, N, nr_clients)

    print("final_proof: {}".format(final_proof_test))

    result_verify = tss.verify(nr_clients, H_is, final_proof_test, final_eval, g)
    print("result of the verify function is:", result_verify)








