function res = simu_dens_ER_BSA_005_time10(base_dir, reps)
    res = struct();
    res.name = 'simu_ER_BSA_005_10';
    res.base_dir = sprintf('%s/C2-Sec61b_Halo-paJF646+400uMBSA_005.czi', base_dir);

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_1_0.3906_60000', k)];
        res.data = [res.data; sprintf('%d/1_5_0.3906_12000', k)];
        res.data = [res.data; sprintf('%d/1_10_0.3906_6000', k)];
        res.data = [res.data; sprintf('%d/1_15_0.3906_4000', k)];
        res.data = [res.data; sprintf('%d/1_20_0.3906_3000', k)];
        res.data = [res.data; sprintf('%d/1_25_0.3906_2400', k)];
        res.data = [res.data; sprintf('%d/1_30_0.3906_2000', k)];
        res.data = [res.data; sprintf('%d/1_35_0.3906_1715', k)];
        res.data = [res.data; sprintf('%d/1_40_0.3906_1500', k)];
        res.data = [res.data; sprintf('%d/1_45_0.3906_1334', k)];
        res.data = [res.data; sprintf('%d/1_50_0.3906_1200', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.3906'; '5_0.3906'; '10_0.3906'; '15_0.3906'; '20_0.3906'; ...
        '25_0.3906'; '30_0.3906'; '35_0.3906'; '40_0.3906'; '45_0.3906'; '50_0.3906'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/ER/C2-Sec61b_Halo-paJF646+400uMBSA_005.czi';
    res.traj_type = 'simu';
    res.params = {};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.3906);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end