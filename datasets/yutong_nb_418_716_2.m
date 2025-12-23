function res = yutong_nb_418_716_2()
    res = struct();
    res.name = 'yutong_nb_418_716_2';
    res.pxsize = 0.0645;
    res.base_dir = '../analysis_data/tracking/intrabody/ib';
    res.data = {'C2-240124_Halo_cell3_MMStack_Pos0_c.ome.tif';
                'C2-240124_Halo_cell4_MMStack_Pos0_c.ome.tif';
                'C2-240127_Halo_cell1_MMStack_Pos0_c.ome.tif';
                'C2-240130_Halo_cell12_MMStack_Pos0_c.ome.tif';
                'C2-240130_Halo_cell1_MMStack_Pos0_c.ome.tif'};

    res.cat_idxs = [ones(length(res.data), 1)];
    res.cat_names = {''};

    res.cat_cols = [0 0 0];
    res.proc_dir = '../analysis_data/analysis/intrabody/ib';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=1_rad=0.7_th=0.35.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_struct', 1, [1 5 3 4 6]);
end