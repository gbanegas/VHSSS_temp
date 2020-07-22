

class Params:

    FINITE_FIELD = 151
    SECURITY = 64
    G = 3
    NR_CLIENTS = 4
    NR_SERVERS = 3
    THRESHOLD_CLIENTS = 2
    THRESHOLD = 3

    @staticmethod
    def set_finite_field(Q):
        Params.FINITE_FIELD = Q

