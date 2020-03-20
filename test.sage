q = 3911
FIELD = GF(q)

t = 3
g = FIELD(3)

nr_clients=4

load("client.sage")
load("server.sage")
load("additive_lhss.sage")
load("utils.sage")
load("hash.sage")

security = 64
l = security/2
prime=random_prime(2^l-1, false, 2^(l-1))#Added here to generate a prime used for creating a field for the injective function of setup
p,q = generate_safe_primes(security)
N = p*q
print("p: {} - q: {}".format(p,q))
print("N: {}".format(N))

lvhss = LHSVHSSAdditive()
lvhss.setup(security,N,nr_clients)#test the function setup
print ("Hash function output is:{}".format(H(3,prime)))
