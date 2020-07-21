import math
from arithmetic.modp import *
from arithmetic.utils import *
from shamir_secre_sharing.wrapper import *

from vhss_lhss.lhss_additive import *
from vhss_lhss.client_lhss import *
from vhss_lhss.server_lhss import *


def main_lhss():
    print("------ starting -------")
    q = 3911
    modQ = IntegersModP(q)
    print(modQ(3912) + modQ(3912111))
    t = 3
    nr_clients = 3
    g = 3
    nr_servers = t * nr_clients + 1
    clients = []
    servers = []
    security = 64
    lhss = LHSSAdditive(modQ)
    p, q = generate_safe_primes(security)
    N = p * q
    print("p: {} - q: {}".format(p, q))
    print("N: {}".format(N))
    nr_clients = 4
    nr_servers = 3
    t = 2
    secret_key, verification_key = lhss.setup(security, N, nr_clients)

    client_1 = ClientLHSS(1, [2], t, g, verification_key[2], lhss)
    client_2 = ClientLHSS(2, [3], t, g, verification_key[2], lhss)
    client_3 = ClientLHSS(3, [4], t, g, verification_key[2], lhss)
    client_4 = ClientLHSS(4, [5], t, g, verification_key[2], lhss)

    shares_c_1 = client_1.generate_shares(nr_servers)
    shares_c_2 = client_2.generate_shares(nr_servers)
    shares_c_3 = client_3.generate_shares(nr_servers)
    shares_c_4 = client_4.generate_shares(nr_servers)

    print(shares_c_1)
    print(shares_c_2)
    print(shares_c_3)
    print(shares_c_4)

    server_1 = ServerLHSS(1, lhss)
    server_2 = ServerLHSS(2, lhss)
    server_3 = ServerLHSS(3, lhss)

    server_1.set_share(1, shares_c_1[0])
    server_1.set_share(2, shares_c_2[0])
    server_1.set_share(3, shares_c_3[0])
    server_1.set_share(4, shares_c_4[0])

    server_2.set_share(1, shares_c_1[1])
    server_2.set_share(2, shares_c_2[1])
    server_2.set_share(3, shares_c_3[1])
    server_2.set_share(4, shares_c_4[1])

    server_3.set_share(1, shares_c_1[2])
    server_3.set_share(2, shares_c_2[2])
    server_3.set_share(3, shares_c_3[2])
    server_3.set_share(4, shares_c_4[2])
    print("shares s1: {}".format(server_1.get_shares()))
    print("shares s2: {}".format(server_2.get_shares()))
    print("shares s3: {}".format(server_3.get_shares()))

    partial_eval_1 = lhss.partial_eval(1, server_1.get_shares(), nr_clients)
    partial_eval_2 = lhss.partial_eval(2, server_2.get_shares(), nr_clients)
    partial_eval_3 = lhss.partial_eval(3, server_3.get_shares(), nr_clients)

    print("Partial eval server 1: {}".format(partial_eval_1))
    print("Partial eval server 2: {}".format(partial_eval_2))
    print("Partial eval server 3: {}".format(partial_eval_3))

    final_eval = lhss.final_eval(nr_servers)

    partial_proof_1 = lhss.partial_proof(secret_key, verification_key, 3, 2 + 1, 1, q)
    partial_proof_2 = lhss.partial_proof(secret_key, verification_key, 3, 3 + 1, 2, q)
    partial_proof_3 = lhss.partial_proof(secret_key, verification_key, 3, 4 + 1, 3, q)
    # R_i = ceil(3/(q-1))*(q-1)-3
    phi = (secret_key[0] - 1) * (secret_key[1] - 1)
    R_i = math.ceil(3 / (phi)) * (phi) - 3
    partial_proof_4 = lhss.partial_proof(secret_key, verification_key, 1, 5 + R_i, 4, q)

    print("Partial proof c 1: {}".format(partial_proof_1))
    print("Partial proof c 2: {}".format(partial_proof_2))
    print("Partial proof c 3: {}".format(partial_proof_3))
    print("Partial proof c 4: {}".format(partial_proof_4))

    list_proofs = [partial_proof_1, partial_proof_2, partial_proof_3, partial_proof_4]
    final_proof_test = lhss.final_proof(verification_key, list_proofs, nr_clients, q)

    print("Final Proof: {}".format(final_proof_test))

    lhss.verify(verification_key, final_proof_test, final_eval, q)
