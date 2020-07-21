from sympy.ntheory import factorint
import sympy
import random


def totient(n):
    totient = n
    for factor in factorint(n):
        totient -= totient // factor
    return totient


def random_element(modQ):
    random_e = random.randint(1, modQ.p)
    return random_e


def generate_safe_primes(security):
    lower_bound = 2 ** (security - 1)
    upper_bound = 2 ** security
    p = sympy.randprime(lower_bound, upper_bound)
    q = sympy.randprime(lower_bound, upper_bound)

    while True:
        if sympy.isprime(2 * p + 1) and sympy.isprime(2 * q + 1) and (q != p):
            return p, q
        p = sympy.randprime(lower_bound, upper_bound)
        q = sympy.randprime(lower_bound, upper_bound)


def generate_random_primes(k_security, N):
    print("starting generate random_primes")
    lower_bound = 2 ** (k_security - 1)
    upper_bound = 2 ** k_security
    p = sympy.randprime(lower_bound, upper_bound)
    q = sympy.randprime(lower_bound, upper_bound)
    n_h = p * q
    e = (p - 1) * (q - 1)
    gcd_r = sympy.gcd(N, e)
    while (p == q) or (gcd_r != 1) or (not sympy.isprime(2 * p + 1)) or (not sympy.isprime(2 * q + 1)):
        while not sympy.isprime(2 * p + 1):
            p = sympy.randprime(lower_bound, upper_bound)
        while not sympy.isprime(2 * q + 1):
            q = sympy.randprime(lower_bound, upper_bound)
        n_h = p * q
        e = (p - 1) * (q - 1)
        gcd_r = sympy.gcd(N, e)
        if sympy.isprime((p + 1) / 2) and sympy.isprime((q + 1) / 2) and (p != q) and (gcd_r == 1):
            return p, q
    return p, q


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
    NC = '\x1b[0m'  # No Color


class ANSI_Compatible:
    END = '\x1b[0m'

    # If Foreground is False that means color effect on Background
    def Color(ColorNo, Foreground=True):  # 0 - 255
        FB_G = 38  # Effect on foreground
        if Foreground != True:
            FB_G = 48  # Effect on background
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


class GColor:  # Gnome supported
    END = "\x1b[0m"

    # If Foreground is False that means color effect on Background
    def RGB(R, G, B, Foreground=True):  # R: 0-255  ,  G: 0-255  ,  B: 0-255
        FB_G = 38  # Effect on foreground
        if Foreground != True:
            FB_G = 48  # Effect on background
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
