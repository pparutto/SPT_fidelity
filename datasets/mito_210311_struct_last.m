function res = mito_210311_struct_last()
    res = struct();
    res.name = 'mito_210311_struct_last';
    res.pxsize = 0.0967821;
    res.base_dir = '../analysis_data/tracking/Mito/210311_laststruct';
    res.data = {'C1-210311_COS67_TOM20-Halo_Mito-mNeonG_untreated_3.czi.tif'};

    res.cat_idxs = [1];
    res.cat_names = {'TOMM'};
    res.cat_cols = [1 0 1];
    res.proc_dir = '../analysis_data/analysis/Mito/210311_laststruct';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=1_rad=0.75_th=1.0.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_struct', 1, [1 5 3 4 6 9]);
end