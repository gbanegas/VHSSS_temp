load("additive_tss.sage")
load("utils.sage")

q = 3911
FIELD = GF(q)

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


shares1, shared_key1, A_1, H_1  = vhss.gen_secret_share_additive_with_threshold_ss(1, [1], t, private_keys[1], 3, nr_servers, threshold, g)

shares2, shared_key2, A_2, H_2  = vhss.gen_secret_share_additive_with_threshold_ss(2, [2], t, private_keys[2], 3, nr_servers, threshold, g)

shares3, shared_key3, A_3, H_3  = vhss.gen_secret_share_additive_with_threshold_ss(3, [3], t, private_keys[3], 3, nr_servers, threshold, g)

shares4, shared_key4, A_4, H_4  = vhss.gen_secret_share_additive_with_threshold_ss(4, [5], t, private_keys[4], 3, nr_servers, threshold, g)

shares5, shared_key5, A_5, H_5  = vhss.gen_secret_share_additive_with_threshold_ss(5, [3], t, private_keys[5], 3, nr_servers, threshold, g)

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

partial_proofs = vhss.partial_proof(omegas, H_is, A_is, N, nr_servers, threshold,nr_clients)

print("partial_proofs = {}".format(partial_proofs))