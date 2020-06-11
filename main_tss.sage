load("additive_tss.sage")
load("utils.sage")

#test

f = 3911
FIELD = GF(f)

t = 4
g = FIELD(3)

nr_clients = 5
threshold = 3
nr_servers= 4+2
g = FIELD(3)
k_security = 64 #just to test
#p,q need to be safe primes 
p, q = generate_safe_primes(k_security)
p = (2*p+1)
q = (2*q+1)
N = p*q




print("p: {}  \n q: {}".format(p,q))
print("(p-1)/2: {}  \n (q-1)/2: {}".format((p-1)/2,(q-1)/2))
vhss = VHSS_TSS()

private_keys = {}
public_keys = {}

for i in range(1, nr_clients+1):
    public_key, private_key = vhss.setup(k_security, p, q, nr_clients, threshold)
    private_keys[i] = private_key
    public_keys[i] = public_key


print("pk: {} \n sk: {}".format(public_key, private_key))


#rsa test:
m = 11
n = p*q
c = m.powermod(public_key, n)
print("c = {}".format(c))
m_prime = c.powermod(private_key, n)
print("m_prime = {}".format(m_prime))
#--------


shares1, shared_key1, A_1, H_1  = vhss.gen_secret_share_additive_with_threshold_ss(1, [1], t, private_keys[1], 1, nr_servers, threshold, N, g)

shares2, shared_key2, A_2, H_2  = vhss.gen_secret_share_additive_with_threshold_ss(2, [2], t, private_keys[2], 1, nr_servers, threshold, N,g)

shares3, shared_key3, A_3, H_3  = vhss.gen_secret_share_additive_with_threshold_ss(3, [3], t, private_keys[3], 1, nr_servers, threshold,N, g)

shares4, shared_key4, A_4, H_4  = vhss.gen_secret_share_additive_with_threshold_ss(4, [5], t, private_keys[4], 1, nr_servers, threshold, N,g)


#phi = (p-1)*(q-1)
#R_i = ceil(R_is/(q-1))*(q-1)-R_is
R_i = ceil(4/(f-1))*(f-1)-4

shares5, shared_key5, A_5, H_5  = vhss.gen_secret_share_additive_with_threshold_ss(5, [3], t, private_keys[5], R_i, nr_servers, threshold, N,g)


print ("shares 1: {}".format(shares1))
print ("shares 2: {}".format(shares2))
print ("shares 3: {}".format(shares3))
print ("shares 4: {}".format(shares4))


#below we create lists with what each server has
servers = {}
for j in range(1, nr_servers+1):
    server_share = {}
    server_share[1] = shares1[j]
    server_share[2] = shares2[j]
    server_share[3] = shares3[j]
    server_share[4] = shares4[j]
    server_share[5] = shares5[j]
    servers[j] = server_share
        
      

omegas = {}
H_is = {}
A_is = {}
omegas[1] =shared_key1
omegas[2] =shared_key2
omegas[3] =shared_key3
omegas[4] =shared_key4
omegas[5] =shared_key5
H_is[1] = H_1
H_is[2] = H_2
H_is[3] = H_3
H_is[4] = H_4
H_is[5] = H_5

A_is[1] = A_1
A_is[2] = A_2
A_is[3] = A_3
A_is[4] = A_4
A_is[5] = A_5

#print("shares: {}".format(shares))
print("shared_key: {}".format(omegas))
print("A_is: {}".format(A_is))
print("H_is: {}".format(H_is))


print("servers: {}".format(servers[1]))

partial_eval1 = vhss.partial_eval(1, servers[1], nr_clients)
partial_eval2 = vhss.partial_eval(2, servers[2], nr_clients)
partial_eval3 = vhss.partial_eval(3, servers[3], nr_clients)
partial_eval4 = vhss.partial_eval(4, servers[4], nr_clients)
partial_eval5 = vhss.partial_eval(5, servers[5], nr_clients)
partial_eval6 = vhss.partial_eval(6, servers[6], nr_clients)

final_eval = vhss.final_eval(nr_servers)
print("final_eval : {}".format(final_eval))

partial_proofs = vhss.partial_proof(omegas, H_is, A_is, N, threshold,nr_clients)



print("partial_proofs = {}".format(partial_proofs))

print("It works until now!!!!!!!!!!!!!")
print("H_is: {}".format(H_is))

final_proof_test = vhss.final_proof( public_keys, H_is, A_is, partial_proofs, threshold, N)

print("final_proof: {}".format(final_proof_test))

result_verify = vhss.verify(nr_clients, H_is, final_proof_test, final_eval)
print ("result of the verify function is:", result_verify)
