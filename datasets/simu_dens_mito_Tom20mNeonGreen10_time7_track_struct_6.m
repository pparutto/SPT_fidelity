function res = simu_dens_mito_Tom20mNeonGreen10_time7_track_struct_6(base_dir, reps)
    res = struct();
    res.name = 'simu_mito_Tom20mNeonGreen10_7_track_struct_6_v3';
    res.base_dir = sprintf('%s/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_10.czi', base_dir);

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
        res.cat_idxs = [res.cat_idxs; k * ones(11, 1)];
    end

    res.cat_names = {'1_0.0625'; '5_0.0625'; '10_0.0625'; '15_0.0625'; '20_0.0625'; ...
        '25_0.0625'; '30_0.0625'; '35_0.0625'; '40_0.0625'; '45_0.0625'; '50_0.0625'};
    res.cat_cols = jet(length(res.cat_names));
    res.proc_dir = '../analysis_simu/analysis/simu/mito/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_10.czi_track_struct_6_v3';
    res.traj_type = 'track';
    res.params = {'dist'; 'distgap'; 'framegap'};

    res.constr = struct();

    res.spots_handler = SimuSpotsParser(res.base_dir, 'trajs.csv', {}, 0.0625);
    res.track_handler = SimuFileParser(res.base_dir, res.data, 1, 'trajs.csv');
end