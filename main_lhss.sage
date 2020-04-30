load("client_lhss.sage")
load("server.sage")
load("additive_lhss.sage")
load("utils.sage")
load("hash.sage")

q = 3911
FIELD = GF(q)

lvhss = LHSVHSSAdditive()

security = 64
p,q = generate_safe_primes(security)
N = p*q
print("p: {} - q: {}".format(p,q))
print("N: {}".format(N))

nr_clients = 4
nr_servers = 3
t=2
secret_key, verification_key = lvhss.setup(security,N,nr_clients)

client_1 = Client(1, [2], t, verification_key[2], lvhss )
client_2 = Client(2, [3], t, verification_key[2], lvhss )
client_3 = Client(3, [4], t, verification_key[2], lvhss )
client_4 = Client(4, [5], t, verification_key[2], lvhss )


shares_c_1 = client_1.generate_shares(nr_servers)
shares_c_2 = client_2.generate_shares(nr_servers)
shares_c_3 = client_3.generate_shares(nr_servers)
shares_c_4 = client_4.generate_shares(nr_servers)

print(shares_c_1)
print(shares_c_2)
print(shares_c_3)
print(shares_c_4)