function res = roger_250226()
    res = struct();
    res.name = 'roger_250226';
    res.pxsize = 0.159;
    res.data_dir = '../data_raw/recordings/ERES/roger/Hela_250226';
    res.base_dir = '../analysis_data/tracking/ERES/roger/Hela_250226';
    res.data = {'C1-250226_HeLa_Sec13_SNAP_GFP_Sec61_Halo_KDEL_250nM_PAJF646_c9.nd2'};

    res.cat_idxs = [1];
    res.cat_names = {''};

    res.cat_cols = [0 0 0; 1 0 0];
    res.proc_dir = '../analysis_data/analysis/ERES/roger/Hela_250226';
    res.traj_type = 'track';

    res.eres_trck_fname = 'tracks_spots_mask=0_rad=0.5_th=25.0_dist=0.8_distgap=0.8_framegap=20.csv';

    res.constr = struct();
    res.constr.mask = 0;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, '', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]);
    res.track_handler.ambig_col = 7;
end