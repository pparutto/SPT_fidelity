from fiji.plugin.trackmate import TrackMate, Model, Settings, Logger
from fiji.plugin.trackmate.features.edges import EdgeAmbiguityAnalyzer
from fiji.plugin.trackmate.tracking.jaqaman import SimpleSparseLAPTrackerFactory
from fiji.plugin.trackmate.tracking.jaqaman.costfunction import ComponentDistancesTime, ReachableDistCostFunctionTime

from ij import IJ, WindowManager
from fiji.plugin.trackmate import Spot

import os
import sys
from os import path


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

#sys.path.append("/mnt/data4/SPT_method_moved_for_space/yutong_240123/240122_Yutong_cos123-716-717-418_HPA646-3ul_6ms/cell1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/cell10_nobace1_10ms")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/cell11_nobace1_1_10ms")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/010825/cell12_bace1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/010825/cell9-bace1")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/170925/cell8_well1_466")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/C1-cell5_2_10ms")
#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/010825/cell6_high")

#sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/290725_PP_YY_cos123-931/cell9_nobace1_1_10ms")
sys.path.append("/mnt/data4/SPT_method_moved_for_space/APP/090725/cell23")


from config_tracking import *

wdur = struct_w_dur

def load_spots_trackmate(f, model):
	head = f.readline().rstrip("\n").split(",")
	frame_idx = head.index("FRAME")
	x_idx = head.index("POSITION_X")                                 
	y_idx = head.index("POSITION_Y")
	r_idx = head.index("RADIUS")
	q_idx = head.index("QUALITY")
	for i, ln in enumerate(f.readlines()):
		ln = ln.rstrip("\n").split(",")
		frame = int(float(ln[frame_idx]))
		spt = Spot(float(ln[x_idx]), float(ln[y_idx]), 0.0, float(ln[r_idx]), float(ln[q_idx]), "ID{}".format(i))
		spt.putFeature("POSITION_T", float(ln[0]))
		model.addSpotTo(spt, frame)

todo_dirs = []
for exp_dir in os.listdir(out_dir):
	if path.isdir("/".join([out_dir, exp_dir])) and not any([e in exp_dir for e in exclude]):
		todo_dirs.append(exp_dir)

cd = None
cost_f = None

exp_fname_id = -1

for cpt, fname in enumerate(todo_dirs):
	print("Processing[{}/{}]: {}".format(cpt + 1, len(todo_dirs), fname))
	exp_fname = fname.split("/")[exp_fname_id]
	exp_path = "/".join([out_dir, exp_fname])

	exp_fname_no_chan = exp_fname
	if exp_fname[0] == "C" and exp_fname[2] == "-":
		exp_fname_no_chan = exp_fname_no_chan[3:]
	print(exp_fname_no_chan)

	comp_f = path.join(base_dir, comp_fname_win.format(fname=exp_fname_no_chan[:-len(".czi.tif")]))
	if not path.isfile(comp_f):
		print("   ERROR: {}".format(comp_f))
		continue

	IJ.open(comp_f)
	imp = IJ.getImage()
	dims = imp.getDimensions()
	is_single_frame = all([e == 1 for e in dims[2:]])

	cur_dist_fname = path.join(base_dir, dist_fname.format(fname=exp_fname_no_chan[:-len(".czi.tif")], max_dist=struct_max_dist, w_dur=struct_w_dur, w_ovlp=struct_w_ovlp))
	print(cur_dist_fname)
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
	
	settings.addEdgeAnalyzer(EdgeAmbiguityAnalyzer())


	print("Loading distances")
	cd = ComponentDistancesTime(cur_dist_fname, imp, settings.width, settings.height, settings.dx)
	cost_f = ReachableDistCostFunctionTime(cd)

	for p_DIAMETER in p_DETECTION_BLOB_DIAMETERS:
		for spot_th in ths:
			fname = path.join(exp_path, "trackmate", spot_fname.format(mask=mask, spot_rad=p_DIAMETER, spot_th=spot_th))
			print(fname)

			if not path.isfile(fname):
				print("  Skipped: spot file not found")
				continue

			model = Model()
			model.setLogger(Logger.IJ_LOGGER)
			model.setPhysicalUnits("µm", "ms")

			with open(fname, 'r') as f:
				load_spots_trackmate(f, model)

			print(settings.dx, settings.dy, settings.dt, settings.tstart, settings.tend, settings.width, settings.height)

			frames = set()
			cnt = 0
			spots_to_rm = []
			for s in model.getSpots().iterator(True):
				cnt += 1
				pos = [s.getFeature("POSITION_X"), s.getFeature("POSITION_Y")]
				p = [int(s.getFeature("FRAME")), int(pos[0] // set_dx), int(pos[1] // set_dx)]
				frames.add(p[0])

				s_wins = cd.getWindowIdxs(p[0])
				if cd.getComponent(cd.getWindowIdxs(p[0])[0], [p[1], p[2]]) == 0:
					spots_to_rm.append(s)

				s.putFeature("PX_X", p[1])
				s.putFeature("PX_Y", p[2])
				s.putFeature("SQDIST_TO_PX", (pos[0] - (p[1] * set_dx + set_dx / 2)) ** 2 + (pos[1] - (p[2] * set_dx + set_dx / 2)) ** 2)
				assert(s.getFeature("SQDIST_TO_PX") <= 2 * set_dx**2)

			print("REMOVING {} over {} spots".format(len(spots_to_rm), cnt))
			for s in spots_to_rm:
				model.removeSpot(s)

			#ADD fake spots so that the tracking does not skip inexistant frames
			for i in range(min(frames), max(frames)):
				if i not in frames:
					spt = Spot(float("nan"), float("nan"), 0.0, float("nan"), float("nan"), "ID{}".format(i))
					spt.putFeature("POSITION_T", float("nan"))
					spt.putFeature("PX_X", -1)
					spt.putFeature("PX_Y", -1)
					spt.putFeature("SQDIST_TO_PX", float("nan"))
					model.addSpotTo(spt, i)


			settings.tend = model.getSpots().lastKey()

			trackmate = TrackMate(model, settings)
			trackmate.setNumThreads(4)

			cd.preprocess_spots(model.getSpots())

			comps = []
			f = open(exp_path + "/" + spot_fname.format(mask=mask, spot_rad=p_DIAMETER, spot_th=spot_th) + "_pxs", 'w')
			for s in model.getSpots().iterator(True):
				pos = [s.getFeature("POSITION_X"), s.getFeature("POSITION_Y")]
				p = [int(s.getFeature("PX_X")), int(s.getFeature("PX_Y"))]
				s_wins = cd.getWindowIdxs(int(s.getFeature("FRAME")))
				comp = cd.getComponent(s_wins[0], p)
				comps.append(comp)
				f.write("{},{},{},{},{},{},{},{},{}\n".format(s.ID(), int(s.getFeature("FRAME")), s.getFeature("POSITION_T"), pos[0], pos[1], p[0], p[1], "/".join([str(e) for e in s_wins]), comp))
			f.close()

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
					outFname = path.join(exp_path, link_struct_fname.format(fname=tmp, dist=p_DISTANCE, distgap=gap_distance, framegap=p_GAP_FRAME))

					if not force and path.isfile(outFname):
						print("  Skipped")
						continue

					# Configure tracker
					settings.trackerFactory = SimpleSparseLAPTrackerFactory()
					settings.trackerSettings = settings.trackerFactory.getDefaultSettings()
					settings.trackerSettings['LINKING_MAX_DISTANCE'] = p_DISTANCE
					settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE'] = gap_distance
					settings.trackerSettings['MAX_FRAME_GAP'] = p_GAP_FRAME
					settings.trackerSettings["COMPONENTS_DISTANCES"] = cd

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
						f.write('Traj. id, Spot id, x (mum), y (mum), time (sec), frame, winIdx, comp, cost, edgeWeight, Ambiguity\n')
						for tid in model.getTrackModel().trackIDs(True):
						    spots = sorted(model.getTrackModel().trackSpots(tid), key=lambda s: s.getFeature('FRAME'))
						    edges = sorted(model.getTrackModel().trackEdges(tid), key=lambda e: model.getTrackModel().getEdgeSource(e).getFeature('FRAME'))

						    for i in range(len(spots)):
						    	spot = spots[i]
						    	if i < len(spots) - 1:
						    		cost = cost_f.linkingCost(spots[i], spots[i+1])
						    		ew = model.getTrackModel().getEdgeWeight(edges[i])
						    		na = model.getFeatureModel().getEdgeFeature( edges[i], "AMBIGUITY" )
					    		else:
					    			cost = -1.0
					    			ew = -1.0
					    			na = -2

						        sid = spot.ID()

						        x = spot.getFeature('POSITION_X')
						        y = spot.getFeature('POSITION_Y')
						        t = spot.getFeature('POSITION_T')
						        fr = spot.getFeature('FRAME')

						        s_wins = cd.getWindowIdxs(int(spot.getFeature("FRAME")))
						        comp = cd.getComponent(s_wins[0], [int(spot.getFeature("PX_X")), int(spot.getFeature("PX_Y"))])

						        f.write(",".join([str(e) for e in [tid, sid, x, y, t, fr, s_wins[0], comp, cost, ew, na]]) + "\n")

					model.clearTracks(True)
			model.clearSpots(True)

	imp.changes = False
	imp.close()

	cd = None
	cost_f = None


print("done")
