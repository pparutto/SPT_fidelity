from fiji.plugin.trackmate import TrackMate, Settings, Model, Logger
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
simu_dir = "/mnt/data2/SPT_method/simu/"

#sys.path.append(simu_dir + "/ER")
#sys.path.append(simu_dir + "/mito")
sys.path.append(simu_dir + "/lines/sim")
#sys.path.append(simu_dir + "/hex/sim")
#sys.path.append(simu_dir + "/hex_deci/sim")


#sys.path.append("/mnt/data4/SPT_method_moved_for_space/yutong_240123/240123_Yutong_dATL_20ms/cell6/sim")

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
		for i, ln in enumerate(f.readlines()):
			ln = ln.rstrip("\n").split(",")
			spt = Spot(float(ln[2]), float(ln[3]), 0.0, 0.0, 0.0, "")
			spt.putFeature("POSITION_T", float(ln[1]))
			spt.putFeature("SNR", 0.0)
			spt.putFeature("MEAN_INTENSITY", 0.0)
			spt.putFeature("IDX", i)
			model.addSpotTo(spt, int(round(float(ln[1]) / DT)))
	return DT


todo_dirs = []
for root, dirs, files, in os.walk(base_dir):
	if not any([e in root for e in exclude]):
		if spot_fname in files:
			todo_dirs.append(path.join(root, root))

imp = None
cd = None
cost_f = None


for cpt, exp_path in enumerate(todo_dirs):
	exp_fname = exp_path.split("/")[-3]

	if "struct_line_dist=31_pxsize=0.024195525_poly.poly" not in exp_path:
		continue

	if "/2/" not in exp_path:
		continue

	#if "hexnet_75_100" not in exp_fname:
	#	continue

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
	print(cur_dist_fname)
	if not path.isfile(cur_dist_fname):
		print("  Skipped: no distance file found")
		imp.changes = False
		imp.close()
		continue
	print(exp_path)

	settings = Settings()
	settings.tstart = 0
	settings.tend = dims[3]
	settings.dx = set_dx
	settings.dy = set_dx
	settings.dt = set_dt
	settings.width = dims[0]
	settings.height = dims[1]

	if cd == None:
		print("Loading distances")
		cd = ComponentDistancesTime(cur_dist_fname, imp, settings.width, settings.height, settings.dx)
	else:
		cd.clear_spots_comps()
	cost_f = ReachableDistCostFunctionTime(cd)

	if spots_type == "TRACKMATE":
		fname = path.join(exp_path, "trackmate", spot_fname.format(mask=mask))
	else:
		fname = path.join(exp_path, spot_fname.format(mask=mask))

	print(fname)

	if not path.isfile(fname):
		print("  Skipped: spot file not found")
		continue

	model = Model()
	model.setLogger(Logger.IJ_LOGGER)
	model.setPhysicalUnits("µm", "ms")

	set_dt = load_spots_simu(exp_path, spot_fname, param_fname, model, settings)
	settings.dt = set_dt

	print(settings.dx, settings.dy, settings.dt, settings.tstart, settings.tend, settings.width, settings.height)

	cnt = 0
	spots_to_rm = []
	for s in model.getSpots().iterator(True):
		pos = [s.getFeature("POSITION_X"), s.getFeature("POSITION_Y")]
		p = [s.getFeature("FRAME"), int(pos[0] // set_dx), int(pos[1] // set_dx)]
		s.putFeature("PX_X", p[1])
		s.putFeature("PX_Y", p[2])
		s.putFeature("SQDIST_TO_PX", (pos[0] - (p[1] * set_dx + set_dx / 2)) ** 2 + (pos[1] - (p[2] * set_dx + set_dx / 2)) ** 2)
		assert(s.getFeature("SQDIST_TO_PX") <= 2 * set_dx**2)
		cnt += 1

	print("REMOVING {} over {} spots".format(len(spots_to_rm), cnt))
	for s in spots_to_rm:
		model.removeSpot(s)

	frames_spts = {}
	spts = []
	cnt = 0
	spots_to_rm = []
	for s in model.getSpots().iterator(True):
		fr = int(s.getFeature("FRAME"))
		spts.append(s)
		if fr not in frames_spts:
			frames_spts[fr] = []
		frames_spts[fr].append(int(s.getFeature("IDX")))

	spts = sorted(spts, key=lambda s: s.getFeature("IDX"))

	trackmate = TrackMate(model, settings)
	trackmate.setNumThreads(4)

	cd.preprocess_spots(model.getSpots())


	p_DISTANCE = max(p_LINKING_MAX_DISTANCES)
	p_GAP_FRAME = 0
	gap_distance = 0.0
	
	tmp = spot_fname.format(mask=mask)
	if tmp.endswith(".csv"):
		tmp = tmp[:-len(".csv")]
	outFname = path.join(exp_path, "ambig_struct_{struct_max_dist}_dist={dist}_distgap={distgap}_framegap={framegap}.csv".format(fname=tmp, struct_max_dist=struct_max_dist, dist=p_DISTANCE, distgap=gap_distance, framegap=p_GAP_FRAME))

	if not force and path.isfile(outFname):
		print("  Skipped")
		continue

	res = []
	for i in range(len(spts)):
		res.append([])
		fr = int(spts[i].getFeature("FRAME"))
		if fr+1 not in frames_spts:
			continue

		for j in frames_spts[fr+1]:
			ed = sqrt(spts[i].squareDistanceTo(spts[j]))
			if ed < p_DISTANCE:
				gd = cost_f.linkingCost(spts[i], spts[j])
				res[-1].append((j, ed, sqrt(gd)))

	#================= EXPORT TRACKS
	fm = model.getFeatureModel()
	with open(outFname, 'w') as f:
		for i in range(len(res)):
			if len(res[i]) == 0:
				continue
			f.write("{},{}\n".format(i, len(res[i])))
			for elts in res[i]:
				f.write("{},{},{}\n".format(elts[0], elts[1], elts[2]))

	#if imp:
	#	imp.changes = False
	#	imp.close()
	#	imp = None
	#cost_f = None
	#cd = None

print("done")
