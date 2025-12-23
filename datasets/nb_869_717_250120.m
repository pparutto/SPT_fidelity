function res = nb_869_717_250120()
    res = struct();
    res.name = 'nb_869_717_250120';
    res.pxsize = 0.0645;
    res.base_dir = '/mnt/data2/SPT_method/tracking_opti/nanobody/869_717/250120';
    res.data = {'C3-cell1_MMStack_Pos0_c';
                'C3-cell2_MMStack_Pos0_c';
                'C3-cell3-2_MMStack_Pos0_c';
                'C3-cell3_MMStack_Pos0_c';
                'C3-cell4_MMStack_Pos0_c';
                'C3-cell5-2_MMStack_Pos0_c';
                'C3-cell6-2_MMStack_Pos0_c';
                'C3-cell6-3_MMStack_Pos0_c';
                'C3-cell6-4_MMStack_Pos0_c';
                'C3-cell6-5_MMStack_Pos0_c';
                'C3-cell6_MMStack_Pos0_c'};

    res.cat_idxs = [ones(length(res.data), 1)];
    res.cat_names = {''};

    res.cat_cols = [0 0 0];
    res.proc_dir = '/mnt/data2/SPT_method/analysis_opti/nanobody/869_717/250120';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    %res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=1_rad=0.6_th=0.55.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]);
end