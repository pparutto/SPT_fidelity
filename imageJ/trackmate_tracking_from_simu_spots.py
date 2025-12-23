from fiji.plugin.trackmate import TrackMate, Settings, Model, Logger, Spot
from fiji.plugin.trackmate.tracking.jaqaman import SimpleSparseLAPTrackerFactory

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


#change this path to point to the folder containing the raw recordings
#simu_dir = "/mnt/data4/SPT_fidelity2024_data/SPT_fidelity2024_data_raw/simu/mock"
simu_dir = "/mnt/data2/SPT_method/simu"
#sys.path.append(simu_dir + "/freespace_fbm2/density")
#sys.path.append(simu_dir + "/freespace_HMM2/")
#sys.path.append(simu_dir + "/freespace_mixed/")
#sys.path.append(simu_dir + "/freespace")
#sys.path.append(simu_dir + "/ER")
#sys.path.append(simu_dir + "/mito")
sys.path.append(simu_dir + "/lines/sim")
#sys.path.append(simu_dir + "/hex/sim")
#sys.path.append(simu_dir + "/hex_deci/sim")

#sys.path.append("/mnt/data4/SPT_method_moved_for_space/yutong_240123/240123_Yutong_dATL_20ms/cell6/sim")


from config_tracking import *

filenames = []
for root, dirs, files, in os.walk(base_dir):
	filenames.extend([path.join(root, f) for f in files if f == spot_fname])
random.shuffle(filenames)

ndone = 0
for cpt,fname in enumerate(filenames):
	print("Processing[{}/{}]: {}".format(cpt + 1, len(filenames), fname))

	exp_path = "/".join(fname.split("/")[:-1])

	#if int(fname.split("/")[-3]) != 1:
	#	continue

	if "/2/" not in exp_path:
		continue

	#if "1_50_1_1200" not in exp_path:
	#	continue

	exp_fname = fname.split("/")[-1]

	skip = True
	for p_DISTANCE in p_LINKING_MAX_DISTANCES:
		for p_GAP_FRAME in p_MAX_FRAME_GAPS:
			p_GAP_DISTANCE = p_DISTANCE
			if p_GAP_FRAME == 0:
				p_GAP_DISTANCE = 0.0

			outFname = path.join(exp_path, link_fname.format(fname=exp_fname, dist=p_DISTANCE, distgap=p_GAP_DISTANCE, framegap=p_GAP_FRAME))
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


	#ADD fake spots so that the tracking does not skip inexistant frames
	added_fake = 0
	frames = set([int(s.getFeature("FRAME")) for s in model.getSpots().iterator(True)])
	for i in range(min(frames), max(frames)):
		if i not in frames:
			spt = Spot(float("nan"), float("nan"), 0.0, float("nan"), float("nan"), "ID{}".format(i))
			spt.putFeature("POSITION_T", float("nan"))
			model.addSpotTo(spt, i)
			added_fake += 1
	if added_fake > 0:
		print("Added {} fake spots".format(added_fake))


	trackmate = TrackMate(model, settings)
	trackmate.setNumThreads(4)

	#======= TRACKING
	for p_DISTANCE in p_LINKING_MAX_DISTANCES:
		for p_GAP_FRAME in p_MAX_FRAME_GAPS:
			p_GAP_DISTANCE = p_DISTANCE
			if p_GAP_FRAME == 0:
				p_GAP_DISTANCE = 0.0

			outFname = path.join(exp_path, link_fname.format(fname=exp_fname, dist=p_DISTANCE, distgap=p_GAP_DISTANCE, framegap=p_GAP_FRAME))

			if path.isfile(outFname):
				print("  Skipped")
				continue

			# Configure tracker
			settings.trackerFactory = SimpleSparseLAPTrackerFactory()
			settings.trackerSettings = settings.trackerFactory.getDefaultSettings()
			settings.trackerSettings['LINKING_MAX_DISTANCE'] = p_DISTANCE
			settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE'] = p_GAP_DISTANCE
			settings.trackerSettings['MAX_FRAME_GAP'] = p_GAP_FRAME
			if p_GAP_FRAME == 0:
				settings.trackerSettings["ALLOW_GAP_CLOSING"] = False

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
