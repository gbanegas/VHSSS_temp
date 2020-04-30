def H(element,prime):
    L=GF(prime)
    g = L.multiplicative_generator()
    
    is_nr_prime = False
    temp = 0
    while not is_nr_prime:
        temp = g^element
        is_nr_prime = temp.is_prime()
        print ("temp is {} - and is_nr_prime {}".format(temp, is_nr_prime))

    return temp
