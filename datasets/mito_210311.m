function res = mito_210311()
    res = struct();
    res.name = 'mito_210311';
    res.pxsize = 0.0967821;
    res.base_dir = '../analysis_data/tracking/Mito/210311';
    res.data = {'C1-210311_COS67_TOM20-Halo_Mito-mNeonG_untreated_3.czi.tif'};
    res.cat_idxs = [1];
    res.cat_names = {'TOMM'};
    res.cat_cols = [1 0 1];
    res.proc_dir = '../analysis_data/analysis/Mito/210311_raw';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    res.constr.mask = 0;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=0_rad=0.75_th=1.0.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]);
end