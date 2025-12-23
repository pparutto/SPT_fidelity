function res = yutong_nb_418_716_717_240123()
    res = struct();
    res.name = 'yutong_nb_418_716_717_240123';
    res.pxsize = 0.0645;
    res.base_dir = '../analysis_data/tracking/intrabody/ib+APP';
    res.data = {'C3-cell1_MMStack_Pos0_c_1in5.ome.tif'};

    res.cat_idxs = [ones(length(res.data), 1)];
    res.cat_names = {''};

    res.cat_cols = [0 0 0];
    res.proc_dir = '../analysis_data/analysis/intrabody/ib+APP';
    res.traj_type = 'track';

    res.constr = struct();
    res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, '', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]);
    res.track_handler.ignore = 'struct';
end