function res = mem_210806_struct_first()
    res = struct();
    res.name = 'mem_210806_struct_first';
    res.pxsize = 0.0967821;
    res.base_dir = '../analysis_data/tracking/Mem/210806_v3_firststruct';
    res.data = {'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_BSA_004.czi.tif'};

    res.cat_idxs = [1];
    res.cat_names = {'UNT'};
    res.cat_cols = [0 0 0];
    res.proc_dir = '../analysis_data/analysis/Mem/210806_struct_v3_firststruct';
    res.traj_type = 'track';

    res.constr = struct();
    res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=1_rad=0.75_th=1.0.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_struct', 1, [1 5 3 4 6 9]);
end