load("additive_tss.sage")
load("utils.sage")

nr_clients = 4
threshold = 3

k_security = 64 #just to test
#p,q need to be safe primes 
p, q = generate_safe_primes(k_security)
p = (2*p+1)
q = (2*q+1)


print("p: {}  \n q: {}".format(p,q))
print("(p-1)/2: {}  \n (q-1)/2: {}".format((p-1)/2,(q-1)/2))
vhss = VHSS_TSS()

public_key, private_key = vhss.setup(k_security, p, q, nr_clients, threshold)


print("pk: {} \n sk: {}".format(public_key, private_key))

