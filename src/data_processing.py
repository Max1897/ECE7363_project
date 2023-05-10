# Data reading file
# This file process SND raw data to data matrices. Column: demand pair, Row: demands along time

# #Reference: https://github.com/PredWanTE/DOTE/blob/43e628bd457e31958eba4f696e3de869d3e7789e
# /networking_envs/data/gen_geant_topo.py#L12


import os
import math

demand_matrices_dir = "./data/directed-geant-uhlig-15min-over-4months-ALL-native"
output_dir = "./data/GEANT"
train_fraction = 0.75  # fraction of DMs for the training dataset
assert not os.path.exists(output_dir)

# demand matrices
dms_input_files = os.listdir(demand_matrices_dir)
dms_input_files.sort()

nodes = {}

# Create nodes dictionary
with open(demand_matrices_dir + '/' + dms_input_files[0]) as f:
    line = f.readline().strip()
    while not line.startswith("NODES ("): line = f.readline().strip()
    line = f.readline().strip()
    while not line.startswith(")"):
        node_name = line.split()[0]
        nodes[node_name] = len(nodes)

        line = f.readline().strip()

# demand matrices
demands = [["0.0"] * (len(nodes) * len(nodes)) for _ in range(len(dms_input_files))]
count = 0
for i in range(len(dms_input_files)):
    file = dms_input_files[i]
    assert file.endswith('.txt')
    is_empty = True
    with open(demand_matrices_dir + '/' + file) as f:
        line = f.readline().strip()
        while not line.startswith("DEMANDS ("): line = f.readline().strip()
        line = f.readline().strip()
        while not line.startswith(")"):
            is_empty = False
            demand_info = line.split()
            src = demand_info[2]
            dst = demand_info[3]
            demand = demand_info[6]
            assert src in nodes and dst in nodes and demand_info[0] == src + '_' + dst and float(demand) >= 0.0
            demands[count][nodes[src] * len(nodes) + nodes[dst]] = repr(float(demand))
            line = f.readline().strip()
    if is_empty:
        continue
    count += 1

# Dividing train & test data
train_data = demands[:int(math.ceil(count * train_fraction))]
test_data = demands[int(math.ceil(count * train_fraction)):]


os.mkdir(output_dir)
os.mkdir(output_dir + "/pred")

n_train_dms = int(math.ceil(count * train_fraction))
f = open(output_dir + '/GEANT_train.txt', 'w')
n_dms_in_f = 0
for i in range(count):
    if i == n_train_dms:
        f.close()
        f = open(output_dir + '/GEANT_test.txt', 'w')
        n_dms_in_f = 0

    f.write(' '.join(demands[i]) + '\n')
    n_dms_in_f += 1
