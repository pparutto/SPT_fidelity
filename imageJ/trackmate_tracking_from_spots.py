from fiji.plugin.trackmate import TrackMate, Model, Settings, Logger
from fiji.plugin.trackmate.tracking.jaqaman import SimpleSparseLAPTrackerFactory
from fiji.plugin.trackmate.features.edges import EdgeAmbiguityAnalyzer

from ij import IJ
from fiji.plugin.trackmate import Spot

import os
import sys
from os import path

#default value
out_name_cats = [-1]


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

#sys.path.append("/mnt/data4/SPT_method_moved_for_space/yutong_240123/240122_Yutong_cos123-716-717-418_HPA646-3ul_6ms/cell1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/yutong_240123/240122_Yutong_cos123-716-717-418_HPA646-3ul_6ms/cell1_1in5")

#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/cell10_nobace1_10ms")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/cell11_nobace1_1_10ms")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/cell7_nobace1_1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/010825/cell9-bace1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/010825/cell12_bace1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/010825/cell6_high")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/240725/cell20_good")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/240625/cell21")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/cells")

#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/170925/cell8_well1_466")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/170925/cell3_well1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/170925/cells")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/240925/cell10_nobace1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/240925/cell9_nobace1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/C1-cell5_2_10ms")

#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/090725/cell16")
sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/090725/cell23")

from config_tracking import *
	
def load_spots_trackmate(f, model):
	for i, ln in enumerate(f.readlines()):
		ln = ln.rstrip("\n").split(",")
		if i == 0:
			continue
		frame = int(float(ln[3]))
		spt = Spot(float(ln[1]), float(ln[2]), 0.0, float(ln[4]), float(ln[5]), "ID{}".format(i))
		spt.putFeature("POSITION_T", float(ln[0]))
		model.addSpotTo(spt, frame)

todo_dirs = []
for exp_dir in os.listdir(out_dir):
	if exp_dir not in exclude:
		todo_dirs.append(exp_dir)

print(base_dir)
for cpt, exp_fname in enumerate(todo_dirs):
	print("Processing[{}/{}]: {}".format(cpt + 1, len(todo_dirs), exp_fname))

	exp_path = "/".join([out_dir, exp_fname])

	settings = Settings()
	settings.tstart = 0
	settings.dx = set_dx
	settings.dy = set_dx
	settings.dt = set_dt

	settings.addEdgeAnalyzer(EdgeAmbiguityAnalyzer())

	print("pxsize = {} um; dt = {} s".format(settings.dx, settings.dt))

	for p_DIAMETER in p_DETECTION_BLOB_DIAMETERS:
		for spot_th in ths:
			if spots_type == "TRACKMATE":
				fname = "/".join([exp_path, "trackmate", spot_fname.format(mask=mask, spot_rad=p_DIAMETER, spot_th=spot_th)])
			else:
				fname = "/".join([exp_path, spot_fname.format(mask=mask, spot_rad=p_DIAMETER, spot_th=spot_th)])

			if not path.isfile(fname):
				print("  Skipped: spot file not found: {}".format(fname))
				continue

			model = Model()
			model.setLogger(Logger.IJ_LOGGER)
			model.setPhysicalUnits("µm", "ms")

			with open(fname, 'r') as f:
				load_spots_trackmate(f, model)

			settings.tend = model.getSpots().lastKey()
			trackmate = TrackMate(model, settings)
			trackmate.setNumThreads(4)

			#======= TRACKING
			for p_DISTANCE in p_LINKING_MAX_DISTANCES:
				for p_GAP_FRAME in p_MAX_FRAME_GAPS:
					if p_GAP_FRAME == 0:
						gap_distance = 0.0
					else:
						gap_distance = p_DISTANCE

					tmp = spot_fname.format(mask=mask, spot_rad=p_DIAMETER, spot_th=spot_th)
					if tmp.endswith(".csv"):
						tmp = tmp[:-len(".csv")]
					outFname = "/".join([exp_path, link_fname.format(fname=tmp, dist=p_DISTANCE, distgap=gap_distance, framegap=p_GAP_FRAME)])

					if path.isfile(outFname):
						print("  Skipped")
						continue

					# Configure tracker
					settings.trackerFactory = SimpleSparseLAPTrackerFactory()
					settings.trackerSettings = settings.trackerFactory.getDefaultSettings()
					settings.trackerSettings['LINKING_MAX_DISTANCE'] = p_DISTANCE
					settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE'] = gap_distance
					settings.trackerSettings['MAX_FRAME_GAP'] = p_GAP_FRAME

					if p_GAP_FRAME == 0:
						settings.trackerSettings['ALLOW_GAP_CLOSING'] = False

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
					fm = model.getFeatureModel()
					with open(outFname, 'w') as f:
						f.write('Traj. id, Spot id, x (mum), y (mum), time (sec), frame, Ambiguity\n')
						for tid in model.getTrackModel().trackIDs(True):
						    spots = sorted(model.getTrackModel().trackSpots(tid), key=lambda s: s.getFeature('FRAME'))
						    edges = sorted(model.getTrackModel().trackEdges(tid), key=lambda e: model.getTrackModel().getEdgeSource(e).getFeature('FRAME'))

						    for i in range(len(spots)):
						    	spot = spots[i]

						    	if i < len(spots) - 1:
						    		na = model.getFeatureModel().getEdgeFeature( edges[i], "AMBIGUITY" )
					    		else:
					    			na = -2

						        sid = spot.ID()
						        x = spot.getFeature('POSITION_X')
						        y = spot.getFeature('POSITION_Y')
						        t = spot.getFeature('POSITION_T')
						        fr = spot.getFeature('FRAME')

						        f.write(",".join([str(e) for e in [tid, sid, x, y, t, fr, na]]) + "\n")

					model.clearTracks(True)
			model.clearSpots(True)

print("done")
