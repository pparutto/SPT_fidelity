function res = simu_dens_ER_BSA_008_time12(base_dir, reps)
    res = struct();
    res.name = 'simu_ER_BSA_008_12';
    res.base_dir = sprintf('%s/C2-Sec61b_Halo-paJF646+400uMBSA_008.czi', base_dir);

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_1_0.7656_60000', k)];
        res.data = [res.data; sprintf('%d/1_5_0.7656_12000', k)];
        res.data = [res.data; sprintf('%d/1_10_0.7656_6000', k)];
        res.data = [res.data; sprintf('%d/1_15_0.7656_4000', k)];
        res.data = [res.data; sprintf('%d/1_20_0.7656_3000', k)];
        res.data = [res.data; sprintf('%d/1_25_0.7656_2400', k)];
        res.data = [res.data; sprintf('%d/1_30_0.7656_2000', k)];
        res.data = [res.data; sprintf('%d/1_35_0.7656_1715', k)];
        res.data = [res.data; sprintf('%d/1_40_0.7656_1500', k)];
        res.data = [res.data; sprintf('%d/1_45_0.7656_1334', k)];
        res.data = [res.data; sprintf('%d/1_50_0.7656_1200', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.7656'; '5_0.7656'; '10_0.7656'; '15_0.7656'; '20_0.7656'; ...
        '25_0.7656'; '30_0.7656'; '35_0.7656'; '40_0.7656'; '45_0.7656'; '50_0.7656'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/ER/C2-Sec61b_Halo-paJF646+400uMBSA_008.czi';
    res.traj_type = 'simu';
    res.params = {};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.7656);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end