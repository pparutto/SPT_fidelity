function res = cos931_wt_bace1_010825_struct()
    res = struct();
    res.name = 'cos931_wt_bace1_010825_struct';
    res.pxsize = 0.0645;
    res.data_dir = '';
    res.base_dir = '../analysis_data/tracking/APP/010825';
    res.data = {'C3-cell6_high_MMStack_Pos0.ome.tif';
                'C3-cell12_bace1_MMStack_Pos0.ome.tif'};

    %'C3-cell9_MMStack_Pos0.ome.tif';          %%BAD
    %'C3-cell12_bace1_MMStack_Pos0.ome.tif'    %%BAD

    res.cat_idxs = [1 2 2];
    res.cat_names = {'WT'; 'BACE1OE'};

    res.cat_cols = [1 0 0; 1 0.4 0 ; 0 0 1; 0.2 0.8 1; 0 0 0; 0.2 0.9 0; 1 0 1];
    res.proc_dir = '../analysis_data/analysis/APP/010825_struct';
    res.traj_type = 'track';

    res.constr = struct();
    res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, '', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_struct', 1, [1 5 3 4 6]);
    res.track_handler.ambig_col = 11;

    res.noa = 1;
end