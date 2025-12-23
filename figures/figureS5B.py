#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 10 19:15:10 2022

@author: pierre
"""

from matplotlib import pyplot as plt
import numpy as np

from scipy.stats import ttest_ind
from math import pi

infiles = ["../analysis_data/FRAP/2022.03.29-ER Membrane FRAP/out/log.txt",
           "../analysis_data/FRAP/2022.02.04 - ER Membrane FRAP/out/log.txt",
           "../analysis_data/FRAP/2022.04.12 - ER membrane FRAP/out/log.txt"]

t12_max = 300

res = {"BSA": {"tau": [], "t12": [], "r": [], "D": []}, "OA": {"tau": [], "t12": [], "r": [], "D": []}}
for infile in infiles:
    with open(infile, 'r') as f:
        fname = None
        dat = None
        tau = None
        t12 = None
        r = None
        pxsize = None
        for line in f:
            line = line.rstrip("\n")
            if line.endswith("tif") or line.endswith(".czi"):
                if tau != None:
                    if t12 < t12_max:
                        res[dat]["tau"].append(tau)
                        res[dat]["t12"].append(t12)
                        res[dat]["r"].append(r)
                        res[dat]["D"].append(0.224 * r**2 / t12)
                        print("{}: {:.3f}".format(fname, res[dat]["D"][-1]))
                tau = None
                r = None
                t12 = None
                pxsize = None
                if "1in5 BSA" in line:
                    dat = "BSA"
                    fname = line
                elif "1in5 OA":
                   dat = "OA"
                   fname = line
                else:
                    assert(False)

            elif line.startswith("p[0]"):
                tau = float(line.split(":")[1].split(";")[0])
            elif line.startswith("t 1/2"):
                t12 = float(line.split(" ")[-1])
            elif line.startswith("ROI size"):
                vs = [float(e) for e in line.split(":")[1].split(",")]
                r = np.mean(vs) * pxsize
            elif line.startswith("pxsize"):
                pxsize = float(line.split(":")[1])

        if tau != None:
            if t12 < t12_max:
                res[dat]["tau"].append(tau)
                res[dat]["t12"].append(t12)
                res[dat]["r"].append(r)
                res[dat]["D"].append(0.224 * r**2 / t12)
                print("{}: {:.3f}".format(fname, res[dat]["D"][-1]))



plt.figure(figsize=(5,5))
plt.boxplot([res["BSA"]["t12"], res["OA"]["t12"]])
for i, k in enumerate(["BSA", "OA"]):
    x = np.random.normal(i+1, 0.04, size=len(res[k]["t12"]))
    plt.plot(x, res[k]["t12"], 'r.', alpha=0.4)
plt.xticks(range(1,3), ["BSA", "OA"])
plt.ylabel("t-half (sec)")
plt.savefig("/tmp/frap_halflife.png")

print("t1/2 (s)")
for k in ["BSA", "OA"]:
    print("{}: {:.2f} ± {:.2f} (n={})".format(k, np.mean(res[k]["t12"]), np.std(res[k]["t12"]), len(res[k]["t12"])))
print("t-test p={:.3f}".format(ttest_ind(res["BSA"]["t12"], res["OA"]["t12"]).pvalue))