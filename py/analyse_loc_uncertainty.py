#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct  1 17:03:27 2025

@author: pierre
"""
import numpy as np

base_dir = "/mnt/data4/"
files = ["SPT_fidelity2024_data/SPT_fidelity2024_data_raw/recordings/ERES/roger/Hela_250226/C1-250226_HeLa_Sec13_SNAP_GFP_Sec61_Halo_KDEL_250nM_PAJF646_c9.nd2/C1-250226_HeLa_Sec13_SNAP_GFP_Sec61_Halo_KDEL_250nM_PAJF646_c9.nd2_preview_thunderstorm.csv",
         "SPT_fidelity2024_data/SPT_fidelity2024_data_raw/recordings/dATL_HaloER/C2-cell6_405-58mW_MMStack_Pos0_c.ome_thunderstorm.csv",
         "SPT_fidelity2024_data/SPT_fidelity2024_data_raw/recordings/IB/C2-240124_Halo_cell3_MMStack_Pos0_c.ome_thunderstorm.csv",
         "SPT_fidelity2024_data/SPT_fidelity2024_data_raw/recordings/ineuron_HaloCyto/C1-290424-Image 7_1_SPT_thunderstorm.csv",
         "SPT_fidelity2024_data/SPT_fidelity2024_data_raw/recordings/Sec61b/C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_BSA_004.czi_thunderstorm.csv",
         "SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/C1-cell5_2_10ms/C3-cell5_2_10ms_MMStack_Pos0.ome_thunderstorm.csv"]
names = ["ERES", "dATL", "IB", "cyto", "Sec61b", "APP"]


for i,fname in enumerate(files):
    dat = np.loadtxt(base_dir + fname, delimiter=",", skiprows=1)[:, 3:5]
    dat = dat[np.argsort(dat[:,0]), :]
    keep = int(0.25 * dat.shape[0])
    dat = dat[-keep:,:]
    print("{}: {:.3f} / {:.3f} n={}".format(names[i], np.mean(dat[:,1]), np.std(dat[:,1]), dat.shape[0]))