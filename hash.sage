load("utils.sage")

def H(element,prime):
    L=GF(prime)
    g = L.multiplicative_generator()
    print ("generator is {} - and prime is {}".format(g, prime))

    return g^element
