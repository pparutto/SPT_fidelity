function res = simu_dens_freespace_time3_track(base_dir, reps, trck_ps)
    res = struct();
    res.trck_prefix = trck_ps.prefix;
    res.name = sprintf('simu_freespace_time3_%s', trck_ps.prefix);
    res.base_dir = base_dir;

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_1_0.0025_60000', k)];
        res.data = [res.data; sprintf('%d/1_5_0.0025_12000', k)];
        res.data = [res.data; sprintf('%d/1_10_0.0025_6000', k)];
        res.data = [res.data; sprintf('%d/1_15_0.0025_4000', k)];
        res.data = [res.data; sprintf('%d/1_20_0.0025_3000', k)];
        res.data = [res.data; sprintf('%d/1_25_0.0025_2400', k)];
        res.data = [res.data; sprintf('%d/1_30_0.0025_2000', k)];
        res.data = [res.data; sprintf('%d/1_35_0.0025_1715', k)];
        res.data = [res.data; sprintf('%d/1_40_0.0025_1500', k)];
        res.data = [res.data; sprintf('%d/1_45_0.0025_1334', k)];
        res.data = [res.data; sprintf('%d/1_50_0.0025_1200', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.0025'; '5_0.0025'; '10_0.0025'; '15_0.0025'; '20_0.0025'; ...
        '25_0.0025'; '30_0.0025'; '35_0.0025'; '40_0.0025'; '45_0.0025'; '50_0.0025'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = sprintf('../analysis_simu/analysis/simu/freespace3_%s', trck_ps.prefix);
    res.traj_type = 'track';
    res.params = trck_ps.params;

    res.constr = struct();
    res.constr.framegap = 0;

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.0025);
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, trck_ps.prefix, 1, trck_ps.col_idxs);
    res.track_handler.ignore = 'struct';
end