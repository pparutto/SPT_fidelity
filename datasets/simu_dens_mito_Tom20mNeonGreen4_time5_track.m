function res = simu_dens_mito_Tom20mNeonGreen4_time5_track(base_dir, reps)
    res = struct();
    res.name = 'simu_mito_Tom20mNeonGreen4_5_track';
    res.base_dir = sprintf('%s/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_4.czi', base_dir);

    res.data = {};
    res.cat_idxs = [];
    for k=reps
        res.data = [res.data; sprintf('%d/1_1_0.01_60000', k)];
        res.data = [res.data; sprintf('%d/1_5_0.01_12000', k)];
        res.data = [res.data; sprintf('%d/1_10_0.01_6000', k)];
        res.data = [res.data; sprintf('%d/1_15_0.01_4000', k)];
        res.data = [res.data; sprintf('%d/1_20_0.01_3000', k)];
        res.data = [res.data; sprintf('%d/1_25_0.01_2400', k)];
        res.data = [res.data; sprintf('%d/1_30_0.01_2000', k)];
        res.data = [res.data; sprintf('%d/1_35_0.01_1715', k)];
        res.data = [res.data; sprintf('%d/1_40_0.01_1500', k)];
        res.data = [res.data; sprintf('%d/1_45_0.01_1334', k)];
        res.data = [res.data; sprintf('%d/1_50_0.01_1200', k)];
        res.cat_idxs = [res.cat_idxs; (1:11)'];
    end

    res.cat_names = {'1_0.01'; '5_0.01'; '10_0.01'; '15_0.01'; '20_0.01'; ...
        '25_0.01'; '30_0.01'; '35_0.01'; '40_0.01'; '45_0.01'; '50_0.01'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/mito/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_4.czi_track';
    res.traj_type = 'track';
    res.params = {'dist'; 'distgap'; 'framegap'};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.01);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end