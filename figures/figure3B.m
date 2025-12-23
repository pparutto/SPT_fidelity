addpath('..')
addpath('../datasets/')
addpath('../external/plot2svg/')

dist_ths = 0.2:0.2:6;

% dats = simu_dens_mito_Tom20mNeonGreen5_time13_track(1);
% %path names got changed btw raw and analysis archives
% dats.base_dir = '../simu/mito/density2/C2-210505_COS7_TOMM20-Halo-PAJF646_Mito-mNeonGreen_5.czi';
% l = 8;
% dth_idx = 6;
% 
% dats = simu_dens_ER_BSA_008_time13_track(3);
% %%path names got changed btw raw and analysis archives
% dats.base_dir = '../simu/ER/density2/C2-Sec61b_Halo-paJF646+400uMBSA_008.czi';
% l = 8;
% dth_idx = 8;

dats = simu_dens_lines_31_time13_track(1);
l = 8;
dth_idx = 6;

g_dat = csvread(sprintf('%s/%s/tracks_gdist_dist=%.1f_structdist=6.1.csv', dats.base_dir, dats.data{l}, dist_ths(dth_idx)));

ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{l}));
params = ana.params;
ana = ana.ana;

tab = ana.tabs{dth_idx}{1};

tr_err_is = [];
for k=unique(tab(:,1))'
    tr_idx = find(tab(:,1) == k);
    tr_idx = tr_idx(1:(end-1));
    if any(g_dat(tr_idx) > (dist_ths(dth_idx) * 1.1))
        tr_err_is = [tr_err_is; k];
    end
end

figure
hold on
for k=tr_err_is(1:20:end)'
    tr = tab(tab(:,1) == k, :);
    tr_idx = find(tab(:,1) == k);

    for l=1:(size(tr,1)-1)
        if g_dat(tr_idx(l)) > (dist_ths(dth_idx) * 1.1)
            plot(tr([l l+1], 3), tr([l l+1], 4), 'r')
        else
            plot(tr([l l+1], 3), tr([l l+1], 4), 'k')
        end
    end
end
hold off
axis([0 10.2 0 10.2])
daspect([1 1 1])
plot2svg(sprintf('/tmp/trajs_gerr_%s_%d_%s_subsamps.svg', dats.name, l, params.track_strs{dth_idx}));