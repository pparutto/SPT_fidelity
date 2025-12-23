#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri May 16 10:14:26 2025

@author: pierre
"""

import os
import numpy as np

basedir = "/mnt/data2/SPT_method/simu/lines/sim/struct_line_dist=31_pxsize=0.024195525_poly.poly"
#basedir = "/mnt/data4/SPT_fidelity2024_data/SPT_fidelity2024_data_raw/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly.poly/3"
#basedir = "/mnt/data2/SPT_method/simu/hex/sim"
#basedir = "/mnt/data2/SPT_method/simu/hex_deci/a/sim"
outfname = "trajs_cliped_recent.csv"

for root, dirs, files, in os.walk(basedir):
    if "trajs.csv" not in files:
        continue

    #if "hexnet_38_100_poly.poly/1/1_35_0.0006_1715" not in root:
    #    continue

    if outfname in files:
        print("Skipping: already done")
        continue

    print("Processing:", root)

    simreg = None
    pxsize = None
    with open("/".join([root, "params.csv"]), 'r') as f:
        for line in f:
            if line.startswith("SimReg"):
                simreg = np.array([int(e) for e in line.rstrip("\n").split(",")[1:]])
            if line.startswith("pixelSize"):
                pxsize = float(line.rstrip("\n").split(",")[-1])
    assert(not simreg is None and pxsize)

    simreg = simreg * pxsize
    tab = np.loadtxt("/".join([root, "trajs.csv"]), delimiter=",")
    prevN = tab.shape[0]
    tab[:, 2:4] = tab[:, 2:4] - simreg[0:2]
    simreg[2:4] = simreg[2:4] - simreg[0:2]
    
    tab = tab[np.logical_and(np.logical_and(tab[:,2] >= 0, tab[:,3] >= 0),
                             np.logical_and(tab[:,2] <= simreg[2], tab[:,3] <= simreg[3])), :]
    print("Size: {}/{}".format(tab.shape[0], prevN))
    assert(np.all(np.logical_and(np.logical_and(tab[:,2] >= 0, tab[:,3] >= 0),
                             np.logical_and(tab[:,2] <= simreg[2], tab[:,3] <= simreg[3]))))

    with open("/".join([root, outfname]), 'w') as f:
        for i in range(tab.shape[0]):
            f.write("{:d},{:.6f},{:.5f},{:.5f}\n".format(int(tab[i,0]), *tab[i,1:]))
