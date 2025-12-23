basedir = '/mnt/data2/SPT_method/simu/ER/ncolls';

structs = {'C2-Sec61b_Halo-paJF646+400uMBSA_001.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil_poly.poly';
           'C2-Sec61b_Halo-paJF646+400uMBSA_004.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil_poly.poly';
           'C2-Sec61b_Halo-paJF646+400uMBSA_005.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil_poly.poly';
           'C2-Sec61b_Halo-paJF646+400uMBSA_008.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil_poly.poly';
           'C2-Sec61b_Halo-paJF646+400uMBSA_009.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil_poly.poly';
           'C2-Sec61b_Halo-paJF646+400uMOA_002.czi_avg17_musical_4_6_50frames_croped46pxs_avg_norm_gauss1.5px_bin_close1px_erode1px_erode1px_dil_dil_poly.poly'};


reps = 1;

all_cnts = cell(length(structs),1);
for i1=1:length(structs)
    for nrep=reps
        dirs = dir(sprintf('%s/%s/%d', basedir, structs{i1}, nrep));
        all_cnts{i1} = cell(length(dirs)-2, 1);
        for i2=1:length(dirs)
            if strcmp(dirs(i2).name, '.') || strcmp(dirs(i2).name, '..')
                continue
            end
            display(sprintf('%d %d', i1, i2-2));

            lines = readlines(sprintf('%s/%s/ncolls', dirs(i2).folder, dirs(i2).name));
            lines = lines(1:(end-1));
            cnts = [];
            n = 0;
            for k=1:length(lines)
                if strcmp(lines{k}, '@')
                    cnts = [cnts; n];
                    n = 0;
                else
                    n = n + str2num(lines{k});
                end
            end
            all_cnts{i1}{i2} = cnts;
        end
    end
end

figure
hold on
for i=1:length(structs)
    plot(1:length(all_cnts{i}), cellfun(@(x) mean(x) / 9, all_cnts{i}))
end
hold off
ylabel('avg Number of collisions per displacement')
xlabel('characteristic length')
axis square
print('/tmp/avg_collisions_per_disps_ER.svg', '-dsvg')