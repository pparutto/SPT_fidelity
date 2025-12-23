from ij import IJ, WindowManager
from ij.plugin.frame import RoiManager;
from ij.gui import Roi

import os
import time
from os import path

def read_roi(inp):
    res = []
    with open(inp, "r") as f:
        for line in f:
            res.append([int(e) for e in line.rstrip("\n").split(",")])
    return res

def read_roi_cz(inp):
	r_to_box_factor = 0.9
	res = []
	cx = None
	cy = None
	r = None
	with open(inp, "r") as f:
		for line in f:
			line = line.rstrip("\n")
			if line.startswith("        <CenterX>"):
				cx = float(line.split(">")[1].split("<")[0])
			if line.startswith("        <CenterY>"):
				cy = float(line.split(">")[1].split("<")[0])
			if line.startswith("        <Radius>"):
				r = r_to_box_factor * float(line.split(">")[1].split("<")[0])
	return [[cx - r, cy - r], [cx + r, cy - r], [cx - r, cy + r], [cx + r, cy + r]]

###PATH to raw FRAP data folder
raw_dir = "XXXXXXXXXXXXXX"

#base_dir = raw_dir + "/2022.02.04 - ER Membrane FRAP/data"
#out_dir = raw_dir + "/2022.02.04 - ER Membrane FRAP/out"
#file_ext = "tif"
#roi_name = "{}_roi.csv"

#base_dir = raw_dir + "/2022.03.29-ER Membrane FRAP/data"
#out_dir = raw_dir + "/2022.03.29-ER Membrane FRAP/out"
#file_ext = "czi"
#roi_name = "{}_roi.cz"

base_dir = raw_dir + "/2022.04.12 - ER membrane FRAP/data"
out_dir = raw_dir + "/2022.04.12 - ER membrane FRAP/out"
file_ext = "czi"
roi_name = "{}_roi.cz"

filenames = []
for root, dirs, files, in os.walk(base_dir):
	filenames.extend([path.join(root, f) for f in files if f.endswith(file_ext)])

print(filenames)
for i, fname in enumerate(filenames):
	print("Processing[{}/{}]: {}".format(i+1, len(filenames), fname))

	roim = RoiManager()
	if roim == None:
		RoiManager.getInstance()

	IJ.open(fname)
	imp = IJ.getImage()

	#roi = read_roi()/
	if fname.endswith(".czi"):
		roi = read_roi_cz(roi_name.format(fname[:-len(".czi")]))
	else:
		print(roi_name.format(fname))
		roi = read_roi(roi_name.format(fname))
	print(roi, roi[0][0], roi[0][1], roi[1][0] - roi[0][0], roi[2][1] - roi[1][1])

	roim.addRoi(Roi(roi[0][0], roi[0][1], roi[1][0] - roi[0][0], roi[2][1] - roi[1][1]))
	roim.addRoi(Roi(0, 0, imp.getWidth(), imp.getHeight()))
	roim.select(0);

	IJ.log(fname[len(base_dir):])
	IJ.log("pxsize: " + str(imp.getCalibration().pixelWidth))
	IJ.log("ROI size: " + str(roi[1][0] - roi[0][0]) + " , " + str(roi[2][1] - roi[1][1]))
	IJ.run("FRAP Profiler v2", "curve=[Single exponential recovery] time=1.7");


	curOutPath = out_dir + fname[len(base_dir):]
	if not path.isdir(curOutPath):
		os.makedirs(curOutPath)
	print(curOutPath)
	for i in range(WindowManager.getWindowCount(), 0, -1):
		IJ.selectWindow(i)
		IJ.save(path.join(curOutPath, IJ.getImage().getTitle() + ".png"))
		IJ.getImage().changes = False
		IJ.getImage().close()
	roim.close()
	time.sleep(5)

IJ.selectWindow("Log")
IJ.saveAs("Text", path.join(out_dir, "log.txt"));

print("DONEEEE")