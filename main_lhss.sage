load("client_lhss.sage")
load("server_lhss.sage")
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

server_1 = Server(1, lvhss)
server_2 = Server(2, lvhss)
server_3 = Server(3, lvhss)

server_1.set_share(1, shares_c_1[1])
server_1.set_share(2, shares_c_2[1])
server_1.set_share(3, shares_c_3[1])
server_1.set_share(4, shares_c_4[1])

server_2.set_share(1, shares_c_1[2])
server_2.set_share(2, shares_c_2[2])
server_2.set_share(3, shares_c_3[2])
server_2.set_share(4, shares_c_4[2])

server_3.set_share(1, shares_c_1[3])
server_3.set_share(2, shares_c_2[3])
server_3.set_share(3, shares_c_3[3])
server_3.set_share(4, shares_c_4[3])


partial_eval_1  = lvhss.partial_eval(1, server_1.get_shares(), nr_clients)
partial_eval_2  = lvhss.partial_eval(2, server_2.get_shares(), nr_clients)
partial_eval_3  = lvhss.partial_eval(3, server_3.get_shares(), nr_clients)

print("Partial eval server 1: {}".format(partial_eval_1))
print("Partial eval server 2: {}".format(partial_eval_2))
print("Partial eval server 3: {}".format(partial_eval_3))

final_eval = lvhss.final_eval(nr_servers)

partial_proof_1 = lvhss.partial_proof(self, secret_key, verification_key, 1, 2+1, 1)
partial_proof_2 = lvhss.partial_proof(self, secret_key, verification_key, 1, 3+1, 2)
partial_proof_3 = lvhss.partial_proof(self, secret_key, verification_key, 1, 4+1, 3)
R_i = ceil(3/(q-1))*(q-1)-3
partial_proof_4 = lvhss.partial_proof(self, secret_key, verification_key, 1, 5+R_i, 4)

