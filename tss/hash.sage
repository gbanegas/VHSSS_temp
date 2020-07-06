def H(element,prime):
    L=GF(prime)
    g = L.multiplicative_generator()
    temp = g^element
    is_nr_prime = Integer(temp).is_prime()
    while not is_nr_prime or temp == 2:
        element=element+1
        temp = g^element
        is_nr_prime = Integer(temp).is_prime()
        #print ("temp is {} - and is_nr_prime {}".format(temp, is_nr_prime))
    return temp
