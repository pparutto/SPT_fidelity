function res = simu_dens_freespace_fbm_time13(base_dir, reps, H)
    res = struct();
    res.H = H;
    res.name = sprintf('simu_freespace_fbm_%g_13', H);
    res.base_dir = base_dir;

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/%g_1_1_1_60000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_5_1_12000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_10_1_6000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_15_1_4000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_20_1_3000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_25_1_2400', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_30_1_2000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_35_1_1715', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_40_1_1500', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_45_1_1334', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_50_1_1200', k, H)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_1'; '5_1'; '10_1'; '15_1'; '20_1'; ...
        '25_1'; '30_1'; '35_1'; '40_1'; '45_1'; '50_1'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = sprintf('../analysis_simu/analysis/simu/freespace_fbm/%g', H);
    res.traj_type = 'simu';
    res.params = {};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 1);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end