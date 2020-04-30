#TODO: CHECK THE OPERATIONS IN additive_vhss.sage

#q = (2^(127))-1


q = 3911
FIELD = GF(q)

t = 3
g = FIELD(3)

load("client.sage")
load("server.sage")


nr_clients = 3
nr_servers = t*nr_clients+1
if nr_servers <= t*nr_clients:
    print(Color.F_Red, " NOT OK: Nr of server need to be bigger than t*Nr of Clients ", Color.F_Default)
    #exit()

print(Color.F_LightBlue, "------------", Color.F_Default)
print(Color.F_LightBlue, "Parameters:", Color.F_Default)
print(Color.F_LightBlue, FIELD, Color.F_Default)
print(Color.F_LightBlue, "t = {}".format(t), Color.F_Default)
print(Color.F_LightBlue, "nr_clients = {}".format(nr_clients), Color.F_Default)
print(Color.F_LightBlue, "nr_servers = {}".format(nr_servers), Color.F_Default)
print(Color.F_LightBlue, "------------", Color.F_Default)


clients = []
servers = []
vahss = VHSSAdditive()
R_is = 0
for i in range(1, nr_clients+1): #Generation clients
    if(i != nr_clients):
        R_i = FIELD.random_element()
        client = Client(i, [3] , t, g, R_i, vahss)
        print("R_i: {}".format(R_i))
        R_is = int(R_is) + int(R_i)
        clients.append(client)
    else:
        R_i = ceil(R_is/(q-1))*(q-1)-R_is
        print("R_is: {}".format(R_is))
        print("ceil: {}".format(ceil(R_is/(q-1))))
        print("ceil(R_is/(q-1))*(q-1)+R_is: {}".format(R_i))
        client = Client(i, [3] , t, g, R_i, vahss)
        clients.append(client)



for j in range(1, nr_servers+1):#generation servers
    server = Server(j, vahss)
    servers.append(server)

tau_is = {}
for client in clients: #generation shares and tau_i
    shares = client.generate_shares(nr_servers)
    print(shares)
    tau_is[client.i] = client.tau_i
    print(Color.F_Cyan,"Client {} - tau_i = {}".format(client.i, client.tau_i), Color.F_Default)
    for j in range(1, nr_servers+1):
        servers[j-1].set_share(client.i, shares[j])

#print("Tau_is : {} ".format(tau_is))
for server in servers:
    print("Server: {} -  Shares: {} ".format(server.j, server.shares))
    y_j = vahss.partial_eval(server.j, server.shares, nr_clients)
    print( "Partial Eval From Server {} = {}".format(server.j, y_j)
    sigma_j = vahss.partial_proof(server.j, server.shares, g, nr_clients)
    print(,"Partial Proof From Server {} = {}".format(server.j, sigma_j))

sigma = vahss.final_proof(nr_servers, g)
print("sigma: {}".format(sigma))

y = vahss.final_eval(nr_servers)
print(Color.F_Green,"y: {}".format(FIELD(y)),Color.F_Default)
result = vahss.verify(tau_is, nr_clients, sigma, y)
print(Color.F_Green, "Result of Verification is: {}".format(result), Color.F_Default)


# client_1 = Client(1, 3,3,g,5)
# client_1.generate_shares(5)
# client_2 = Client(2,5,3,g,5)
# client_2.generate_shares(5)
#TODO: Call the functions for running


#secret_key, verification_key = setup()
# nr_clients = 1
# shares_clients  ={}
# R_i = 5 #TODO: generate random R_is such as R_N  = -sum(R_is)
# vhss_additive = VHSSAdditive()
# for i in range(1, nr_clients+1):
#      #return_client = gen_secret_share(128, i, [3], 2, 6)
#      return_client = vhss_additive.gen_secret_share_additive_with_hash_functions(128, i, [3], 2, 6, R_i, g)
#      print("return_client: ", return_client)
#      shares_clients[i] = return_client

#gen_secret_share(128, 2, [3], 2, 6)
