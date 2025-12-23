function res = cos931_wt_bace1()
    res = struct();
    res.name = 'cos931_wt_bace1';
    res.pxsize = 0.065;
    res.data_dir = '';
    res.base_dir = '../analysis_data/tracking/APP/cos123-931';
    res.data = {'090725/cell23/C3-cell23_MMStack_Pos0.ome.tif';
                '290725/cell11_nobace1_1_10ms/C3-cell11_nobace1_1_10ms_MMStack_Pos0.ome.tif';
                '290725/cell9_nobace1_1_10ms/C3-cell9_nobace1_1_10ms_MMStack_Pos0.ome.tif';
                '290725/cell5_2_10ms/C3-cell5_2_10ms_MMStack_Pos0.ome';
                '170925/cell8_well1_466/C3-cell8_well1_good_MMStack_Pos0.ome.tif';
                '010825/C3-cell12_bace1_MMStack_Pos0.ome.tif'};

    res.cat_idxs = [1 1 1 2 2 2];
    res.cat_names = {'WT'; 'BACE1OE'};

    res.cat_cols = [1 0 0; 1 0.4 0 ; 0 0 1; 0.2 0.8 1; 0 0 0; 0.2 0.9 0; 1 0 1];
    res.proc_dir = '../analysis_data/analysis/APP/cos123-931';
    res.traj_type = 'track';

    res.constr = struct();
    res.constr.mask = 0;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, '', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]);
    res.track_handler.ambig_col = 7;
    res.track_handler.ignore = 'struct';

    res.noa = 0;
end