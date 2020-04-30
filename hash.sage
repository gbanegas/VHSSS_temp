def H(element,prime, n_hat):
    L=GF(prime)
    g = L.multiplicative_generator()
    
    temp = g^element
    is_nr_prime = Integer(temp).is_prime()
    gcd_r = gcd(temp, n_hat)
    while not is_nr_prime or temp == 2 or gcd_r != 1:
        temp = g^L.random_element()
        is_nr_prime = Integer(temp).is_prime()
        gcd_r = gcd(temp, n_hat)
        print ("temp is {} - and is_nr_prime {}".format(temp, is_nr_prime))

    return temp
