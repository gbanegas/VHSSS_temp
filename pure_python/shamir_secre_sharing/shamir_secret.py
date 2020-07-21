# -*- coding: utf-8 -*-
"""
    Secret Sharing
    ~~~~~
    :copyright: (c) 2014 by Halfmoon Labs
    :license: MIT, see LICENSE for more details.
"""

import string

from six import integer_types
from utilitybelt import int_to_charset, charset_to_int

from arithmetic.modp import *
from arithmetic.finitefield import *
from arithmetic.prime import get_large_enough_prime
import logging, sys
logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)


def mod_inverse(k, prime):
    k = k % prime
    if k < 0:
        r = egcd(prime, -k)[2]
    else:
        r = egcd(prime, k)[2]
    return (prime + r) % prime

def modular_lagrange_interpolation(x, points, prime):
    # break the points up into lists of x and y values
    x_values, y_values = zip(*points)
    # initialize f(x) and begin the calculation: f(x) = SUM( y_i * l_i(x) )
    f_x = 0
    for i in range(len(points)):
        # evaluate the lagrange basis polynomial l_i(x)
        numerator, denominator = 1, 1
        for j in range(len(points)):
            # don't compute a polynomial fraction if i equals j
            if i == j:
                continue
            # compute a fraction & update the existing numerator + denominator
            numerator = (numerator * (x - x_values[j]))
            denominator = (denominator * (x_values[i] - x_values[j]))
        # get the polynomial from the numerator + denominator mod inverse
        lagrange_polynomial = numerator * mod_inverse(denominator, prime)
        # multiply the current y & the evaluated polynomial & add it to f(x)
        f_x = (prime + f_x + (y_values[i] * lagrange_polynomial))
    return f_x

def lagrange_coeffs(x, points, prime):
    # break the points up into lists of x and y values
    x_values, y_values = zip(*points)

    # initialize f(x) and begin the calculation: f(x) = SUM( y_i * l_i(x) )
    coeffs = {}
    lambdas_ijs = {}
    for i in range(1, len(points)+1):
        # evaluate the lagrange basis polynomial l_i(x)
        numerator, denominator = 1, 1
        lambda_ij = 1
        for j in range(1, len(points)+1):
            if i != j:
                denominator = (j-i) % prime
                denominator_tmp = mod_inverse(denominator, prime)
                lambda_ij = lambda_ij*j*denominator_tmp

        lambdas_ijs[i-1] = lambda_ij
    for i in range(len(points)):
        coeffs[i] = lambdas_ijs[i]*y_values[i]
    return coeffs



def secret_int_to_points(secret_int, point_threshold, num_points, prime=None):
    """ Split a secret (integer) into shares (pair of integers / x,y coords).
        Sample the points of a random polynomial with the y intercept equal to
        the secret int.
    """

    if point_threshold < 2:
        raise ValueError("Threshold must be >= 2.")
    if point_threshold > num_points:
        raise ValueError("Threshold must be < the total number of points.")
    if not prime:
        prime = get_large_enough_prime([secret_int, num_points])
    if not prime:
        raise ValueError("Error! Secret is too long for share calculation!")
    coefficients = shamir_random_polynomial(point_threshold-1, secret_int, prime)
    points = get_polynomial_points(coefficients, num_points)
    return points

def secret_input_int_to_points(secret_int, point_threshold, num_points, prime=None):
    """ Split a secret (integer) into shares (pair of integers / x,y coords).
        Sample the points of a random polynomial with the y intercept equal to
        the secret int.
    """

    if point_threshold < 2:
        raise ValueError("Threshold must be >= 2.")
    if point_threshold > num_points:
        raise ValueError("Threshold must be < the total number of points.")
    if not prime:
        prime = get_large_enough_prime([secret_int, num_points])
    if not prime:
        raise ValueError("Error! Secret is too long for share calculation!")
    coefficients = shamir_random_polynomial(point_threshold-1, secret_int, prime)
    points = get_polynomial_points(coefficients, num_points)
    #print("eval: {}".format(points))
    lagrange_pol = lagrange_coeffs(secret_int, points, prime)
    #print("lagrange: {}".format(lagrange_pol))
    return lagrange_pol



def points_to_secret_int(points, prime=None):
    """ Join int points into a secret int.
        Get the intercept of a random polynomial defined by the given points.
    """
    if not isinstance(points, list):
        raise ValueError("Points must be in list form.")
    for point in points:
        if not isinstance(point, tuple) and len(point) == 2:
            raise ValueError("Each point must be a tuple of two values.")
        if not (isinstance(point[0], integer_types)):
            raise ValueError("Each value in the point must be an int.")
    x_values, y_values = zip(*points)
    #prime = points[0][1].get_p()
    if not prime:
        prime = get_large_enough_prime(y_values)

    free_coefficient = modular_lagrange_interpolation(0, points, prime)
    secret_int = free_coefficient  # the secret int is the free coefficient
    return secret_int


def point_to_share_string(point, charset):
    """ Convert a point (a tuple of two integers) into a share string - that is,
        a representation of the point that uses the charset provided.
    """
    # point should be in the format (1, 4938573982723...)
    if '-' in charset:
        raise ValueError(
            'The character "-" cannot be in the supplied charset.')
    if not (isinstance(point, tuple) and len(point) == 2 and
            isinstance(point[0], integer_types) and
            isinstance(point[1], integer_types)):
        raise ValueError(
            'Point format is invalid. Must be a pair of integers.')
    x, y = point
    x_string = int_to_charset(x, charset)
    y_string = int_to_charset(y, charset)
    share_string = x_string + '-' + y_string
    return share_string


def share_string_to_point(share_string, charset):
    """ Convert a share string to a point (a tuple of integers).
    """
    # share should be in the format "01-d051080de7..."
    if '-' in charset:
        raise ValueError(
            'The character "-" cannot be in the supplied charset.')
    if not isinstance(share_string, str) and share_string.count('-') == 1:
        raise ValueError('Share format is invalid.')
    x_string, y_string = share_string.split('-')
    if (set(x_string) - set(charset)) or (set(y_string) - set(charset)):
        raise ValueError("Share has characters that aren't in the charset.")
    x = charset_to_int(x_string, charset)
    y = charset_to_int(y_string, charset)
    return (x, y)


class SecretSharer():
    """ Creates a secret sharer, which can convert from a secret string to a
        list of shares and vice versa. The splitter is initialized with the
        character set of the secrets and the character set of the shares that
        it expects to be dealing with.
    """
    secret_charset = string.hexdigits[0:16]
    share_charset = string.hexdigits[0:16]

    def __init__(self):
        pass

    @classmethod
    def split_secret(cls, secret_string, share_threshold, num_shares):
        secret_int = charset_to_int(secret_string, cls.secret_charset)
        points = secret_int_to_points(secret_int, share_threshold, num_shares)
        shares = []
        for point in points:
            shares.append(point_to_share_string(point, cls.share_charset))
        return shares

    @classmethod
    def recover_secret(cls, shares):
        points = []
        for share in shares:
            points.append(share_string_to_point(share, cls.share_charset))
        secret_int = points_to_secret_int(points)
        secret_string = int_to_charset(secret_int, cls.secret_charset)
        return secret_string


class HexToHexSecretSharer(SecretSharer):
    """ Standard sharer for converting hex secrets to hex shares.
    """
    secret_charset = string.hexdigits[0:16]
    share_charset = string.hexdigits[0:16]


class PlaintextToHexSecretSharer(SecretSharer):
    """ Good for converting secret messages into standard hex shares.
    """
    secret_charset = string.printable
    share_charset = string.hexdigits[0:16]


