function res = ineuron_737_290124()
    res = struct();
    res.name = 'ineuron_737_290124';
    res.pxsize = 0.0967821;
    res.imsize = [512 512] * res.pxsize;
    res.base_dir = '../analysis_data/tracking/290124_ineurons_737/data';
    res.data = {'Image 7_1_SPT.czi'};

    res.cat_idxs = [ones(length(res.data), 1)];
    res.cat_names = {''};

    res.cat_cols = [0 0 0];
    res.proc_dir = '../analysis_data/analysis/290124_ineurons_737/data';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    res.constr.mask = 0;
    res.constr.framegap = 0;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=1_rad=1.5_th=0.2.csv', {'th'}, 4);
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_', 1, [1 5 3 4 6]);
    %res.track_handler.frameid = 5;
    res.track_handler.ignore = 'struct';
end