from arithmetic.modp import *
from arithmetic.utils import *
from vhss_ts.params import *
from vhss_ts.tss import *
from vhss_ts.client import *
from vhss_ts.server import *
import math

def main_ts():
    print("--- Start Main ---")
    clients = []
    servers = []

    #p, q = generate_safe_primes(Params.SECURITY)
    Params.set_finite_field(151)
    modQ = IntegersModP(Params.FINITE_FIELD)
    p = 151
    q = 11
    N = p * q
    phi_N = (p-1)*(q-1)
    print("p: {} - q: {}".format(p, q))
    print("N: {}".format(N))
    tss = TSS(modQ)

    public_keys = {}
    R_is = 0
    for i in range(1, Params.NR_CLIENTS+1):
        if i != Params.NR_CLIENTS:
            public_key, private_key = tss.key_gen(p,q)
            print("public: {}".format(public_key))
            print("private_key: {}".format(private_key))
            R_i = 2
            c = ClientTS(i, [1], private_key, public_key, R_i, tss)
            R_is = int(R_is) + int(R_i)
            clients.append(c)
            public_keys[i] = public_key
        else:
            print("public: {}".format(public_key))
            print("private_key: {}".format(private_key))
            R_i = math.ceil(R_is / (Params.FINITE_FIELD - 1)) * (Params.FINITE_FIELD - 1) - R_is
            c = ClientTS(i, [1], private_key, public_key, R_i, tss)
            R_is = int(R_is) + int(R_i)
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

    print("Omegas: {}".format(omegas))
    print("matrix_As: {}".format(matrix_As))
    print("hash_Hs: {}".format(hash_Hs))

    tss.partial_proof(omegas,hash_Hs, matrix_As, N)

    sigma = tss.final_proof(public_keys, hash_Hs, matrix_As, N)

    result_verify = TSS.verify(hash_Hs, sigma, y)

    print("result_verify: {}".format(result_verify))



