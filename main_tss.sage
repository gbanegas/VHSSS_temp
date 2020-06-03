load("additive_tss.sage")
load("utils.sage")

nr_clients = 4
threshold = 3

k_security = 64 #just to test
#p,q need to be safe primes 
p, q = generate_safe_primes(k_security)


vhss = VHSS_TSS()

public_key, private_key = vhss.setup(k_security, p, q, nr_clients, threshold)
