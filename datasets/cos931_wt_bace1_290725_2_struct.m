function res = cos931_wt_bace1_290725_2_struct()
    res = struct();
    res.name = 'cos931_wt_bace1_290725_struct';
    res.pxsize = 0.065;
    res.data_dir = '';
    res.base_dir = '../analysis_data/tracking/APP/290725_PP_YY_cos123-931';
    res.data = {'well1_bace1_snapkdel/cell10_nobace1_10ms/C3-cell10_nobace1_10ms_MMStack_Pos0.ome.tif'
                'well1_bace1_snapkdel/cell5_2_10ms/C3-cell5_2_10ms_MMStack_Pos0.ome';
                'well1_bace1_snapkdel/cell11_nobace1_1_10ms/C3-cell11_nobace1_1_10ms_MMStack_Pos0.ome.tif';
                'well1_bace1_snapkdel/C3-cell9_nobace1_1_10ms_MMStack_Pos0.ome.tif'};

    res.cat_idxs = [1 2 1];
    res.cat_names = {'WT'; 'BACE1OE'};

    res.cat_cols = [1 0 0; 1 0.4 0 ; 0 0 1; 0.2 0.8 1; 0 0 0; 0.2 0.9 0; 1 0 1];
    res.proc_dir = '../analysis_data/analysis/APP/290725_PP_YY_cos123-931_struct';
    res.traj_type = 'track';

    res.constr = struct();
    res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, '', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_struct', 1, [1 5 3 4 6]);
    res.track_handler.ambig_col = 11;

    res.noa = 1;
end