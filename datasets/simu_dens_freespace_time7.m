function res = simu_dens_freespace_time7(base_dir, reps)
    res = struct();
    res.name = 'simu_freespace_7';
    res.base_dir = base_dir;

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
    res.proc_dir = '../analysis_simu/analysis/simu/freespace3';
    res.traj_type = 'simu';
    res.params = {};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.0625);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end