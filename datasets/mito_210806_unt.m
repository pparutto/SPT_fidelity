function res = mito_210806_unt()
    res = struct();
    res.name = 'mito_210806_unt';
    res.pxsize = 0.0967821;
    res.base_dir = '../analysis_data/tracking/Mito/210806';
    res.data = {'C1-210806_COS7_4MTS-mNG_4MTS-HAlo-PA646_UT_2.czi.tif'};


    res.cat_idxs = [1];
    res.cat_names = {'UNT'};
    res.cat_cols = [0 0 0; 0.96 0.60 0.12; 1 0 0; 0.12 0.96 0.60; 0 1 0; 1 0 1];
    res.proc_dir = '../analysis_data/analysis/Mito/210806_raw';
    res.traj_type = 'track';

    res.constr = struct();
    res.constr.mask = 0;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=0_rad=0.75_th=1.1.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]); %12
end