from fiji.plugin.trackmate import TrackMate, Settings, Model, Logger, SpotCollection
from fiji.plugin.trackmate.tracking.jaqaman import SimpleSparseLAPTrackerFactory
from fiji.plugin.trackmate.tracking.jaqaman.costfunction import ComponentDistancesTime, ReachableDistCostFunctionTime

from ij import IJ
from fiji.plugin.trackmate import Spot


import os
import sys
from os import path
from math import sqrt

#default value
out_name_cats = [-1]
force = False


#change this path to point to the folder containing the raw recordings
#simu_dir = "/mnt/data4/SPT_fidelity2024_data/SPT_fidelity2024_data_raw/simu/mock"

#sys.path.append(simu_dir + "/ER")
#sys.path.append(simu_dir + "/mito")

simu_dir = "/mnt/data2/SPT_method/simu/"

#sys.path.append(simu_dir + "/ER")
#sys.path.append(simu_dir + "/mito")
sys.path.append(simu_dir + "/lines/sim")
#sys.path.append(simu_dir + "/hex/sim")
#sys.path.append(simu_dir + "/hex_deci/sim")

from config_tracking import *

wdur = struct_w_dur

todo_dirs = []
for root, dirs, files, in os.walk(base_dir):
	if not any([e in root for e in exclude]):
		if "trajs.csv" in files:
			todo_dirs.append(path.join(root, root))

cd = None
cost_f = None
exp_fname_id = -1
imp = None

for cpt, exp_path in enumerate(todo_dirs):
	exp_fname = exp_path.split("/")[-3]

	if "line_dist=31" not in exp_fname:
		continue
		
	if "1_35_1_1715" not in exp_path:
		continue
	
	print("Processing[{}/{}]: {}".format(cpt + 1, len(todo_dirs), exp_fname))
	
	exp_fname_no_chan = exp_fname
	if exp_fname[0] == "C" and exp_fname[2] == "-":
		exp_fname_no_chan = exp_fname_no_chan[3:]
	print(exp_fname_no_chan)

	comp_f = path.join(base_dir, comp_fname_win.format(fname=exp_fname_no_chan))
	if not path.isfile(comp_f):
		print("   ERROR: {}".format(comp_f))
		continue

	if imp == None:
		IJ.open(comp_f)
		imp = IJ.getImage()
		dims = imp.getDimensions()

	cur_dist_fname = path.join(base_dir, dist_fname.format(fname=exp_fname_no_chan, max_dist=struct_max_dist, w_dur=struct_w_dur, w_ovlp=struct_w_ovlp))
	if not path.isfile(cur_dist_fname):
		print("  Skipped: no distance file found")
		continue
	print(exp_path)

	if cd == None:
		print("Loading distances")
		cd = ComponentDistancesTime(cur_dist_fname, imp, 420, 420, set_dx)
	else:
		cd.clear_spots_comps()
	cost_f = ReachableDistCostFunctionTime(cd)

	for tr_d in p_LINKING_MAX_DISTANCES:
		cd.clear_spots_comps()
		cost_f = ReachableDistCostFunctionTime(cd)

		fname = path.join(exp_path, link_fname.format(fname=exp_fname_no_chan, dist=tr_d, distgap=0.0, framegap=0))
		print(fname)
		if not path.isfile(fname):
			print("  Skipped: spot file not found")
			#imp.changes = False
			#imp.close()
			continue

		spts = SpotCollection()
		tab = []
		with open(fname, 'r') as f:
			f.readline()
			for line in f:
				line = line.split(",")
				pos = [float(line[2]), float(line[3])]
				p = [int(pos[0] // set_dx), int(pos[1] // set_dx)]
				spt = Spot(pos[0], pos[1], 0.0, 0.0, 0.0, "ID{}".format(len(tab)))
				spt.putFeature("TRID", int(line[0]))
				spt.putFeature("PX_X", p[0])
				spt.putFeature("PX_Y", p[1])
				spt.putFeature("SQDIST_TO_PX", (pos[0] - (p[0] * set_dx + set_dx / 2)) ** 2 + (pos[1] - (p[1] * set_dx + set_dx / 2)) ** 2)
				assert(spt.getFeature("SQDIST_TO_PX") <= 2 * set_dx**2)
				tab.append(spt)
				spts.add(spt, int(float(line[5])))

		
		cd.preprocess_spots(spts)

		outFname = exp_path + "/tracks_gdist_dist={dist}_structdist={struct_max_dist}.csv".format(
			dist=tr_d, struct_max_dist=struct_max_dist)

		if not force and path.isfile(outFname):
			print("  Skipped: {} already exists".format(outFname))
			continue

		res = []
		for i in range(len(tab) - 1):
			if tab[i].getFeature("TRID") != tab[i+1].getFeature("TRID"):
				res.append(-1.0)
			else:
				res.append(sqrt(cost_f.linkingCost(tab[i], tab[i+1])))

		#================= EXPORT
		with open(outFname, 'w') as f:
			for i in range(len(res)):
				f.write("{}\n".format(res[i]))

	#/!!!!!\
	cost_f = None


print("done")