base_dir = '../simu_raw/simu';
ER_dir = 'ER';
mito_dir = 'mito';

pxsize = 0.024195525;

ER_structs = {'C2-Sec61b_Halo-paJF646+400uMOA_002.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
              'C2-Sec61b_Halo-paJF646+400uMBSA_009.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
              'C2-Sec61b_Halo-paJF646+400uMBSA_008.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
              'C2-Sec61b_Halo-paJF646+400uMBSA_005.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
              'C2-Sec61b_Halo-paJF646+400uMBSA_004.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
              'C2-Sec61b_Halo-paJF646+400uMBSA_001.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif'};

mito_structs = {'C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_4.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
                'C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_5.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
                'C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_7.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
                'C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_9.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif';
                'C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_10.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil.tif'};

ER_areas = zeros(length(ER_structs), 1) * nan;
ER_dens = zeros(length(ER_structs), 1) * nan;
for k=1:length(ER_structs)
    im = imread(sprintf('%s/%s/%s', base_dir, ER_dir, ER_structs{k}));
    ER_dens(k) = sum(im(:) > 0) / (size(im,1) * size(im,2));
    ER_areas(k) = sum(im(:) > 0) * pxsize^2;
end

display(sprintf('AVG ER area=%.3f μm^2', mean(ER_areas)))

mito_areas = zeros(length(mito_structs), 1) * nan;
mito_dens = zeros(length(mito_structs), 1) * nan;
for k=1:length(mito_structs)
    im = imread(sprintf('%s/%s/%s', base_dir, mito_dir, mito_structs{k}));
    mito_dens(k) = sum(im(:) > 0) / (size(im,1) * size(im,2));
    mito_areas(k) = sum(im(:) > 0) * pxsize^2;
end

display(sprintf('AVG mito area=%.3f μm^2', mean(mito_areas)))

figure
hold on
bar([mean(ER_dens), mean(mito_dens)] * 100)
plot(ones(length(ER_dens), 1) + (rand(length(ER_dens), 1) - 0.5) * 0.1, ER_dens * 100, 'xk')
plot(ones(length(mito_dens), 1) * 2 + (rand(length(mito_dens), 1) - 0.5) * 0.1, mito_dens * 100, 'xk')
hold off
axis square
ylabel('Occupied space (% of freespace)')
print('/tmp/ratio_occupied_space_ER_mito.svg', '-dsvg')