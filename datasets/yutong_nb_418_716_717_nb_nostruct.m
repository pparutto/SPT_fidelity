function res = yutong_nb_418_716_717_nb_nostruct()
    res = struct();
    res.name = 'yutong_nb_418_716_717_nb+APP_nostruct';
    res.pxsize = 0.0645;
    res.base_dir = '../tracking/intrabody/ib+APP';
    res.data = {'C3-240122_Halo_cell10_MMStack_Pos0_c.ome.tif';
                'C3-240122_Halo_cell4_MMStack_Pos0_c.ome.tif';
                'C3-240125_Halo_cell10_MMStack_Pos0_c.ome.tif';
                'C3-240125_Halo_cell1_MMStack_Pos0_c.ome.tif';
                'C3-240201_Halo_cell9_MMStack_Pos0_c.ome.tif'};

    res.cat_idxs = [ones(length(res.data), 1)];
    res.cat_names = {''};

    res.cat_cols = [0 0 0];
    res.proc_dir = '../analysis/nanobody/ib+APP_nos';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    res.constr.mask = 0;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=0_rad=0.7_th=0.35.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]);
    res.track_handler.ignore = 'struct';
end