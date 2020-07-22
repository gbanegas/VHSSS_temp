from pfp.fields import Int

from arithmetic.modp import *
from arithmetic.utils import *
from vhss_ts.params import *
from vhss_ts.tss import *
from vhss_ts.client import *
from vhss_ts.server import *

def main_ts():
    print("--- Start Main ---")
    clients = []
    servers = []
    #p, q = generate_safe_primes(Params.SECURITY)
    modQ = IntegersModP(Params.FINITE_FIELD)
    p = 16779169001330563571
    q = 11439834306398852411
    N = p * q
    print("p: {} - q: {}".format(p, q))
    print("N: {}".format(N))
    tss = TSS(modQ)

    public_keys = {}
    for i in range(1, Params.NR_CLIENTS+1):
        public_key, private_key = tss.key_gen(p,q)
        c = ClientTS(i, [1], private_key, public_key, 0, tss)
        clients.append(c)
        public_keys[i] = public_key

    for j in range(1, Params.NR_SERVERS+1):
        s = ServerTS(j)
        servers.append(s)


    omegas = {}
    matrix_As = {}
    hash_Hs = {}
    for c in clients:
        shares, shared_key, matrix_A, hash_H = c.generate_shares(N)
        omegas[c.i] = shared_key
        matrix_As[c.i] = matrix_A
        hash_Hs[c.i] = hash_H
        for s in servers:
            s.set_share(c.i, shares[s.j-1])

    for s in servers:
        tss.partial_eval(s.j, s.shares)

    y = tss.final_eval()
    print("y : {}".format(y))

    tss.partial_proof(omegas,hash_Hs, matrix_As, N)

    sigma = tss.final_proof(public_keys, hash_Hs, matrix_As, N)

    result_verify = TSS.verify(hash_Hs, sigma, y)

    print("result_verify: {}".format(result_verify))



