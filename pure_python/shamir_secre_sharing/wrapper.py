from shamir_secre_sharing.shamir_secret import *

import logging, sys
logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)


class Protocol(object):

    def __init__(self):
        pass

    @staticmethod
    def generate_shamir_secret(secret, nr_threshold, nr_parts, prime=None):
        #logging.info("wrapper:generate_shamir_secret")
        points = secret_int_to_points(secret, nr_threshold, nr_parts, prime)
        return points

    @staticmethod
    def recover_shamir_secret(points, prime=None):
        secret = points_to_secret_int(points, prime)
        #print("secret: {}".format(secret%prime))
        return secret

    @staticmethod
    def generate_input_shamir_secret(secret, nr_threshold, nr_parts, prime=None):
        # logging.info("wrapper:generate_shamir_secret")
        points = secret_input_int_to_points(secret, nr_threshold, nr_parts, prime)
        return points

