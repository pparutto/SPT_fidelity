function res = simu_dens_freespace_fbm_time3(base_dir, reps, H)
    res = struct();
    res.H = H;
    res.name = sprintf('simu_freespace_fbm_%g_3', H);
    res.base_dir = base_dir;

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/%g_1_1_0.0025_60000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_5_0.0025_12000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_10_0.0025_6000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_15_0.0025_4000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_20_0.0025_3000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_25_0.0025_2400', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_30_0.0025_2000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_35_0.0025_1715', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_40_0.0025_1500', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_45_0.0025_1334', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_50_0.0025_1200', k, H)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.0025'; '5_0.0025'; '10_0.0025'; '15_0.0025'; '20_0.0025'; ...
        '25_0.0025'; '30_0.0025'; '35_0.0025'; '40_0.0025'; '45_0.0025'; '50_0.0025'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = sprintf('../analysis_simu/analysis/simu/freespace_fbm/%g', H);
    res.traj_type = 'simu';
    res.params = {};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.0025);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end