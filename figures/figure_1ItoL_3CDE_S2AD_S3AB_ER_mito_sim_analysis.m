addpath('../')
addpath('../datasets/')
addpath('../external/')

%%%% UNCOMMENT / COMMENT (& COMMENT / UNCOMMENT MITO DATASETS) TO RUN LINE SIMULATION
Nreps = 3;
basedir = '';
dats_nos = {{simu_dens_lines_31_time_track(basedir, 1:Nreps); simu_dens_lines_31_time2_track(basedir, 1:Nreps); simu_dens_lines_31_time3_track(basedir, 1:Nreps);
          simu_dens_lines_31_time4_track(basedir, 1:Nreps); simu_dens_lines_31_time5_track(basedir, 1:Nreps); simu_dens_lines_31_time6_track(basedir, 1:Nreps);
          simu_dens_lines_31_time7_track(basedir, 1:Nreps); simu_dens_lines_31_time8_track(basedir, 1:Nreps); simu_dens_lines_31_time9_track(basedir, 1:Nreps);
          simu_dens_lines_31_time10_track(basedir, 1:Nreps); simu_dens_lines_31_time11_track(basedir, 1:Nreps); simu_dens_lines_31_time12_track(basedir, 1:Nreps);
          simu_dens_lines_31_time13_track(basedir, 1:Nreps)}};
dats_s = {{simu_dens_lines_31_time_track_struct(basedir, 1:Nreps); simu_dens_lines_31_time2_track_struct(basedir, 1:Nreps); simu_dens_lines_31_time3_track_struct(basedir, 1:Nreps);
          simu_dens_lines_31_time4_track_struct(basedir, 1:Nreps); simu_dens_lines_31_time5_track_struct(basedir, 1:Nreps); simu_dens_lines_31_time6_track_struct(basedir, 1:Nreps);
          simu_dens_lines_31_time7_track_struct(basedir, 1:Nreps); simu_dens_lines_31_time8_track_struct(basedir, 1:Nreps); simu_dens_lines_31_time9_track_struct(basedir, 1:Nreps);
          simu_dens_lines_31_time10_track_struct(basedir, 1:Nreps); simu_dens_lines_31_time11_track_struct(basedir, 1:Nreps); simu_dens_lines_31_time12_track_struct(basedir, 1:Nreps);
          simu_dens_lines_31_time13_track_struct(basedir, 1:Nreps)}};


%%%% UNCOMMENT / COMMENT (& COMMENT / UNCOMMENT MITO DATASETS) TO RUN ER SIMULATION
% Nreps = 5;
% basedir = '';
% dats_nos = {{simu_dens_ER_BSA_001_time_track(basedir, 1:Nreps); simu_dens_ER_BSA_001_time2_track(basedir, 1:Nreps); simu_dens_ER_BSA_001_time3_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_001_time4_track(basedir, 1:Nreps); simu_dens_ER_BSA_001_time5_track(basedir, 1:Nreps); simu_dens_ER_BSA_001_time6_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_001_time7_track(basedir, 1:Nreps); simu_dens_ER_BSA_001_time8_track(basedir, 1:Nreps); simu_dens_ER_BSA_001_time9_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_001_time10_track(basedir, 1:Nreps); simu_dens_ER_BSA_001_time11_track(basedir, 1:Nreps); simu_dens_ER_BSA_001_time12_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_001_time13_track(basedir, 1:Nreps)};
%             {simu_dens_ER_OA_002_time_track(basedir, 1:Nreps); simu_dens_ER_OA_002_time2_track(basedir, 1:Nreps); simu_dens_ER_OA_002_time3_track(basedir, 1:Nreps);
%              simu_dens_ER_OA_002_time4_track(basedir, 1:Nreps); simu_dens_ER_OA_002_time5_track(basedir, 1:Nreps); simu_dens_ER_OA_002_time6_track(basedir, 1:Nreps);
%              simu_dens_ER_OA_002_time7_track(basedir, 1:Nreps); simu_dens_ER_OA_002_time8_track(basedir, 1:Nreps); simu_dens_ER_OA_002_time9_track(basedir, 1:Nreps);
%              simu_dens_ER_OA_002_time10_track(basedir, 1:Nreps); simu_dens_ER_OA_002_time11_track(basedir, 1:Nreps); simu_dens_ER_OA_002_time12_track(basedir, 1:Nreps);
%              simu_dens_ER_OA_002_time13_track(basedir, 1:Nreps)};
%             {simu_dens_ER_BSA_004_time_track(basedir, 1:Nreps); simu_dens_ER_BSA_004_time2_track(basedir, 1:Nreps); simu_dens_ER_BSA_004_time3_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_004_time4_track(basedir, 1:Nreps); simu_dens_ER_BSA_004_time5_track(basedir, 1:Nreps); simu_dens_ER_BSA_004_time6_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_004_time7_track(basedir, 1:Nreps); simu_dens_ER_BSA_004_time8_track(basedir, 1:Nreps); simu_dens_ER_BSA_004_time9_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_004_time10_track(basedir, 1:Nreps); simu_dens_ER_BSA_004_time11_track(basedir, 1:Nreps); simu_dens_ER_BSA_004_time12_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_004_time13_track(basedir, 1:Nreps)};
%             {simu_dens_ER_BSA_005_time_track(basedir, 1:Nreps); simu_dens_ER_BSA_005_time2_track(basedir, 1:Nreps); simu_dens_ER_BSA_005_time3_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_005_time4_track(basedir, 1:Nreps); simu_dens_ER_BSA_005_time5_track(basedir, 1:Nreps); simu_dens_ER_BSA_005_time6_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_005_time7_track(basedir, 1:Nreps); simu_dens_ER_BSA_005_time8_track(basedir, 1:Nreps); simu_dens_ER_BSA_005_time9_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_005_time10_track(basedir, 1:Nreps); simu_dens_ER_BSA_005_time11_track(basedir, 1:Nreps); simu_dens_ER_BSA_005_time12_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_005_time13_track(basedir, 1:Nreps)};
%             {simu_dens_ER_BSA_008_time_track(basedir, 1:Nreps); simu_dens_ER_BSA_008_time2_track(basedir, 1:Nreps); simu_dens_ER_BSA_008_time3_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_008_time4_track(basedir, 1:Nreps); simu_dens_ER_BSA_008_time5_track(basedir, 1:Nreps); simu_dens_ER_BSA_008_time6_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_008_time7_track(basedir, 1:Nreps); simu_dens_ER_BSA_008_time8_track(basedir, 1:Nreps); simu_dens_ER_BSA_008_time9_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_008_time10_track(basedir, 1:Nreps); simu_dens_ER_BSA_008_time11_track(basedir, 1:Nreps); simu_dens_ER_BSA_008_time12_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_008_time13_track(basedir, 1:Nreps)};
%             {simu_dens_ER_BSA_009_time_track(basedir, 1:Nreps); simu_dens_ER_BSA_009_time2_track(basedir, 1:Nreps); simu_dens_ER_BSA_009_time3_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_009_time4_track(basedir, 1:Nreps); simu_dens_ER_BSA_009_time5_track(basedir, 1:Nreps); simu_dens_ER_BSA_009_time6_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_009_time7_track(basedir, 1:Nreps); simu_dens_ER_BSA_009_time8_track(basedir, 1:Nreps); simu_dens_ER_BSA_009_time9_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_009_time10_track(basedir, 1:Nreps); simu_dens_ER_BSA_009_time11_track(basedir, 1:Nreps); simu_dens_ER_BSA_009_time12_track(basedir, 1:Nreps);
%              simu_dens_ER_BSA_009_time13_track(basedir, 1:Nreps)}};
% 
% dats_s = {{simu_dens_ER_BSA_001_time_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_001_time2_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_001_time3_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_001_time4_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_001_time5_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_001_time6_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_001_time7_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_001_time8_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_001_time9_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_001_time10_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_001_time11_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_001_time12_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_001_time13_track_struct_6(basedir, 1:Nreps)};
%           {simu_dens_ER_OA_002_time_track_struct_6(basedir, 1:Nreps); simu_dens_ER_OA_002_time2_track_struct_6(basedir, 1:Nreps); simu_dens_ER_OA_002_time3_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_OA_002_time4_track_struct_6(basedir, 1:Nreps); simu_dens_ER_OA_002_time5_track_struct_6(basedir, 1:Nreps); simu_dens_ER_OA_002_time6_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_OA_002_time7_track_struct_6(basedir, 1:Nreps); simu_dens_ER_OA_002_time8_track_struct_6(basedir, 1:Nreps); simu_dens_ER_OA_002_time9_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_OA_002_time10_track_struct_6(basedir, 1:Nreps); simu_dens_ER_OA_002_time11_track_struct_6(basedir, 1:Nreps); simu_dens_ER_OA_002_time12_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_OA_002_time13_track_struct_6(basedir, 1:Nreps)};
%           {simu_dens_ER_BSA_004_time_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_004_time2_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_004_time3_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_004_time4_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_004_time5_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_004_time6_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_004_time7_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_004_time8_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_004_time9_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_004_time10_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_004_time11_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_004_time12_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_004_time13_track_struct_6(basedir, 1:Nreps)};
%           {simu_dens_ER_BSA_005_time_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_005_time2_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_005_time3_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_005_time4_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_005_time5_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_005_time6_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_005_time7_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_005_time8_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_005_time9_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_005_time10_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_005_time11_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_005_time12_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_005_time13_track_struct_6(basedir, 1:Nreps)};
%           {simu_dens_ER_BSA_008_time_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_008_time2_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_008_time3_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_008_time4_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_008_time5_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_008_time6_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_008_time7_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_008_time8_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_008_time9_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_008_time10_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_008_time11_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_008_time12_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_008_time13_track_struct_6(basedir, 1:Nreps)};
%           {simu_dens_ER_BSA_009_time_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_009_time2_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_009_time3_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_009_time4_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_009_time5_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_009_time6_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_009_time7_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_009_time8_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_009_time9_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_009_time10_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_009_time11_track_struct_6(basedir, 1:Nreps); simu_dens_ER_BSA_009_time12_track_struct_6(basedir, 1:Nreps);
%            simu_dens_ER_BSA_009_time13_track_struct_6(basedir, 1:Nreps)}};


%%%% UNCOMMENT / COMMENT (& COMMENT / UNCOMMENT MITO DATASETS) TO RUN MITO SIMULATION
% Nreps = 5;
% basedir = '';
% dats_nos = {{simu_dens_mito_Tom20mNeonGreen4_time_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time2_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time3_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen4_time4_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time5_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time6_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen4_time7_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time8_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time9_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen4_time10_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time11_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time12_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen4_time13_track(basedir, 1:Nreps)};
%             {simu_dens_mito_Tom20mNeonGreen5_time_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time2_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time3_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen5_time4_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time5_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time6_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen5_time7_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time8_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time9_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen5_time10_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time11_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time12_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen5_time13_track(basedir, 1:Nreps)};
%             {simu_dens_mito_Tom20mNeonGreen7_time_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time2_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time3_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen7_time4_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time5_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time6_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen7_time7_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time8_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time9_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen7_time10_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time11_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time12_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen7_time13_track(basedir, 1:Nreps)};
%             {simu_dens_mito_Tom20mNeonGreen9_time_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time2_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time3_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen9_time4_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time5_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time6_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen9_time7_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time8_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time9_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen9_time10_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time11_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time12_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen9_time13_track(basedir, 1:Nreps)};
%             {simu_dens_mito_Tom20mNeonGreen10_time_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time2_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time3_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen10_time4_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time5_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time6_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen10_time7_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time8_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time9_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen10_time10_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time11_track(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time12_track(basedir, 1:Nreps);
%              simu_dens_mito_Tom20mNeonGreen10_time13_track(basedir, 1:Nreps)}};
% 
% dats_s = {{simu_dens_mito_Tom20mNeonGreen4_time_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time2_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time3_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen4_time4_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time5_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time6_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen4_time7_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time8_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time9_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen4_time10_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time11_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time12_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen4_time13_track_struct_6(basedir, 1:Nreps)};
%         {simu_dens_mito_Tom20mNeonGreen5_time_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time2_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time3_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen5_time4_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time5_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time6_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen5_time7_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time8_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time9_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen5_time10_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time11_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time12_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen5_time13_track_struct_6(basedir, 1:Nreps)};
%         {simu_dens_mito_Tom20mNeonGreen7_time_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time2_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time3_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen7_time4_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time5_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time6_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen7_time7_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time8_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time9_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen7_time10_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time11_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time12_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen7_time13_track_struct_6(basedir, 1:Nreps)};
%         {simu_dens_mito_Tom20mNeonGreen9_time_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time2_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time3_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen9_time4_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time5_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time6_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen9_time7_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time8_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time9_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen9_time10_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time11_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time12_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen9_time13_track_struct_6(basedir, 1:Nreps)};
%         {simu_dens_mito_Tom20mNeonGreen10_time_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time2_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time3_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen10_time4_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time5_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time6_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen10_time7_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time8_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time9_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen10_time10_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time11_track_struct_6(basedir, 1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time12_track_struct_6(basedir, 1:Nreps);
%          simu_dens_mito_Tom20mNeonGreen10_time13_track_struct_6(basedir, 1:Nreps)}};


denss = [];
for k=1:length(dats_nos{1}{1}.cat_names)
    elts = strsplit(dats_nos{1}{1}.cat_names{k}, '_');
    denss = [denss str2num(elts{1})];
end

DTs = cellfun(@(x) x.spots_handler.dt, dats_nos{1});
dist_ths = [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0 4.2 4.4 4.6 4.8 5.0 5.2 5.4 5.6 5.8 6.0];
exp_disp = sqrt(1 * DTs);
Nframes = [60000 12000 6000 4000 3000 2400 2000 1715 1500 1334 1200];

pxsize = 0.024195525;
area = (420 * pxsize)^2;
Nspts = [1 5 10 15 20 25 30 35 40 45 50];
spts_dens = round(Nspts / area * 100, 1);

ndisps_s = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps);
err_disps_s = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps) * nan;
ambigs_s = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps) * nan;
ambigs_s_de = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps) * nan;
ambigs_s_dg = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps) * nan;
runs_s = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps) * nan;
truth_run_lens_s = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_ndisps_s = zeros(length(DTs), length(denss), length(dats_s), Nreps);
best_disp_runs_s = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_disp_err_s = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_disp_dist_s = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_disp_ambigs_s = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_disp_ambigs_s_de = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_disp_ambigs_s_dg = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;

ndisps_nos = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps);
err_disps_nos = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps) * nan;
ambigs_nos = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps) * nan;
runs_nos = zeros(length(DTs), length(dist_ths), length(denss), length(dats_s), Nreps) * nan;
truth_run_lens_nos = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_ndisps_nos = zeros(length(DTs), length(denss), length(dats_s), Nreps);
best_disp_runs_nos = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_disp_err_nos = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_disp_dist_nos = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
best_disp_ambigs_nos = zeros(length(DTs), length(denss), length(dats_s), Nreps) * nan;
for kk=1:length(dats_nos)
    display(sprintf('%d/%d', kk, length(dats_nos)));
    for uu=1:length(DTs)
        for n=1:Nreps
            for vv=1:length(denss)
                ana_nos = load(sprintf('%s/%s/mapping_groundtruth_v2.mat', dats_nos{kk}{uu}.proc_dir, dats_nos{kk}{uu}.data{vv + (n-1)*length(dats_nos{kk}{uu}.cat_names)}));
                ana_nos = ana_nos.ana;
                ana_s = load(sprintf('%s/%s/mapping_groundtruth_v2.mat', dats_s{kk}{uu}.proc_dir, dats_s{kk}{uu}.data{vv + (n-1)*length(dats_s{kk}{uu}.cat_names)}));
                ana_s = ana_s.ana;
                ana_a = load(sprintf('%s/%s/ambig_de_dg.mat', dats_s{kk}{uu}.proc_dir, dats_s{kk}{uu}.data{vv + (n-1)*length(dats_s{kk}{uu}.cat_names)}));
                ana_a = ana_a.ana;

                ndisps_s(uu,:,vv,kk,n) = ana_s.err_disps_cnt_disps / Nframes(vv);
                err_disps_s(uu,:,vv,kk,n) = ana_s.err_disps_f';
                ambigs_s(uu,:,vv,kk,n) = cellfun(@(x) sum(x > 0) / size(x,1), ana_s.all_ambig_n_tab);
                ambigs_s_de(uu,:,vv,kk,n) = arrayfun(@(i) sum(ana_a.ambig_pos{i}(:,2) > 0) / ana_a.ndisps(i), 1:length(ana_a.ambig_pos));
                ambigs_s_dg(uu,:,vv,kk,n) = arrayfun(@(i) sum(ana_a.ambig_pos{i}(:,3) > 0) / ana_a.ndisps(i), 1:length(ana_a.ambig_pos));
                runs_s(uu,:,vv,kk,n) = cellfun(@(x) mean(x(:,2)), ana_s.all_run_len)';
                truth_run_lens_s(uu,vv,kk,n) = ana_s.truth_avg_tlens;

                best_disp_err_s(uu,vv,kk,n) = ana_s.err_disps_f(ana_s.best_err_disps_f_idx);
                best_ndisps_s(uu,vv,kk,n) = ana_s.err_disps_cnt_disps(ana_s.best_err_disps_f_idx) / Nframes(vv);
                best_disp_dist_s(uu,vv,kk,n) = dist_ths(ana_s.best_err_disps_f_idx);
                best_disp_ambigs_s(uu,vv,kk,n) = ambigs_s(uu,ana_s.best_err_disps_f_idx,vv,kk,n);
                best_disp_ambigs_s_de(uu,vv,kk,n) = ambigs_s_de(uu,ana_s.best_err_disps_f_idx,vv,kk,n);
                best_disp_ambigs_s_dg(uu,vv,kk,n) = ambigs_s_dg(uu,ana_s.best_err_disps_f_idx,vv,kk,n);
                best_disp_runs_s(uu,vv,kk,n) = runs_s(uu,ana_s.best_err_disps_f_idx,vv,kk,n);

                ndisps_nos(uu,:,vv,kk,n) = ana_nos.err_disps_cnt_disps / Nframes(vv);
                err_disps_nos(uu,:,vv,kk,n) = ana_nos.err_disps_f';
                ambigs_nos(uu,:,vv,kk,n) = cellfun(@(x) sum(x > 0) / size(x,1), ana_nos.all_ambig_n_tab);
                runs_nos(uu,:,vv,kk,n) = cellfun(@(x) mean(x(:,2)), ana_nos.all_run_len)';
                truth_run_lens_nos(uu,vv,kk,n) = ana_nos.truth_avg_tlens;

                best_ndisps_nos(uu,vv,kk,n) = ana_nos.err_disps_cnt_disps(ana_nos.best_err_disps_f_idx) / Nframes(vv);
                best_disp_err_nos(uu,vv,kk,n) = ana_nos.err_disps_f(ana_nos.best_err_disps_f_idx);
                best_disp_dist_nos(uu,vv,kk,n) = dist_ths(ana_nos.best_err_disps_f_idx);
                best_disp_ambigs_nos(uu,vv,kk,n) = ambigs_nos(uu,ana_nos.best_err_disps_f_idx,vv,kk,n);
                best_disp_runs_nos(uu,vv,kk,n) = runs_nos(uu,ana_nos.best_err_disps_f_idx,vv,kk,n);
            end
        end
    end
end

%%%%%NO STRUCT


pause(1)
figure
h = heatmap(flipud(mean(mean(best_disp_dist_nos, 4), 3)));
h.YData = h.YData(end:-1:1);
h.CellLabelFormat = '%.2f';
h.ColorLimits = [0 4];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG Best dist nos')
print(sprintf('/tmp/avg_distth_best_disp_%s_%dreps.svg', dats_nos{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('best_disp_dists no struct'))
display(sprintf('%s', Utils.show_4D_matrix(best_disp_dist_nos, 3)))

pause(1)
figure
h = heatmap(flipud(mean(mean(1 - best_disp_err_nos, 4), 3)) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'Oranges');
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
h.ColorLimits = [15 100];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG Correct displacement disp nos')
print(sprintf('/tmp/avg_disp_errs_best_disp_%s_%dreps.svg', dats_nos{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('best_disp_err no struct'))
display(sprintf('%s', Utils.show_4D_matrix((1 - best_disp_err_nos)*100, 1)))

pause(1)
figure
h = heatmap(flipud(mean(mean(best_disp_ambigs_nos, 4), 3)) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'YlGnBu');
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 100];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG best Ambiguity nos')
print(sprintf('/tmp/avg_ambigs_best_disp_%s_%dreps.svg', dats_nos{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('Ambgiguous displacements no struct'))
display(sprintf('%s', Utils.show_4D_matrix(best_disp_ambigs_nos*100, 2)))

%%%%STRUCT

pause(1)
figure
h = heatmap(flipud(mean(mean(best_disp_dist_s, 4), 3)));
h.CellLabelFormat = '%.2f';
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 4];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG Best dist s')
print(sprintf('/tmp/avg_distth_best_disp_%s_struct_%dreps.svg', dats_s{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('best_disp_dists struct'))
display(sprintf('%s', Utils.show_4D_matrix(best_disp_dist_s, 3)))

pause(1)
figure
h = heatmap(flipud(mean(mean(1 - best_disp_err_s, 4), 3)) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'Oranges');
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
h.ColorLimits = [15 100];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG Correct displacement disp s')
print(sprintf('/tmp/avg_disp_errs_best_disp_%s_struct_%dreps.svg', dats_s{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('best_disp_err struct'))
display(sprintf('%s', Utils.show_4D_matrix((1 - best_disp_err_s)*100, 1)))

pause(1)
figure
h = heatmap(flipud(mean(mean(best_disp_ambigs_s_de, 4), 3)) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'YlGnBu');
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 100];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG best Ambiguity s de')
print(sprintf('/tmp/avg_ambigs_de_best_disp_%s_struct_%dreps.svg', dats_s{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('Ambgiguous displacements struct de'))
display(sprintf('%s', Utils.show_4D_matrix(best_disp_ambigs_s_de*100, 2)))

pause(1)
figure
h = heatmap(flipud(mean(mean(best_disp_ambigs_s_dg, 4), 3)) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'YlGnBu');
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 100];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG best Ambiguity s dg')
print(sprintf('/tmp/avg_ambigs_dg_best_disp_%s_struct_%dreps.svg', dats_s{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('Ambgiguous displacements struct dg'))
display(sprintf('%s', Utils.show_4D_matrix(best_disp_ambigs_s_dg*100, 2)))

%%%%%RATIOS

pause(1)
figure
h = heatmap(flipud(mean(mean(best_disp_ambigs_s_dg ./ best_disp_ambigs_s_de, 4), 3)));
h.CellLabelFormat = '%.2f';
h.Colormap = inferno(64);
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0.2 1];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG best Ambiguity dg / de')
print(sprintf('/tmp/avg_ambigs_ratio_de_dg_best_disp_%s_struct_%dreps.svg', dats_s{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('Ratio Ambgiguity struct dg/de'))
display(sprintf('%s', Utils.show_4D_matrix(best_disp_ambigs_s_dg ./ best_disp_ambigs_s_de, 2)))

pause(1)
figure
h = heatmap(flipud(mean(mean((1 - best_disp_err_s) ./ (1 - best_disp_err_nos), 4), 3)));
h.CellLabelFormat = '%.2f';
h.Colormap = magma(64);
h.YData = h.YData(end:-1:1);
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG Correct disp s/nos ratio avg structs')
print(sprintf('/tmp/avg_err_disps_s_nos_ratio_avg_structs_%s_%dreps.svg', dats_s{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('Ratio best_dist_err s/nos'))
display(sprintf('%s', Utils.show_4D_matrix((1 - best_disp_err_s) ./ (1 - best_disp_err_nos), 2)))

col =  parula(15);
ok_disps_nos_avg = mean(mean(best_ndisps_nos .* (1 - best_disp_err_nos) / area, 4), 3);
ok_disps_nos_std = std(mean(best_ndisps_nos .* (1 - best_disp_err_nos) / area, 4), 1, 3);
pause(1)
figure
pause(1)
hold on
for k=1:length(exp_disp)
    shadedErrorBar(denss / area, ok_disps_nos_avg(k,:), ok_disps_nos_std(k,:) / sqrt(Nreps), 'lineProps', {'Color', col(k,:)})
end
plot(denss / area, denss / area, 'k--', 'LineWidth', 2)
hold off
axis square
xlabel('Spots Density (spots/um2)')
ylabel('Recovered disps. Density (disps/um2)')
title('ok disps err nos')
pause(1)
print(sprintf('/tmp/avg_ok_disps_response_err_%s_%dreps.svg', dats_nos{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('OK disps err'))
display(sprintf('%s', Utils.show_4D_matrix(best_ndisps_nos .* (1 - best_disp_err_nos) / area, 2)))

ok_disp_ambigs_nos_avg = mean(mean(best_ndisps_nos .* (1 - best_disp_ambigs_nos) / area, 4), 3);
ok_disp_ambigs_nos_std = std(mean(best_ndisps_nos .* (1 - best_disp_ambigs_nos) / area, 4), 1, 3);
pause(1)
figure
pause(1)
hold on
for k=1:length(exp_disp)
    shadedErrorBar(denss / area, ok_disp_ambigs_nos_avg(k,:), ok_disp_ambigs_nos_std(k,:) / sqrt(5), 'lineProps', {'Color', col(k,:)})
end
plot(denss / area, denss / area, 'k--', 'LineWidth', 2)
hold off
axis square
title('ok disps ambig nos')
xlabel('Spots Density (spots/um2)')
ylabel('Recovered disps. Density (disps/um2)')
pause(1)
print(sprintf('/tmp/avg_ok_disps_response_ambig_nos_de_%s_%dreps.svg', dats_nos{1}{1}.name, Nreps), '-dsvg')
pause(1)


display(sprintf('Non-ambig Disp density nos'))
display(sprintf('%s', Utils.show_4D_matrix(best_ndisps_nos .* (1 - best_disp_ambigs_nos) / area, 2)))


ok_disp_ambigs_s_de_avg = mean(mean(best_ndisps_s .* (1 - best_disp_ambigs_s_de) / area, 4), 3);
ok_disp_ambigs_s_dg_avg = mean(mean(best_ndisps_s .* (1 - best_disp_ambigs_s_dg) / area, 4), 3);
ok_disp_ambigs_s_dg_std = std(mean(best_ndisps_s .* (1 - best_disp_ambigs_s_dg) / area, 4), 1, 3);
pause(1)
figure
pause(1)
hold on
for k=1:length(exp_disp)
    shadedErrorBar(denss / area, ok_disp_ambigs_s_dg_avg(k,:), ok_disp_ambigs_s_dg_std(k,:) / sqrt(5), 'lineProps', {'Color', col(k,:)})
end
plot(denss / area, denss / area, 'k--', 'LineWidth', 2)
hold off
axis square
title('ok disps ambig s dg')
xlabel('Spots Density (spots/um2)')
ylabel('Recovered disps. Density (disps/um2)')
pause(1)
print(sprintf('/tmp/avg_ok_disps_response_ambig_dg_%s_%dreps.svg', dats_s{1}{1}.name, Nreps), '-dsvg')
pause(1)


ok_disp_ambigs_s_dg_de_avg = mean(mean((best_ndisps_s .* (1 - best_disp_ambigs_s_dg) / area), 4), 3) ./ mean(mean((best_ndisps_s .* (1 - best_disp_ambigs_s_de) / area), 4), 3);
ok_disp_ambigs_s_dg_de_std = std(mean((best_ndisps_s .* (1 - best_disp_ambigs_s_dg) / area), 4), 1, 3) ./ std(mean((best_ndisps_s .* (1 - best_disp_ambigs_s_de) / area), 4), 1, 3);
pause(1)
figure
pause(1)
hold on
for k=1:length(exp_disp)
    plot(denss / area, ok_disp_ambigs_s_dg_de_avg(k,:), 'Color', col(k,:))
end
hold off
axis square
xlabel('Spots Density (spots/um2)')
ylabel('dg / de ratio')
title('ok disps ambig s dg')
ylim([1 25])
pause(1)
print(sprintf('/tmp/avg_ok_disps_response_ambig_ratio_%s_%dreps.svg', dats_s{1}{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('ok_disp_ambigs_s_dg_de'))
display(sprintf('%s', Utils.show_4D_matrix((best_ndisps_s .* (1 - best_disp_ambigs_s_dg) / area) ./ (best_ndisps_s .* (1 - best_disp_ambigs_s_de) / area), 2)))

fits_ok_disps_err = [];
for k=1:length(exp_disp)
    [f, gof] = fit(denss(1:4)' / area, ok_disps_nos_avg(k,1:4)', 'poly1');
    fits_ok_disps_err = [fits_ok_disps_err; f.p1 gof.adjrsquare];
end
fits_ok_disps_ambig_de = [];
for k=1:length(exp_disp)
    [f, gof] = fit(denss(1:4)' / area, ok_disp_ambigs_s_de_avg(k,1:4)', 'poly1');
    fits_ok_disps_ambig_de = [fits_ok_disps_ambig_de; f.p1 gof.adjrsquare];
end
fits_ok_disps_ambig_dg = [];
for k=1:length(exp_disp)
    [f, gof] = fit(denss(1:4)' / area, ok_disp_ambigs_s_dg_avg(k,1:4)', 'poly1');
    fits_ok_disps_ambig_dg = [fits_ok_disps_ambig_dg; f.p1 gof.adjrsquare];
end

pause(1)
figure
pause(1)
hold on
plot(exp_disp, fits_ok_disps_err(:,1), 'k')
plot(exp_disp, fits_ok_disps_ambig_de(:,1), 'r')
plot(exp_disp, fits_ok_disps_ambig_dg(:,1), 'm')
hold off
axis square
xlabel('Characteristic length (um)')
ylabel('Fit coeff (correct disps. dens / spot dens)')
legend({'Err', 'Ambig de', 'Ambig dg'})
pause(1)
print(sprintf('/tmp/avg_ok_disps_response_fit_coeff_%s_%dreps.svg', dats_s{1}{1}.name, Nreps), '-dsvg')
pause(1)
