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

list_of_elements = []
j=0
for i in range(q):
  result1 = H(i, q) #bijection function
  if result1 not in list_of_elements:
    list_of_elements.append(result1)
    j=j+1
  else:
    print("i: {} - result: {}".format(i, result1))
    print("not bijection")
  print("j is {}".format( j))




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
prime=random_prime(2^l-1, false, 2^(l-1))#Added here to generate a prime used for creating a field for the injective function of setup
p,q = generate_safe_primes(security)
N = p*q
print("p: {} - q: {}".format(p,q))
print("N: {}".format(N))

lvhss = LHSVHSSAdditive()
lvhss.setup(security,N,nr_clients)#test the function setup
print ("Hash function output is:{}".format(H(3,prime)))
