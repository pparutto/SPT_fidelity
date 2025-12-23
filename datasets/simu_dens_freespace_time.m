function res = simu_dens_freespace_time(base_dir, reps)
    res = struct();
    res.name = 'simu_freespace';
    res.base_dir = base_dir;

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_1_0.0001_60000', k)];
        res.data = [res.data; sprintf('%d/1_5_0.0001_12000', k)];
        res.data = [res.data; sprintf('%d/1_10_0.0001_6000', k)];
        res.data = [res.data; sprintf('%d/1_15_0.0001_4000', k)];
        res.data = [res.data; sprintf('%d/1_20_0.0001_3000', k)];
        res.data = [res.data; sprintf('%d/1_25_0.0001_2400', k)];
        res.data = [res.data; sprintf('%d/1_30_0.0001_2000', k)];
        res.data = [res.data; sprintf('%d/1_35_0.0001_1715', k)];
        res.data = [res.data; sprintf('%d/1_40_0.0001_1500', k)];
        res.data = [res.data; sprintf('%d/1_45_0.0001_1334', k)];
        res.data = [res.data; sprintf('%d/1_50_0.0001_1200', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.0001'; '5_0.0001'; '10_0.0001'; '15_0.0001'; '20_0.0001'; ...
        '25_0.0001'; '30_0.0001'; '35_0.0001'; '40_0.0001'; '45_0.0001'; '50_0.0001'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/freespace3';
    res.traj_type = 'simu';
    res.params = {};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.0001);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end