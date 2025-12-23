function res = testDat_track_struct(reps)
    res = struct();
    res.name = 'test_track_struct';
    res.base_dir = '/mnt/data4/SPT_method_moved_for_space/yutong_240123/240123_Yutong_dATL_20ms/cell6/sim/C1-cell6_MMStack_Pos0_c.ome.tif_avg51_FRAME2252_usharp2px_0.8_blur0.5px_Simple_Segmentation_bin_erodecric1px_adj_poly.poly';

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_30_1_2000', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.0001'; '5_0.0001'; '10_0.0001'; '15_0.0001'; '20_0.0001'; ...
        '25_0.0001'; '30_0.0001'; '35_0.0001'; '40_0.0001'; '45_0.0001'; '50_0.0001'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '/mnt/data4/SPT_method_moved_for_space/analysis_opti/test_track_struct';
    res.traj_type = 'track';
    res.params = {'dist'; 'distgap'; 'framegap'};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 1);
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_struct_6.1_v3', 1, [1 5 3 4]);
end