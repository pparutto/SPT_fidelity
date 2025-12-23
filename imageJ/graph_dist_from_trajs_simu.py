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

from config_tracking import *

wdur = struct_w_dur

def load_params(base_dir, params_fname, settings):
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
	return DT

def load_tracks(base_dir, fname, model):
	with open(path.join(base_dir, fname), 'r') as f:
		f.readline() #skip header line
		for i, ln in enumerate(f.readlines()):
			ln = ln.rstrip("\n").split(",")
			spt = Spot(float(ln[2]), float(ln[3]), 0.0, 0.0, 0.0, "")
			spt.putFeature("TR_ID", int(ln[0]))
			spt.putFeature("POSITION_T", float(ln[4]))
			spt.putFeature("SNR", 0.0)
			spt.putFeature("MEAN_INTENSITY", 0.0)
			spt.putFeature("IDX", i)
			model.addSpotTo(spt, int(float(ln[5])))

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

	if "/1/" not in exp_path:
		continue

	if "dist=31" not in exp_fname:
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

	set_dt = load_params(exp_path, "params.csv", settings)
	settings.dt = set_dt

	print(settings.dx, settings.dy, settings.dt, settings.tstart, settings.tend, settings.width, settings.height)

	trackmate = TrackMate(model, settings)
	trackmate.setNumThreads(4)

	p_GAP_DISTANCE = 0
	p_GAP_FRAME = 0
	for p_DISTANCE in p_LINKING_MAX_DISTANCES:
		trckFname = link_fname.format(fname=exp_fname, dist=p_DISTANCE, distgap="0.0", framegap="0")

		outFname = path.join(exp_path, "gdist_track_{struct_max_dist}_dist={dist}_distgap=0.0_framegap=0.csv".format(
			struct_max_dist=struct_max_dist, dist=p_DISTANCE))
		if not force and path.isfile(outFname):
			print("  Skipped")
			continue

		load_tracks(exp_path, trckFname, model)

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

		cd.preprocess_spots(model.getSpots())

		trcks = {}
		for s in model.getSpots().iterator(True):
			trid = int(s.getFeature("TR_ID"))
			if trid not in trcks:
				trcks[trid] = []
			trcks[trid].append(s)

		for trid in trcks.keys():
			trcks[trid] = sorted(trcks[trid], key=lambda s: s.getFeature("FRAME"))

		gdists = {}
		for trid, tr in trcks.items():
			gdists[trid] = []
			for i in range(len(tr)-1):
				gdists[trid].append((int(tr[i].getFeature("FRAME")), sqrt(cost_f.linkingCost(tr[i], tr[i+1]))))
			gdists[trid].append((int(tr[-1].getFeature("FRAME")), -1))

		#================= EXPORT TRACKS
		with open(outFname, 'w') as f:
			for trid, vs in gdists.items():
				for v in vs:
					f.write("{},{},{}\n".format(trid, v[0], v[1]))
		
		model.clearTracks(True)
		model.clearSpots(True)

	#if imp:
	#	imp.changes = False
	#	imp.close()
	#	imp = None
	#cost_f = None
	#cd = None

print("done")
