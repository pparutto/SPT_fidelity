from fiji.plugin.trackmate import TrackMate, Model, Settings, Logger
from fiji.plugin.trackmate.tracking.jaqaman import SimpleSparseLAPTrackerFactory
from fiji.plugin.trackmate.tracking.jaqaman.costfunction import ComponentDistancesTime, ReachableDistCostFunctionTime

from ij import IJ
from fiji.plugin.trackmate import Spot

import os
import sys
from os import path

#default value
out_name_cats = [-1]
force = False

#change this path to point to the folder containing the raw recordings
#simu_dir = "/mnt/data4/SPT_fidelity2024_data/SPT_fidelity2024_data_raw/simu/mock"
simu_dir = "/mnt/data2/SPT_method/simu"

#sys.path.append(simu_dir + "/ER")
#sys.path.append(simu_dir + "/mito")
#sys.path.append(simu_dir + "/lines/sim")
sys.path.append(simu_dir + "/hex/sim")

from config_tracking import *

wdur = struct_w_dur

def load_spots_simu(base_dir, spot_fname, params_fname, model, settings):
	DT = None
	nframes_ok = False
	with open(path.join(base_dir, params_fname), 'r') as f:
		for line in f.readlines():
			if line.startswith("pixelSize"):
				pxsize = float(line.rstrip("\n").split(",")[1].strip(" "))
				settings.dx = pxsize
				settings.dy = pxsize
			elif line.startswith("DT,") or line.startswith("DT (s)"):
				DT = float(line.rstrip("\n").split(",")[1].strip(" "))
				settings.dt = DT
			elif line.startswith("FOVWidth"):
				settings.width = int(line.rstrip("\n").split(",")[1].strip(" "))
			elif line.startswith("FOVHeight"):
				settings.height = int(line.rstrip("\n").split(",")[1].strip(" "))
			elif line.startswith("Nframes") or line.startswith("length"):
				nframes_ok = True
				settings.tend = int(line.rstrip("\n").split(",")[1].strip(" "))

	assert(DT)
	assert(nframes_ok)
	with open(path.join(base_dir, spot_fname), 'r') as f:
		for ln in f.readlines():
			ln = ln.rstrip("\n").split(",")
			spt = Spot(float(ln[2]), float(ln[3]), 0.0, 0.0, 0.0, "")
			spt.putFeature("POSITION_T", float(ln[1]))
			model.addSpotTo(spt, int(round(float(ln[1]) / DT)))
	return DT


todo_dirs = []
for root, dirs, files, in os.walk(base_dir):
	if not any([e in root for e in exclude]):
		if "trajs.csv" in files:
			todo_dirs.append(path.join(root, root))

imp = None
cd = None
cost_f = None

#failed = ["1_1_0.0056_60000", "1_15_0.25_4000", "1_20_0.146_3000", "1_35_0.7656_1715", "1_1_0.3906_60000", "1_10_0.0056_6000", "1_50_0.5625_1200", "1_45_0.5625_1334", "1_15_0.0006_4000", "1_35_0.25_1715", "1_30_0.25_2000",
#				"1_50_0.01_1200"]
failed = []

for cpt, exp_path in enumerate(todo_dirs):
	exp_fname = exp_path.split("/")[-3]
	
	#if "line_dist=31" not in exp_fname:
	#	continue

	if "hexnet_38_100" not in exp_fname:
		continue

	if "/1/" not in exp_path:
		continue
		
	
	#if any([f in exp_path for f in failed]):
	#	continue


	exp_fname_no_chan = exp_fname
	if exp_fname[0] == "C" and exp_fname[2] == "-":
		exp_fname_no_chan = exp_fname_no_chan[3:]

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
		imp.changes = False
		imp.close()
		continue


	settings = Settings()
	settings.tstart = 0
	settings.tend = dims[3]
	settings.dx = set_dx
	settings.dy = set_dx
	settings.dt = set_dt
	settings.width = dims[0]
	settings.height = dims[1]

	#, settings.tend
	if cd == None:
		print("Loading distances")
		cd = ComponentDistancesTime(cur_dist_fname, imp, settings.width, settings.height, settings.dx)
	else:
		cd.clear_spots_comps()
	cost_f = ReachableDistCostFunctionTime(cd)

	fname = path.join(exp_path, spot_fname.format(mask=mask))
	if not path.isfile(fname):
		print("  Skipped: spot file not found")
		continue

	model = Model()
	model.setLogger(Logger.IJ_LOGGER)
	model.setPhysicalUnits("µm", "ms")

	set_dt = load_spots_simu(exp_path, spot_fname, param_fname, model, settings)
	settings.dt = set_dt

	nfailed = 0
	for s in model.getSpots().iterator(True):
		pos = [s.getFeature("POSITION_X"), s.getFeature("POSITION_Y")]
		p = [s.getFeature("FRAME"), int(pos[0] // set_dx), int(pos[1] // set_dx)]

		if cd.getComponent(cd.getWindowIdxs(int(p[0]))[0], [p[1], p[2]]) == 0:
			failed.append(exp_path.split("/")[-1])
			nfailed += 1

		s.putFeature("PX_X", p[1])
		s.putFeature("PX_Y", p[2])
		s.putFeature("SQDIST_TO_PX", (pos[0] - (p[1] * set_dx + set_dx / 2)) ** 2 + (pos[1] - (p[2] * set_dx + set_dx / 2)) ** 2)
		assert(s.getFeature("SQDIST_TO_PX") <= 2 * set_dx**2)

	if nfailed > 0:
		print(exp_path.split("/")[-1], nfailed)

	#if imp:
	#	imp.changes = False
	#	imp.close()
	#	imp = None
		
	#cost_f = None
	#cd = None


print("done")
