addpath('../datasets/')
addpath('../external')
addpath('../')

Nreps = 3;

ec = @(p,q) sqrt(sum((p - q).^2, 2));

ims = {'../simu_raw/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly.poly/struct_line_dist=31_pxsize=0.024195525_poly.poly_fov.tif_stabN=1.tif_comps_wDur=60001_wOvlp=0.tif'};
datdir = '../simu_raw/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly.poly';
datss = {{simu_dens_lines_31_time_track_struct(datdir, 1:Nreps); simu_dens_lines_31_time2_track_struct(datdir, 1:Nreps); simu_dens_lines_31_time3_track_struct(datdir, 1:Nreps);
          simu_dens_lines_31_time4_track_struct(datdir, 1:Nreps); simu_dens_lines_31_time5_track_struct(datdir, 1:Nreps); simu_dens_lines_31_time6_track_struct(datdir, 1:Nreps);
          simu_dens_lines_31_time7_track_struct(datdir, 1:Nreps); simu_dens_lines_31_time8_track_struct(datdir, 1:Nreps); simu_dens_lines_31_time9_track_struct(datdir, 1:Nreps);
          simu_dens_lines_31_time10_track_struct(datdir, 1:Nreps); simu_dens_lines_31_time11_track_struct(datdir, 1:Nreps); simu_dens_lines_31_time12_track_struct(datdir, 1:Nreps);
          simu_dens_lines_31_time13_track_struct(datdir, 1:Nreps)}};


% ims = {'../simu_raw/simu/ER/C2-Sec61b_Halo-paJF646+400uMBSA_001.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif_comps.tif_comps_wdur=60001_wovlp=0.tif';
%        '../simu_raw/simu/ER/C2-Sec61b_Halo-paJF646+400uMBSA_008.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif_comps.tif_comps_wdur=60001_wovlp=0.tif';
%        '../simu_raw/simu/ER/C2-Sec61b_Halo-paJF646+400uMOA_002.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif_comps.tif_comps_wdur=60001_wovlp=0.tif';
%        '../simu_raw/simu/ER/C2-Sec61b_Halo-paJF646+400uMBSA_004.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif_comps.tif_comps_wdur=60001_wovlp=0.tif';
%        '../simu_raw/simu/ER/C2-Sec61b_Halo-paJF646+400uMBSA_005.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif_comps.tif_comps_wdur=60001_wovlp=0.tif';
%        '../simu_raw/simu/ER/C2-Sec61b_Halo-paJF646+400uMBSA_009.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif_comps.tif_comps_wdur=60001_wovlp=0.tif'};
% datss = {{simu_dens_ER_BSA_001_time_track_struct_6(1:Nreps); simu_dens_ER_BSA_001_time2_track_struct_6(1:Nreps); simu_dens_ER_BSA_001_time3_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_001_time4_track_struct_6(1:Nreps); simu_dens_ER_BSA_001_time5_track_struct_6(1:Nreps); simu_dens_ER_BSA_001_time6_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_001_time7_track_struct_6(1:Nreps); simu_dens_ER_BSA_001_time8_track_struct_6(1:Nreps); simu_dens_ER_BSA_001_time9_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_001_time10_track_struct_6(1:Nreps); simu_dens_ER_BSA_001_time11_track_struct_6(1:Nreps); simu_dens_ER_BSA_001_time12_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_001_time13_track_struct_6(1:Nreps)};
%          {simu_dens_ER_BSA_008_time_track_struct_6(1:Nreps); simu_dens_ER_BSA_008_time2_track_struct_6(1:Nreps); simu_dens_ER_BSA_008_time3_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_008_time4_track_struct_6(1:Nreps); simu_dens_ER_BSA_008_time5_track_struct_6(1:Nreps); simu_dens_ER_BSA_008_time6_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_008_time7_track_struct_6(1:Nreps); simu_dens_ER_BSA_008_time8_track_struct_6(1:Nreps); simu_dens_ER_BSA_008_time9_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_008_time10_track_struct_6(1:Nreps); simu_dens_ER_BSA_008_time11_track_struct_6(1:Nreps); simu_dens_ER_BSA_008_time12_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_008_time13_track_struct_6(1:Nreps)};
%          {simu_dens_ER_OA_002_time_track_struct_6(1:Nreps); simu_dens_ER_OA_002_time2_track_struct_6(1:Nreps); simu_dens_ER_OA_002_time3_track_struct_6(1:Nreps);
%           simu_dens_ER_OA_002_time4_track_struct_6(1:Nreps); simu_dens_ER_OA_002_time5_track_struct_6(1:Nreps); simu_dens_ER_OA_002_time6_track_struct_6(1:Nreps);
%           simu_dens_ER_OA_002_time7_track_struct_6(1:Nreps); simu_dens_ER_OA_002_time8_track_struct_6(1:Nreps); simu_dens_ER_OA_002_time9_track_struct_6(1:Nreps);
%           simu_dens_ER_OA_002_time10_track_struct_6(1:Nreps); simu_dens_ER_OA_002_time11_track_struct_6(1:Nreps); simu_dens_ER_OA_002_time12_track_struct_6(1:Nreps);
%           simu_dens_ER_OA_002_time13_track_struct_6(1:Nreps)};
%          {simu_dens_ER_BSA_004_time_track_struct_6(1:Nreps); simu_dens_ER_BSA_004_time2_track_struct_6(1:Nreps); simu_dens_ER_BSA_004_time3_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_004_time4_track_struct_6(1:Nreps); simu_dens_ER_BSA_004_time5_track_struct_6(1:Nreps); simu_dens_ER_BSA_004_time6_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_004_time7_track_struct_6(1:Nreps); simu_dens_ER_BSA_004_time8_track_struct_6(1:Nreps); simu_dens_ER_BSA_004_time9_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_004_time10_track_struct_6(1:Nreps); simu_dens_ER_BSA_004_time11_track_struct_6(1:Nreps); simu_dens_ER_BSA_004_time12_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_004_time13_track_struct_6(1:Nreps)};
%          {simu_dens_ER_BSA_005_time_track_struct_6(1:Nreps); simu_dens_ER_BSA_005_time2_track_struct_6(1:Nreps); simu_dens_ER_BSA_005_time3_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_005_time4_track_struct_6(1:Nreps); simu_dens_ER_BSA_005_time5_track_struct_6(1:Nreps); simu_dens_ER_BSA_005_time6_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_005_time7_track_struct_6(1:Nreps); simu_dens_ER_BSA_005_time8_track_struct_6(1:Nreps); simu_dens_ER_BSA_005_time9_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_005_time10_track_struct_6(1:Nreps); simu_dens_ER_BSA_005_time11_track_struct_6(1:Nreps); simu_dens_ER_BSA_005_time12_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_005_time13_track_struct_6(1:Nreps)};
%          {simu_dens_ER_BSA_009_time_track_struct_6(1:Nreps); simu_dens_ER_BSA_009_time2_track_struct_6(1:Nreps); simu_dens_ER_BSA_009_time3_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_009_time4_track_struct_6(1:Nreps); simu_dens_ER_BSA_009_time5_track_struct_6(1:Nreps); simu_dens_ER_BSA_009_time6_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_009_time7_track_struct_6(1:Nreps); simu_dens_ER_BSA_009_time8_track_struct_6(1:Nreps); simu_dens_ER_BSA_009_time9_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_009_time10_track_struct_6(1:Nreps); simu_dens_ER_BSA_009_time11_track_struct_6(1:Nreps); simu_dens_ER_BSA_009_time12_track_struct_6(1:Nreps);
%           simu_dens_ER_BSA_009_time13_track_struct_6(1:Nreps)}};


% ims = {'../simu_raw/simu/mito/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_4.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
%        '../simu_raw/simu/mito/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_5.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
%        '../simu_raw/simu/mito/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_7.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
%        '../simu_raw/simu/mito/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_9.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
%        '../simu_raw/simu/mito/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_10.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif'};
% datss = {{simu_dens_mito_Tom20mNeonGreen4_time_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time2_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time3_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen4_time4_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time5_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time6_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen4_time7_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time8_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time9_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen4_time10_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time11_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen4_time12_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen4_time13_track_struct_6(1:Nreps)};
%          {simu_dens_mito_Tom20mNeonGreen5_time_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time2_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time3_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen5_time4_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time5_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time6_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen5_time7_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time8_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time9_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen5_time10_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time11_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen5_time12_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen5_time13_track_struct_6(1:Nreps)};
%          {simu_dens_mito_Tom20mNeonGreen7_time_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time2_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time3_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen7_time4_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time5_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time6_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen7_time7_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time8_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time9_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen7_time10_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time11_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen7_time12_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen7_time13_track_struct_6(1:Nreps)};
%          {simu_dens_mito_Tom20mNeonGreen9_time_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time2_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time3_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen9_time4_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time5_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time6_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen9_time7_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time8_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time9_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen9_time10_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time11_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen9_time12_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen9_time13_track_struct_6(1:Nreps)};
%          {simu_dens_mito_Tom20mNeonGreen10_time_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time2_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time3_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen10_time4_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time5_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time6_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen10_time7_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time8_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time9_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen10_time10_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time11_track_struct_6(1:Nreps); simu_dens_mito_Tom20mNeonGreen10_time12_track_struct_6(1:Nreps);
%           simu_dens_mito_Tom20mNeonGreen10_time13_track_struct_6(1:Nreps)}};

rev_order = 0;

idxs1 = 1:length(datss);
if rev_order
    idxs1 = length(datss):-1:1;
end

for n=idxs1
    im = imread(ims{n});

    idxs2 = 1:length(datss{n});
    if rev_order
        idxs2 = length(datss{n}):-1:1;
    end

    for k=idxs2
        idxs3 = 1:length(datss{n}{k}.data);
        if rev_order
            idxs3 = length(datss{n}{k}.data):-1:1;
        end

        for l=idxs3
            display(sprintf('%d %d: %s %s', k, l, datss{n}{k}.name, datss{n}{k}.data{l}))
            out_fname = sprintf('%s/%s/ambig_de_dg.mat', datss{n}{k}.proc_dir, datss{n}{k}.data{l});

            if isfile(out_fname)
              display(sprintf('Skipped[%d][%d/%d]: %s', k, l, length(datss{n}{k}.data), datss{n}{k}.data{l}));
              continue
            end

            DT = datss{n}{k}.spots_handler.dt;

            spts = datss{n}{k}.spots_handler.load_spots(sprintf('%s/%s/%s', datss{n}{k}.base_dir, datss{n}{k}.data{l}, datss{n}{k}.spots_handler.fname));
            spts(:,1) = round(round(spts(:,1),5) / DT);

            ambig_fname = sprintf('%s/%s/ambig_struct_6.1_dist=6.0_distgap=0.0_framegap=0.csv', datss{n}{k}.base_dir, datss{n}{k}.data{l});
            ambig_dat = csvread(ambig_fname);
            ambig = cell(size(spts, 1), 1);
            u = 1;
            while u <= size(ambig_dat, 1)
                tmp = [];
                for v=1:ambig_dat(u,2)
                    tmp = [tmp; ambig_dat(u+v,:)];
                end
                tmp(:,1) = tmp(:,1) + 1;
                ambig{ambig_dat(u,1)+1} = tmp;
                u = u + ambig_dat(u,2) + 1;
            end

            ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', datss{n}{k}.proc_dir, datss{n}{k}.data{l}));
            hash_track = ana.hash;
            params = ana.params;
            ana = ana.ana;

            ambig_pos = cell(length(ana.tabs), 1);
            ndisps = zeros(length(ana.tabs), 1);
            for m=1:length(ana.tabs)
                tab = ana.tabs{m}{1};
                tab(:,2) = round(round(tab(:,2),5) / DT);

                ambig_pos{m} = zeros(0, 3);
                for u=1:(size(tab,1)-1)
                    if tab(u+1, 1) ~= tab(u,1)
                        continue
                    end
                    ndisps(m) = ndisps(m) + 1;

                    p = tab(u,:);
                    p_idx = find(ec(p(3:4), spts(:,2:3)) < 1e-7 & tab(u,2) == spts(:,1));
                    assert(length(p_idx) == 1)
                    succs = find(spts(:,1) == p(2)+1);
                    succs = succs(round(ec(p(3:4), spts(succs, 2:3)),6) <= params.dist(m));

                    p_ambigs = ambig{p_idx};
                    if isempty(p_ambigs)
                        continue
                    end
                    p_ambigs(:,2) = round(p_ambigs(:,2), 6);
                    p_ambigs(:,3) = round(p_ambigs(:,3), 6);

                    p_ambigs_succ = sort(p_ambigs(p_ambigs(:,2) <= params.dist(m),1));
                    if size(succs, 1) > size(p_ambigs_succ, 1)
                        neq = sum(round(ec(p(3:4), spts(succs, 2:3)),6) >= (params.dist(m) - 1e-5));
                        assert(size(p_ambigs_succ,1) + neq == size(succs,1))
                    else
                        assert(all(succs == p_ambigs_succ))
                    end

                    n_de = max([sum(p_ambigs(:,2) < params.dist(m)) - 1, 0]);
                    n_dg = max([sum(p_ambigs(:,3) < params.dist(m)) - 1, 0]);
    
                    if n_de > 0 || n_dg > 0
                        ambig_pos{m} = [ambig_pos{m}; u, n_de, n_dg];
                    end
                end
            end

            in_exp_track = datss{n}{k}.data{l};

            ana = struct();
            ana.ambig_pos = ambig_pos;
            ana.ndisps = ndisps;

            hash = DataHash(ana);
            save(out_fname, 'in_exp_track', 'ambig_fname', 'ana', 'hash', 'hash_track', 'params');
        end
    end
end

