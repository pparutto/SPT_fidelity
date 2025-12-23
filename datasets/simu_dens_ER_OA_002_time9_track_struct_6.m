function res = simu_dens_ER_OA_002_time9_track_struct_6(base_dir, reps)
    res = struct();
    res.name = 'simu_ER_OA_002_9_track_struct_6_v3';
    res.base_dir = sprintf('%s/C2-Sec61b_Halo-paJF646+400uMOA_002.czi', base_dir);

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_1_0.25_60000', k)];
        res.data = [res.data; sprintf('%d/1_5_0.25_12000', k)];
        res.data = [res.data; sprintf('%d/1_10_0.25_6000', k)];
        res.data = [res.data; sprintf('%d/1_15_0.25_4000', k)];
        res.data = [res.data; sprintf('%d/1_20_0.25_3000', k)];
        res.data = [res.data; sprintf('%d/1_25_0.25_2400', k)];
        res.data = [res.data; sprintf('%d/1_30_0.25_2000', k)];
        res.data = [res.data; sprintf('%d/1_35_0.25_1715', k)];
        res.data = [res.data; sprintf('%d/1_40_0.25_1500', k)];
        res.data = [res.data; sprintf('%d/1_45_0.25_1334', k)];
        res.data = [res.data; sprintf('%d/1_50_0.25_1200', k)];
        res.cat_idxs = [res.cat_idxs; k * ones(11, 1)];
    end

    res.cat_names = {'1_0.25'; '5_0.25'; '10_0.25'; '15_0.25'; '20_0.25'; ...
        '25_0.25'; '30_0.25'; '35_0.25'; '40_0.25'; '45_0.25'; '50_0.25'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/ER/C2-Sec61b_Halo-paJF646+400uMOA_002.czi_track_struct_6_v3';
    res.traj_type = 'track';
    res.params = {'dist'; 'distgap'; 'framegap'};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.25);
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_struct_6.1_v3', 1, [1 5 3 4]);
end