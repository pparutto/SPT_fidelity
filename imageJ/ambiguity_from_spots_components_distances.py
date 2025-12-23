from fiji.plugin.trackmate import TrackMate, Model, Settings, Logger
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
#record_dir = "/mnt/data4/SPT_fidelity2024_data/SPT_fidelity2024_data_raw/recordings"

#sys.path.append(record_dir + "/TOMM20")
#sys.path.append(record_dir + "/Sec61b_BSA_OA")
#sys.path.append(record_dir + "/Sec61b")
#sys.path.append(record_dir + "/ineuron_HaloCyto")
#sys.path.append(record_dir + "/IB+APP")
#sys.path.append(record_dir + "/IB")
#sys.path.append(record_dir + "/HaloMito")
#sys.path.append(record_dir + "/dATL_HaloER")
#sys.path.append(record_dir + "/APP")

sys.path.append("/mnt/data4/SPT_method_moved_for_space/yutong_240123/240122_Yutong_cos123-716-717-418_HPA646-3ul_6ms/cell1")

from config_tracking import *

wdur = struct_w_dur

def load_spots_trackmate(f, model):
	head = f.readline().rstrip("\n").split(",")
	frame_idx = head.index("FRAME")
	x_idx = head.index("POSITION_X")
	y_idx = head.index("POSITION_Y")
	for i, ln in enumerate(f.readlines()):
		ln = ln.rstrip("\n").split(",")
		frame = int(float(ln[frame_idx]))
		spt = Spot(float(ln[x_idx]), float(ln[y_idx]), 0.0, 0.0, 0.0, "ID{}".format(i))
		spt.putFeature("IDX", i)
		model.addSpotTo(spt, frame)

spot_parsers = {"TRACKMATE": load_spots_trackmate}


todo_dirs = []
for exp_dir in os.listdir(out_dir):
	if path.isdir("/".join([out_dir, exp_dir])) and not any([e in exp_dir for e in exclude]):
		todo_dirs.append(exp_dir)


imp = None
cd = None
cost_f = None

exp_fname_id = -1

for cpt, fname in enumerate(todo_dirs):
	exp_fname = fname.split("/")[exp_fname_id]
	exp_path = "/".join([out_dir, exp_fname])

	print("Processing[{}/{}]: {}".format(cpt + 1, len(todo_dirs), exp_fname))

	exp_fname_no_chan = exp_fname
	if exp_fname[0] == "C" and exp_fname[2] == "-":
		exp_fname_no_chan = exp_fname_no_chan[3:]

	comp_f = path.join(base_dir, comp_fname_win.format(fname=exp_fname_no_chan[:-len(".czi.tif")]))
	if not path.isfile(comp_f):
		print("   ERROR: {}".format(comp_f))
		continue

	IJ.open(comp_f)
	imp = IJ.getImage()
	dims = imp.getDimensions()

	cur_dist_fname = path.join(base_dir, dist_fname.format(fname=exp_fname_no_chan[:-len(".czi.tif")], max_dist=struct_max_dist, w_dur=struct_w_dur, w_ovlp=struct_w_ovlp))
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

	cd = ComponentDistancesTime(cur_dist_fname, imp, settings.width, settings.height, settings.dx)
	for p_DIAMETER in p_DETECTION_BLOB_DIAMETERS:
		for spot_th in ths:
			cd.clear_spots_comps()
			cost_f = ReachableDistCostFunctionTime(cd)

			if spots_type == "TRACKMATE":
				fname = path.join(exp_path, spot_fname.format(mask=mask, spot_rad=p_DIAMETER, spot_th=spot_th))
			else:
				assert(False)

			print(fname)

			if not path.isfile(fname):
				print("  Skipped: spot file not found")
				continue

			model = Model()
			model.setLogger(Logger.IJ_LOGGER)
			model.setPhysicalUnits("µm", "ms")

			with open(fname, 'r') as f:
				spot_parsers[spots_type](f, model)

			print(settings.dx, settings.dy, settings.dt, settings.tstart, settings.tend, settings.width, settings.height)

			cnt = 0
			spots_to_rm = []
			for i,s in enumerate(model.getSpots().iterator(True)):
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

			#assert(False)

			spts = sorted(spts, key=lambda s: s.getFeature("IDX"))

			trackmate = TrackMate(model, settings)
			trackmate.setNumThreads(4)

			cd.preprocess_spots(model.getSpots())


			p_DISTANCE = max(p_LINKING_MAX_DISTANCES)
			p_GAP_FRAME = 0
			gap_distance = 0.0

			ambig_fname = "ambig_struct_mask={mask}_rad={spot_rad}_th={spot_th}_maxdist={struct_max_dist}.csv"
			outFname = exp_path + "/" + ambig_fname.format(mask=mask, spot_rad=p_DIAMETER, spot_th=spot_th, struct_max_dist=struct_max_dist,
								 						   dist=p_DISTANCE, distgap=gap_distance, framegap=p_GAP_FRAME)

			print(outFname)
			if not force and path.isfile(outFname):
				print("  Skipped: {} already exists".format(outFname))
				continue

			res = []
			for i in range(len(spts)):
				res.append([])
				fr = int(spts[i].getFeature("FRAME"))
				next_fr = fr + 1
				if next_fr not in frames_spts:
					continue

				for j in frames_spts[next_fr]:
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

	if imp:
		imp.changes = False
		imp.close()
		
	#/!!!!!\
	cost_f = None
	cp = None

print("done")
