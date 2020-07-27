def H(element,prime):
    L=GF(prime)
    g = L(2)
    print("g: {}".format(g))
    temp = g^element
    print("q: {}".format(prime))

    is_nr_prime = Integer(temp).is_prime()
    while not is_nr_prime or temp == 2:
        #print("temp: {}".format(temp))
        element = element+1
        temp = g^element
        is_nr_prime = Integer(temp).is_prime()
        #print ("temp is {} - and is_nr_prime {}".format(temp, is_nr_prime))
    return temp
