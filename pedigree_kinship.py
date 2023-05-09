#!/usr/bin/env python

import sys
import networkx as nx
import itertools as it

ped_graph = nx.DiGraph()

with open(sys.argv[1]) as fh:
    for line in fh:
        if(line.startswith('id')):
            continue
        else:
            lineContents = line.split()
            id = lineContents[0]

            if id == ".":
                continue
            else:
                dad = lineContents[13]
                mom = lineContents[14]

                if mom != ".":
                    ped_graph.add_edge(mom, id)
                if dad != ".":
                    ped_graph.add_edge(dad, id)
                if mom == "." and dad == ".":
                    ped_graph.add_node(id)

for x, y in it.combinations(nx.nodes(ped_graph), 2):
    relatedness = 0
    if nx.has_path(ped_graph, source = x, target = y):
        paths = list(nx.all_simple_paths(ped_graph, source = x, target = y))
        for each_path in paths:
            path_length = len(each_path) - 1
            relatedness += 1/pow(2, path_length)
    print(x + ' ' + y + ' ' + str(relatedness))

