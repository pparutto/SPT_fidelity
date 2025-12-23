function res = simu_dens_freespace_time9_track(base_dir, reps, trck_ps)
    res = struct();
    res.trck_prefix = trck_ps.prefix;
    res.name = sprintf('simu_freespace_time9_%s', trck_ps.prefix);
    res.base_dir = base_dir;

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
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.25'; '5_0.25'; '10_0.25'; '15_0.25'; '20_0.25'; ...
        '25_0.25'; '30_0.25'; '35_0.25'; '40_0.25'; '45_0.25'; '50_0.25'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = sprintf('../analysis_simu/analysis/simu/freespace3_%s', trck_ps.prefix);
    res.traj_type = 'track';
    res.params = trck_ps.params;

    res.constr = struct();
    res.constr.framegap = 0;

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.25);
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, trck_ps.prefix, 1, trck_ps.col_idxs);
    res.track_handler.ignore = 'struct';
end