# SPT_fidelity_2024
Code supporting the FidlTrack SPT fidelity manuscript

The data associated to these codes need to be present in the following directories located in this folder (they can be symlinks):

simu_raw
analysis_data/tracking

these data are available here:
Simulations: https://doi.org/10.6084/m9.figshare.30940613
Experiments: https://doi.org/10.6084/m9.figshare.30943214

To regenerate the figures:

1. Regenerate the mat files using the scripts present in the processing folder (especially launch_trajectory_analysis.m). These codes will generate mat files in the following directories:

analysis_simu/analysis
analysis_data/analysis

2. Once these mat files are generated, you can launch the files in the figures folder to regenerate the individual figures.