param D > 0 integer;
param E > 0 integer;
param V > 0 integer;

set Nodes := 1..V;
set link_nos := 1..E;
set demand_nos := 1..D;

param link_src {link_nos} within Nodes;
param link_dest {link_nos} within Nodes;
param link_capacity {link_nos} >= 0 integer;
param link_cost {link_nos} >= 0 integer;

param demand_src {demand_nos} within Nodes;
param demand_dest {demand_nos} within Nodes;
param demand {demand_nos} >= 0;
param h {v in Nodes, t in Nodes} = sum {d in demand_nos} (if v == demand_src[d] && t == demand_dest[d] then demand[d] else 0);

param M > 0 integer;

param w {link_nos} >= 0 integer;
var r {v in Nodes, t in Nodes} >= 0 integer;
var x {e in link_nos, t in Nodes} >= 0;
var y {v in Nodes, t in Nodes} >= 0;
var u {e in link_nos, t in Nodes} binary;
var utilization {e in link_nos} >= 0;

minimize TotalCost: sum {e in link_nos} (link_cost[e] * utilization[e]);

subj to total_demands {t in Nodes}:
sum {e in link_nos} (if link_dest[e] == t then x[e, t]) == sum {s in Nodes} (if s <> t then h[s, t]);

subj to subject_demands {v in Nodes, t in Nodes}:
if v <> t then
sum {e in link_nos} (if link_src[e] == v then x[e, t]) - sum {e in link_nos} (if link_dest[e] == v then x[e, t]) == h[v, t];

subj to total_link_capacity {e in link_nos}:
sum {t in Nodes} (x[e, t]) <= link_capacity[e];

subj to subject_binary_demand_zero {t in Nodes, e in link_nos}:
y[link_src[e], t] - x[e, t] >= 0;

subj to subject_binary_demand_upper {t in Nodes, e in link_nos}:
y[link_src[e], t] - x[e, t] <= (1 - u[e, t]) * sum {v in Nodes} (h[v, t]);

subj to binary_demand {t in Nodes, e in link_nos}:
x[e, t] <= u[e, t] * sum {v in Nodes} (h[v, t]);

subj to length_weight_zero {t in Nodes, e in link_nos}:
r[link_dest[e], t] + w[e] - r[link_src[e], t] >= 0;

subj to length_weight_upper {t in Nodes, e in link_nos}:
r[link_dest[e], t] + w[e] - r[link_src[e], t] <= (1 - u[e, t]) * M;

subj to binary_length_weight {t in Nodes, e in link_nos}:
1 - u[e, t] <= r[link_dest[e], t] + w[e] - r[link_src[e], t];

subj to weight_bound {e in link_nos}:
w[e] >= 1;

subj to link_utilization {e in link_nos}:
utilization[e] = sum {t in Nodes} (x[e, t]) / link_capacity[e];