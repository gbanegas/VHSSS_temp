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




print("p: {}  \n q: {}".format(p,q))
print("(p-1)/2: {}  \n (q-1)/2: {}".format((p-1)/2,(q-1)/2))
vhss = VHSS_TSS()

public_key, private_key = vhss.setup(k_security, p, q, nr_clients, threshold)


print("pk: {} \n sk: {}".format(public_key, private_key))

#rsa test:
m = 11
n = p*q
c = m.powermod(public_key, n)
print("c = {}".format(c))
m_prime = c.powermod(private_key, n)
print("m_prime = {}".format(m_prime))
#--------