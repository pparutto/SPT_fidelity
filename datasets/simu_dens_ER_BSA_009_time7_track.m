function res = simu_dens_ER_BSA_009_time7_track(base_dir, reps)
    res = struct();
    res.name = 'simu_ER_BSA_009_7_track';
    res.base_dir = sprintf('%s/C2-Sec61b_Halo-paJF646+400uMBSA_009.czi', base_dir);

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_1_0.0625_60000', k)];
        res.data = [res.data; sprintf('%d/1_5_0.0625_12000', k)];
        res.data = [res.data; sprintf('%d/1_10_0.0625_6000', k)];
        res.data = [res.data; sprintf('%d/1_15_0.0625_4000', k)];
        res.data = [res.data; sprintf('%d/1_20_0.0625_3000', k)];
        res.data = [res.data; sprintf('%d/1_25_0.0625_2400', k)];
        res.data = [res.data; sprintf('%d/1_30_0.0625_2000', k)];
        res.data = [res.data; sprintf('%d/1_35_0.0625_1715', k)];
        res.data = [res.data; sprintf('%d/1_40_0.0625_1500', k)];
        res.data = [res.data; sprintf('%d/1_45_0.0625_1334', k)];
        res.data = [res.data; sprintf('%d/1_50_0.0625_1200', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.0625'; '5_0.0625'; '10_0.0625'; '15_0.0625'; '20_0.0625'; ...
        '25_0.0625'; '30_0.0625'; '35_0.0625'; '40_0.0625'; '45_0.0625'; '50_0.0625'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/ER/C2-Sec61b_Halo-paJF646+400uMBSA_009.czi_track';
    res.traj_type = 'track';
    res.params = {'dist'; 'distgap'; 'framegap'};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.0625);
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_', 1, [1 5 3 4]);
    res.track_handler.ignore = 'struct';
end