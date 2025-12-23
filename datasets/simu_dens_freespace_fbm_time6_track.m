function res = simu_dens_freespace_fbm_time6_track(base_dir, reps, trck_ps, H)
    res = struct();
    res.H = H;
    res.trck_prefix = trck_ps.prefix;
    res.name = sprintf('simu_freespace_fbm_%g_time6_%s', H, trck_ps.prefix);
    res.base_dir = base_dir;

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/%g_1_1_0.0156_60000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_5_0.0156_12000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_10_0.0156_6000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_15_0.0156_4000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_20_0.0156_3000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_25_0.0156_2400', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_30_0.0156_2000', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_35_0.0156_1715', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_40_0.0156_1500', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_45_0.0156_1334', k, H)];
        res.data = [res.data; sprintf('%d/%g_1_50_0.0156_1200', k, H)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.0156'; '5_0.0156'; '10_0.0156'; '15_0.0156'; '20_0.0156'; ...
        '25_0.0156'; '30_0.0156'; '35_0.0156'; '40_0.0156'; '45_0.0156'; '50_0.0156'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = sprintf('../analysis_simu/analysis/simu/freespace_fbm2_%s/%g', trck_ps.prefix, H);
    res.traj_type = 'track';
    res.params = trck_ps.params;

    res.constr = struct();
    res.constr.framegap = 0;

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.0156);
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, trck_ps.prefix, 1, trck_ps.col_idxs);
    res.track_handler.ignore = 'struct';
end