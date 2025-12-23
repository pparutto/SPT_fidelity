function res = yutong_nb_418_716_717_APP()
    res = struct();
    res.name = 'yutong_nb_418_716_717_APP';
    res.pxsize = 0.0645;
    res.base_dir = '../analysis_data/tracking/intrabody/APP';
    res.data = {'C3-240129_Snap_cell4_MMStack_Pos0_c.ome.tif';
                'C3-240130_Snap_cell2_MMStack_Pos0_c.ome.tif';
                'C3-240130_Snap_cell4_MMStack_Pos0_c.ome.tif';
                'C3-240130_Snap_cell9_MMStack_Pos0_c.ome.tif';
                'C3-240131_Snap_cell4_MMStack_Pos0_c.ome.tif'};

    res.cat_idxs = [ones(length(res.data), 1)];
    res.cat_names = {''};

    res.cat_cols = [0 0 0];
    res.proc_dir = '../analysis_data/analysis/intrabody/APP';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=1_rad=0.7_th=0.35.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_struct', 1, [1 5 3 4 6]);
end