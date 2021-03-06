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

p = 11 
q = 13 

phi = (p-1)*(q-1)
#we need to compute x such that x^a=b mod (pq)
a=7
b=17
inv_a = inverse_mod(a, phi)#a^-1 mod phi
x=(b^inv_a).mod((p*q))

security = 64
l = security/2
prime=random_prime(2^l-1, false, 2^(l-1)) #Added here to generate a prime used for creating a field for the injective function of setup
p,q = generate_safe_primes(security)
N = p*q
print("p: {} - q: {}".format(p,q))
print("N: {}".format(N))

lvhss = LHSVHSSAdditive()
secret_key, verification_key = lvhss.setup(security,N,nr_clients)#test the function setup
print("secret_key: {}".format(secret_key))
print("verification_key: {}".format(verification_key))




