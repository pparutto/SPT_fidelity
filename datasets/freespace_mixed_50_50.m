function res = freespace_mixed_50_50(base_dir, reps)
    res = struct();
    res.name = 'freespace_mixed_50_50';
    res.base_dir = base_dir;

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_1_60000', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_5_12000', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_10_6000', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_15_4000', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_20_3000', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_25_2400', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_30_2000', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_35_1715', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_40_1500', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_45_1334', k)];
        res.data = [res.data; sprintf('%d/0.5_0.1_3.82_50_1200', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'0.5_0_1'; '0.5_0_5'; '0.5_0_10'; '0.5_0_15'; '0.5_0_20'; ...
        '0.5_0_25'; '0.5_0_30'; '0.5_0_35'; '0.5_0_40'; '0.5_0_45'; '0.5_0_50'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/freespace_mixed/';
    res.traj_type = 'simu';
    res.params = {};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.1);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end