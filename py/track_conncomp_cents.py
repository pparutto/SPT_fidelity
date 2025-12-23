#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 14 10:21:35 2025

@author: pierre
"""

import numpy as np
from skimage.io import imread, imsave
from skimage.measure import label, regionprops

#base_dir = "/mnt/data2/SPT_method/Mito/motion_tracking/C1-210806_COS7_4MTS-mNG_4MTS-HAlo-PA646_15min2uMFCCP_3"
#inf = "C2-210806_COS7_4MTS-mNG_4MTS-HAlo-PA646_15min2uMFCCP_3.czi.tif_avg17_Simple Segmentation_bin_openCirc1px_stabN=3.tif"
#outf = "C2-210806_COS7_4MTS-mNG_4MTS-HAlo-PA646_15min2uMFCCP_3.czi.tif_avg17_Simple Segmentation_bin_openCirc1px_stabN=3_compstrck.tif"

base_dir = "/mnt/data2/SPT_method/Mito/motion_tracking/C2-210311_COS67_TOM20-Halo_Mito-mNeonG_untreated_3"
inf = "C2-210311_COS67_TOM20-Halo_Mito-mNeonG_untreated_3.czi.tif_avg17_crop_Simple Segmentation_bin_openCirc1px.tif"
outf = "C2-210311_COS67_TOM20-Halo_Mito-mNeonG_untreated_3.czi.tif_avg17_crop_Simple Segmentation_bin_openCirc1px_compstrck.tif"

frame_gap = 1
comp_dist_sq = 75

im = imread("{}/{}".format(base_dir, inf))
labs = label(im[0])
prps = regionprops(labs)
for p in prps:
    p.frame = 0
    p.next = []

prev_comps = prps
for i in range(1, im.shape[0]):
    labs = label(im[i])
    prps = regionprops(labs)

    prev_cents = np.array([(u, pc.frame, *pc.centroid) for u,pc in enumerate(prev_comps)
                           if i - prev_comps[u].frame <= frame_gap])

    for prp in prps:
        prp.frame = i
        prp.next = []
        prev_comps.append(prp)

        dsts = np.sum((np.array([i, *prp.centroid]) - prev_cents[:,1:4])**2, axis=1)
        idx = np.argmin(dsts)

        if dsts[idx] < comp_dist_sq:
            prev_comps[int(prev_cents[idx,0])].next.append(len(prev_comps) - 1)

done = np.zeros(len(prev_comps), dtype="bool")
comp_id = np.zeros(len(prev_comps), dtype="int")
k = 1
for i in range(len(prev_comps)):
    if done[i] == True:
        continue

    done[i] = True
    comp_id[i] = k

    todo = prev_comps[i].next
    while todo != []:
        cur = todo[0]
        todo = todo[1:]
        assert(done[cur] == False) # or comp_id[cur] == k

        done[cur] = True
        comp_id[cur] = k
        todo.extend(prev_comps[cur].next)

    k += 1

res = np.zeros(im.shape)
for i in range(len(comp_id)):
    pr = prev_comps[i]
    res[pr.frame, pr.coords[:,0], pr.coords[:,1]] = comp_id[i]

imsave("{}/{}".format(base_dir, outf), res, check_contrast=False)