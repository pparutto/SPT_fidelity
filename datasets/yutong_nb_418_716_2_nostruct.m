function res = yutong_nb_418_716_2_nostruct()
    res = struct();
    res.name = 'yutong_nb_418_716_2';
    res.pxsize = 0.0645;
    res.base_dir = '/mnt/data2/SPT_method/tracking_opti/nanobody/nb';
    res.data = {'C2-240124_Halo_cell3_MMStack_Pos0';
                'C2-240124_Halo_cell4_MMStack_Pos0';
                'C2-240127_Halo_cell1_MMStack_Pos0';
                'C2-240130_Halo_cell12_MMStack_Pos0';
                'C2-240130_Halo_cell1_MMStack_Pos0'};

    res.cat_idxs = [ones(length(res.data), 1)];
    res.cat_names = {''};

    res.cat_cols = [0 0 0];
    res.proc_dir = '/mnt/data2/SPT_method/analysis_opti/nanobody/nb';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    res.constr.mask = 0;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=0_rad=0.7_th=0.35.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]);
    res.track_handler.ignore = 'struct';
end