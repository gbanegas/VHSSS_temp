def generate_safe_primes(k_security):
    p = random_prime(2^k_security-1, false, 2^(k_security-1))#(upperbound of the lenght of the prime selected,proof of primality,lower bound of length of the prime selected)
    q = random_prime(2^k_security-1, false, 2^(k_security-1))
    while True:
        #print("p: {} , q: {}".format(p,q))
        if ZZ((2*p+1)).is_prime() and ZZ((2*q+1)).is_prime() and (p != q):
            return p,q
        p = random_prime(2^k_security-1, false, 2^(k_security-1))
        q = random_prime(2^k_security-1, false, 2^(k_security-1))

def generate_random_primes(k_security, N):
     p_h = random_prime(2^k_security-1, false, 2^(k_security-1))
     q_h = random_prime(2^k_security-1, false, 2^(k_security-1))
    # print("p_hat: {} - q_hat: {}".format(p_h,q_h))
     n_h =  p_h*q_h
     e =  euler_phi(n_h)
    # print("euler_phi: ", e)
     gcd_r = gcd(N, e);
     #print("gcd: ", gcd_r)
     while (p_h == q_h) or (gcd_r != 1) or (not ZZ((2*p_h+1)).is_prime()) or (not ZZ((2*q_h+1)).is_prime()):
         while (not ZZ((2*p_h+1)).is_prime()):
              p_h = random_prime(2^k_security-1, false, 2^(k_security-1))
         while (not ZZ((2*q_h+1)).is_prime()):
              q_h = random_prime(2^k_security-1, false, 2^(k_security-1))
         n_h =  p_h*q_h
         e =  euler_phi(n_h)
         gcd_r = gcd(N, e);
        # print("p_h == q_h: {} - gcd_r != 1: {} - (not ZZ((p_h+1)/2).is_prime()): {} - (not ZZ((q_h+1)/2).is_prime()): {}".format((p_h == q_h),(gcd_r != 1) , (not ZZ((p_h+1)/2).is_prime()), (not ZZ((q_h+1)/2).is_prime())))
         if (ZZ((q_h+1)/2).is_prime()) and (ZZ((p_h+1)/2).is_prime()) and (p_h != q_h) and (gcd_r == 1):
             return p_h,q_h



     return p_h, q_h

def random_Z_star(N):
    R = IntegerModRing(N)
    r=R.random_element()
    while (gcd(r, N)!=1) and (r==0):
        r=R.random_element()
    return r


def generate_random_polynomial(x_i, t):
    rs = []
    for i in range(t):
        random_e = FIELD.random_element()
        while random_e == 0:
            random_e = FIELD.random_element()
        rs.insert(i, random_e)
    #rs = [FIELD.random_element() for _ in range(t+1)]
    F.<X> = FIELD[]
    rs.insert(0,x_i[0])
    #print "rs: ", rs
    pol = F(rs)
    return pol


def generate_points(polynomial_i, nr_servers):
    evaluation_theta = {}
    for j in range(1,nr_servers+1):
        evaluation_theta[j] = polynomial_i(j)
        #dictionary[j] = evaluation_theta

    #Computing Lagrange Coeffs
    lambda_ijs = {}
    pre_computed_products = {}
    for j in range(1, nr_servers+1):
        lambda_ij =  FIELD(1)
        for k in range(1, nr_servers+1):
            if j != k:
                lambda_ij = FIELD(lambda_ij)*FIELD(FIELD(k)/(FIELD(k)-FIELD(j)))
        lambda_ijs[j] = lambda_ij
        pre_computed_products[j] =  lambda_ij*evaluation_theta[j]


    return evaluation_theta, lambda_ijs, pre_computed_products


class Base:
    # Foreground:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    # Formatting
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    # End colored text
    END = '\033[0m'
    NC ='\x1b[0m' # No Color

class ANSI_Compatible:
    END = '\x1b[0m'
    # If Foreground is False that means color effect on Background
    def Color(ColorNo, Foreground=True): # 0 - 255
        FB_G = 38 # Effect on foreground
        if Foreground != True:
            FB_G = 48 # Effect on background
        return '\x1b[' + str(FB_G) + ';5;' + str(ColorNo) + 'm'

class Formatting:
    Bold = "\x1b[1m"
    Dim = "\x1b[2m"
    Italic = "\x1b[3m"
    Underlined = "\x1b[4m"
    Blink = "\x1b[5m"
    Reverse = "\x1b[7m"
    Hidden = "\x1b[8m"
    # Reset part
    Reset = "\x1b[0m"
    Reset_Bold = "\x1b[21m"
    Reset_Dim = "\x1b[22m"
    Reset_Italic = "\x1b[23m"
    Reset_Underlined = "\x1b[24"
    Reset_Blink = "\x1b[25m"
    Reset_Reverse = "\x1b[27m"
    Reset_Hidden = "\x1b[28m"

class GColor: # Gnome supported
    END = "\x1b[0m"
    # If Foreground is False that means color effect on Background
    def RGB(R, G, B, Foreground=True): # R: 0-255  ,  G: 0-255  ,  B: 0-255
        FB_G = 38 # Effect on foreground
        if Foreground != True:
            FB_G = 48 # Effect on background
        return "\x1b[" + str(FB_G) + ";2;" + str(R) + ";" + str(G) + ";" + str(B) + "m"

class Color:
    # Foreground
    F_Default = "\x1b[39m"
    F_Black = "\x1b[30m"
    F_Red = "\x1b[31m"
    F_Green = "\x1b[32m"
    F_Yellow = "\x1b[33m"
    F_Blue = "\x1b[34m"
    F_Magenta = "\x1b[35m"
    F_Cyan = "\x1b[36m"
    F_LightGray = "\x1b[37m"
    F_DarkGray = "\x1b[90m"
    F_LightRed = "\x1b[91m"
    F_LightGreen = "\x1b[92m"
    F_LightYellow = "\x1b[93m"
    F_LightBlue = "\x1b[94m"
    F_LightMagenta = "\x1b[95m"
    F_LightCyan = "\x1b[96m"
    F_White = "\x1b[97m"
    # Background
    B_Default = "\x1b[49m"
    B_Black = "\x1b[40m"
    B_Red = "\x1b[41m"
    B_Green = "\x1b[42m"
    B_Yellow = "\x1b[43m"
    B_Blue = "\x1b[44m"
    B_Magenta = "\x1b[45m"
    B_Cyan = "\x1b[46m"
    B_LightGray = "\x1b[47m"
    B_DarkGray = "\x1b[100m"
    B_LightRed = "\x1b[101m"
    B_LightGreen = "\x1b[102m"
    B_LightYellow = "\x1b[103m"
    B_LightBlue = "\x1b[104m"
    B_LightMagenta = "\x1b[105m"
    B_LightCyan = "\x1b[106m"
    B_White = "\x1b[107m"
