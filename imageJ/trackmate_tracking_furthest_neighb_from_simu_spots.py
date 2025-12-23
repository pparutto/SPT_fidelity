from fiji.plugin.trackmate import TrackMate, Settings, Model, Logger, Spot
from fiji.plugin.trackmate.tracking.kdtree import FurthestNeighborTrackerFactory

from ij import IJ

import os
import sys
from os import path

import random

def read_parameters(f):
	res = {}
	for line in f:
		line = line.rstrip("\n").split(",")
		res[line[0].split(" ")[0]] = line[1].lstrip()
	return res

#default value
out_name_cats = [-1]

split_x = None
spot_fname = "trajs.csv"


#change this path to point to the folder containing the raw recordings
#simu_dir = "/mnt/data4/SPT_fidelity2024_data/SPT_fidelity2024_data_raw/simu/mock"
#simu_dir = "/mnt/data2/SPT_fidelity2024_data/SPT_fidelity2024_data_raw/simu"

#sys.path.append(simu_dir + "/freespace")

#simu_dir = "/mnt/data2/SPT_method/simu/freespace/density3/"
simu_dir = "/mnt/data4/SPT_fidelity2024_data/SPT_fidelity2024_simu_raw/simu/freespace"
sys.path.append(simu_dir)


#sys.path.append(simu_dir + "/ER")
#sys.path.append(simu_dir + "/mito")

from config_tracking import *

filenames = []
for root, dirs, files, in os.walk(base_dir):
	filenames.extend([path.join(root, f) for f in files if f == spot_fname])
random.shuffle(filenames)

ndone = 0
for cpt,fname in enumerate(filenames):
	print("Processing[{}/{}]: {}".format(cpt + 1, len(filenames), fname))

	exp_path = "/".join(fname.split("/")[:-1])
	
	#if int(fname.split("/")[-3]) != 2:
	#	continue

	exp_fname = fname.split("/")[-1]

	skip = True
	for p_DISTANCE in p_LINKING_MAX_DISTANCES:
			outFname = path.join(exp_path, link_fn_fname.format(fname=exp_fname, dist=p_DISTANCE))
			if not path.isfile(outFname):
				skip = False
	if skip:
		print("  Skipped")
		continue

	ps = {}
	with open(path.join(exp_path, "params.csv"), 'r') as f:
		ps = read_parameters(f)

	model = Model()
	model.setLogger(Logger.IJ_LOGGER)
	model.setPhysicalUnits("µm", "ms")

	settings = Settings()
	settings.tstart = 0

	if "Nframes" in ps:
		settings.tend = int(ps["Nframes"]) - 1
		settings.nframes = int(ps["Nframes"])
	elif "length" in ps:
		settings.tend = int(ps["length"]) - 1
		settings.nframes = int(ps["length"])
	settings.dx = float(ps["pixelSize"])
	settings.dy = float(ps["pixelSize"])
	settings.dt = float(ps["DT"])
	if "FOVWidth" in ps:
		settings.width = int(ps["FOVWidth"])
	elif "width" in ps:
		settings.width = int(ps["width"])
	if "FOVHeight" in ps:
		settings.height = int(ps["FOVHeight"])
	elif "height" in ps:
		settings.height = int(ps["height"])

	print(settings.dx, settings.dy, settings.dt)

	frames = []
	with open(os.path.join(fname), 'r') as f:
		for i, ln in enumerate(f.readlines()):
			ln = ln.rstrip("\n").split(",")
			frame = int(round(float(ln[1]) / float(ps["DT"])))
			frames.append(frame)
			spt = Spot(float(ln[2]), float(ln[3]), 0.0, 0.05, 0, "ID{}".format(i))
			spt.putFeature("POSITION_T", float(ln[1]))
			model.addSpotTo(spt, frame)

	if mask:
		cur_fname = fname.split("/")[-4]
		cur_fname = cur_fname[len("C2-"):cur_fname.find(".czi")+4]
		print(cur_fname)

		mask_path = "/".join(fname.split("/")[:-4])
		if stab_mask_fname:
			mask_f = path.join(mask_path, stab_mask_fname.format(fname=cur_fname))
		else:
			mask_f = path.join(mask_path, mask_fname.format(fname=cur_fname))
		print(" Masking spots: " + mask_f)
		if not path.isfile(mask_f):
			print(" [ERROR] Mask file not found : " + mask_f)
			continue

		IJ.open(mask_f)
		mask_imp = IJ.getImage()

		spots_to_rm = []
		for s in model.getSpots().iterator(True):
			pos = [s.getFeature("POSITION_X"), s.getFeature("POSITION_Y")]
			p = [int(s.getFeature("FRAME")), int(pos[0] // set_dx), int(pos[1] // set_dx)]
			if mask_imp.getProcessor().getPixel(p[1], p[2]) == 0:
				spots_to_rm.append(s)
				continue

		print("  REMOVING {} spots not in structure".format(len(spots_to_rm)))
		with open(path.join(exp_path, "spots_not_in_struct.csv"), "w") as f:
			for s in spots_to_rm:
				f.write("{}\n".format(s.ID()))
				model.removeSpot(s)

		mask_imp.close()


	trackmate = TrackMate(model, settings)
	trackmate.setNumThreads(4)

	#======= TRACKING
	for p_DISTANCE in p_LINKING_MAX_DISTANCES:
		outFname = path.join(exp_path, link_fn_fname.format(fname=exp_fname, dist=p_DISTANCE))

		if path.isfile(outFname):
			print("  Skipped")
			continue

		# Configure tracker
		settings.trackerFactory = FurthestNeighborTrackerFactory()
		settings.trackerSettings = settings.trackerFactory.getDefaultSettings()
		settings.trackerSettings['LINKING_MAX_DISTANCE'] = p_DISTANCE

		trackmate = TrackMate(model, settings)
		trackmate.setNumThreads(4)

		ok = trackmate.execTracking()
		if not ok:
			print(str(trackmate.getErrorMessage()))
			continue
		ok = trackmate.computeTrackFeatures(True)
		if not ok:
			print(str(trackmate.getErrorMessage()))
			continue
		ok = trackmate.execTrackFiltering(True)
		if not ok:
			print(str(trackmate.getErrorMessage()))
			continue
		ok = trackmate.computeEdgeFeatures(True)
		if not ok:
			print(str(trackmate.getErrorMessage()))
			continue

		#================= EXPORT TRACKS
		ndone += 1
		fm = model.getFeatureModel()
		with open(outFname, 'w') as f:
			f.write('Traj. id, Spot id, x (mum), y (mum), time (sec), frame\n')
			for tid in model.getTrackModel().trackIDs(True):
			    track = sorted(model.getTrackModel().trackSpots(tid), key=lambda s: s.getFeature('FRAME'))
			    for spot in track:
			        sid = spot.ID()

			        x = spot.getFeature('POSITION_X')
			        y = spot.getFeature('POSITION_Y')
			        t = spot.getFeature('POSITION_T')
			        fr = spot.getFeature('FRAME')

			        f.write(",".join([str(e) for e in [tid, sid, x, y, t, fr]]) + "\n")

		model.clearTracks(True)
	model.clearSpots(True)

print("done: {}".format(ndone))
