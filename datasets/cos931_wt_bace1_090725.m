function res = cos931_wt_bace1_090725()
    res = struct();
    res.name = 'cos931_wt_bace1_090725';
    res.pxsize = 0.0645;
    res.data_dir = '';
    res.base_dir = '../analysis_data/tracking/APP/090725';
    res.data = {'cell16/C3-cell16_MMStack_Pos0.ome.tif';
                'cell23/C3-cell23_MMStack_Pos0.ome.tif'};

    res.cat_idxs = [2 1];
    res.cat_names = {'WT'; 'BACE1OE'};

    res.cat_cols = [1 0 0; 1 0.4 0 ; 0 0 1; 0.2 0.8 1; 0 0 0; 0.2 0.9 0; 1 0 1];
    res.proc_dir = '../analysis_data/analysis/APP/090725';
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