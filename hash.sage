def H(element,prime):#only for the lhss/TODO: fix this for getting the next prime #if element does not give an acceptable value, then go to element+1 etc until you find one. 
    L=GF(prime)
    g = L.multiplicative_generator()
    if(element == 1):
        return 3

    temp = g^element
    is_nr_prime = Integer(temp).is_prime()
    while not is_nr_prime or temp == 2:
        temp = g^L.random_element()
        is_nr_prime = Integer(temp).is_prime()
        #print ("temp is {} - and is_nr_prime {}".format(temp, is_nr_prime))

    return temp

def H_1(element,prime):
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
