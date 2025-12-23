function res = yutong_260124_dATL_235()
    res = struct();
    res.name = '260124_dATL_235';
    res.pxsize = 0.0645;
    res.base_dir = '../analysis_data/tracking/dATL_HaloER';
    res.data = {'C2-cell6_405-1mW_MMStack_Pos0_c.ome.tif';
                'C2-cell6_405-58mW_MMStack_Pos0_c.ome.tif'};

    res.cat_idxs = [1 2];
    res.cat_names = {'lowDens', 'HighDens'};

    res.cat_cols = [0 0 0; 1 0 0];
    res.proc_dir = '../analysis_data/analysis/yutong/240126_Yutong_cosdATL_2.5ul_20ms';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=1_rad=1.1_th=0.3.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_', 1, [1 5 3 4 6]);
    res.track_handler.ignore = 'struct';
end