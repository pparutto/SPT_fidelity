function res = simu_dens_lines_31_time8_track(base_dir, reps)
    res = struct();
    res.name = 'simu_lines_31_8_track';
    res.base_dir = base_dir;

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_1_0.146_60000', k)];
        res.data = [res.data; sprintf('%d/1_5_0.146_12000', k)];
        res.data = [res.data; sprintf('%d/1_10_0.146_6000', k)];
        res.data = [res.data; sprintf('%d/1_15_0.146_4000', k)];
        res.data = [res.data; sprintf('%d/1_20_0.146_3000', k)];
        res.data = [res.data; sprintf('%d/1_25_0.146_2400', k)];
        res.data = [res.data; sprintf('%d/1_30_0.146_2000', k)];
        res.data = [res.data; sprintf('%d/1_35_0.146_1715', k)];
        res.data = [res.data; sprintf('%d/1_40_0.146_1500', k)];
        res.data = [res.data; sprintf('%d/1_45_0.146_1334', k)];
        res.data = [res.data; sprintf('%d/1_50_0.146_1200', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.146'; '5_0.146'; '10_0.146'; '15_0.146'; '20_0.146'; ...
        '25_0.146'; '30_0.146'; '35_0.146'; '40_0.146'; '45_0.146'; '50_0.146'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly_track';
    res.traj_type = 'track';
    res.params = {'dist'; 'distgap'; 'framegap'};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.146);
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_', 1, [1 5 3 4]);
    res.track_handler.ignore = 'struct';
end