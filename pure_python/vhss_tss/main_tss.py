import math
from arithmetic.modp import *
from arithmetic.utils import *
from shamir_secre_sharing.wrapper import *

from vhss_tss.tss_additive import *


def main_tss():
    print("------ starting TSS ----")
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
    p, q = generate_safe_primes(security)
    N = p * q
    print("p: {} - q: {}".format(p, q))
    print("N: {}".format(N))
    nr_clients = 4
    nr_servers = 3
    t = 2
    tss = VHSS_TSS(modQ)


