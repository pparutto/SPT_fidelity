function res = simu_dens_mito_Tom20mNeonGreen4_time4(base_dir, reps)
    res = struct();
    res.name = 'simu_mito_Tom20mNeonGreen4_4';
    res.base_dir = sprintf('%s/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_4.czi', base_dir);

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_1_0.0056_60000', k)];
        res.data = [res.data; sprintf('%d/1_5_0.0056_12000', k)];
        res.data = [res.data; sprintf('%d/1_10_0.0056_6000', k)];
        res.data = [res.data; sprintf('%d/1_15_0.0056_4000', k)];
        res.data = [res.data; sprintf('%d/1_20_0.0056_3000', k)];
        res.data = [res.data; sprintf('%d/1_25_0.0056_2400', k)];
        res.data = [res.data; sprintf('%d/1_30_0.0056_2000', k)];
        res.data = [res.data; sprintf('%d/1_35_0.0056_1715', k)];
        res.data = [res.data; sprintf('%d/1_40_0.0056_1500', k)];
        res.data = [res.data; sprintf('%d/1_45_0.0056_1334', k)];
        res.data = [res.data; sprintf('%d/1_50_0.0056_1200', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.0056'; '5_0.0056'; '10_0.0056'; '15_0.0056'; '20_0.0056'; ...
        '25_0.0056'; '30_0.0056'; '35_0.0056'; '40_0.0056'; '45_0.0056'; '50_0.0056'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/mito/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_4.czi';
    res.traj_type = 'simu';
    res.params = {};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.0056);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end