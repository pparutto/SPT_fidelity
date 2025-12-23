function res = bip_250121()
    res = struct();
    res.name = 'bip_250121';
    res.pxsize = 0.0645;
    res.data_dir = '';
    res.base_dir = '/mnt/data4/yutong/tracking/250121_chok1haloc7_2colSPTlocPA';
    res.data = {'cell10_CHX_MMStack_Pos0';
                'cell11_CHX+Tg1min_MMStack_Pos0';
                'cell12_CHX+Tg6min_MMStack_Pos0'};

    res.cat_idxs = [1 2 3];
    res.cat_names = {'Unt'; 'CHXTG1min'; 'CHXTG6min'};
    res.cat_cols = [0 0 0; 1 0 0; 1 0 1];

    res.proc_dir = '/mnt/data4/yutong/analysis/250121_chok1haloc7_2colSPTlocPA';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    %res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=0_rad=1.0_th=4.0.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]);
end