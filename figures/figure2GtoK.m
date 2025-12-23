addpath('..')
addpath('../datasets')
addpath('../external/plot2svg')


dats = yutong_260124_dATL_235();

ps = struct();
ps.mask = 1;
ps.dist = 2.8;
ps.framegap = 0;
min_tr_len = 15;
ps_str = dats.track_handler.track_params(ps, dats.params);

dx = 0.5;

frames = 0:7999;

dens = [];
avg_disp = [];

ana_1 = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{1}));
params_1 = ana_1.params;
ana_1 = ana_1.ana;
ana_a1 = load(sprintf('%s/%s/pipeline_5_ambiguities.mat', dats.proc_dir, dats.data{1}));
ana_a1 = ana_a1.ana;

i1 = find(cellfun(@(x) strcmp(x, ps_str), params_1.track_strs));
i2 = find(params_1.min_tr_lens == min_tr_len);

tab1 = ana_1.tabs{i1}{i2};
grid1 = Utils.gen_grid(tab1, dx);

ds1 = Utils.displacements(tab1);
avg_disp = [avg_disp mean(ds1)];
dens1 = [mean(arrayfun(@(i) sum(tab1(:,5) == i), frames)) std(arrayfun(@(i) sum(tab1(:,5) == i), frames))];
dens = [dens; dens1];
display(sprintf('Dens1 = %.1f %.1f', dens1(1), dens1(2)))

tab_cut1 = ana_a1.tabs_cut_ambigs{i1}{i2};
tab_cut1 = Utils.filter_trajectories_npts(tab_cut1, min_tr_len);
ds1_cut = Utils.displacements(tab_cut1);

pause(1)
figure
pause(1)
Utils.show_trajectories(tab1, 'rand')
axis([0 35 0 35])
daspect([1 1 1])
pause(1)
print(sprintf('/tmp/traj_%s_%s_minLen=%d.svg', dats.data{1}, ...
    params_1.track_strs{i1}, params_1.min_tr_lens(i2)), '-dsvg')
pause(1)

amap1 = Utils.ambig_map(ana_a1.ambig_pos{i1}{i2}, grid1, grid1);
ndisps_map1 = Utils.ndisps_map(tab1, grid1, grid1);
namap1 = amap1 ./ ndisps_map1;
colmap1 = zeros([size(namap1) 3]) * nan;
cm = jet(64);
cm(1,:) = [0.5 0.5 0.5];
minv = 0;
maxv = 1;
for u=1:size(namap1,1)
    for v=1:size(namap1,2)
        if ~isnan(namap1(u,v))
            colmap1(u,v,:) = cm(ceil(((namap1(u,v) - minv) ./ maxv).*63)+1, :);
        end
    end
end

pause(1)
figure
pause(1)
Utils.show_scalar_map(namap1, grid1, grid1, 0, 1);
colorbar()
axis([0 35 0 35])
daspect([1 1 1])
pause(1)
Utils.scalarmap_to_svg(colmap1, 1, dats.pxsize, ...
    sprintf('/tmp/percambig_map_%s_%s_minLen=%d_dx=%g.svg', dats.data{1}, ...
    params_1.track_strs{i1}, params_1.min_tr_lens(i2), dx));
pause(1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ana_2 = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{2}));
params_2 = ana_2.params;
ana_2 = ana_2.ana;

ana_a2 = load(sprintf('%s/%s/pipeline_5_ambiguities.mat', dats.proc_dir, dats.data{2}));
ana_a2 = ana_a2.ana;

i1 = find(cellfun(@(x) strcmp(x, ps_str), params_2.track_strs));
i2 = find(params_2.min_tr_lens == min_tr_len);

tab2 = ana_2.tabs{i1}{i2};
grid2 = Utils.gen_grid(tab2, dx);


sum_disps2 = ana_2.sum_disps{i1}{i2};
avg_disps2 = ana_2.sum_disps{i1}{i2} ./ ana_2.tlengths{i1}{i2};
ds2 = Utils.displacements(ana_2.tabs{i1}{i2});
avg_disp = [avg_disp mean(ds2)];
tlen2 = ana_2.tlengths{i1}{i2};
dens2 = [mean(arrayfun(@(i) sum(tab2(:,5) == i), frames)) std(arrayfun(@(i) sum(tab2(:,5) == i), frames))];
dens = [dens; dens2];
display(sprintf('Dens2 = %.1f %.1f', dens2(1), dens2(2)))

tab_cut2 = ana_a2.tabs_cut_ambigs{i1}{i2};
tab_cut2 = Utils.filter_trajectories_npts(tab_cut2, min_tr_len);
ds2_cut = Utils.displacements(tab_cut2);

pause(1)
figure
pause(1)
Utils.show_trajectories(ana_2.tabs{i1}{i2}, 'rand')
axis([0 35 0 35])
daspect([1 1 1])
pause(1)
plot2svg(sprintf('/tmp/traj_%s_%s_minLen=%d.svg', dats.data{2}, ...
     params_2.track_strs{i1}, params_2.min_tr_lens(i2)))
pause(1)

amap2 = Utils.ambig_map(ana_a2.ambig_pos{i1}{i2}, grid2, grid2);
ndisps_map2 = Utils.ndisps_map(tab2, grid2, grid2);
namap2 = amap2 ./ ndisps_map2;
colmap2 = zeros([size(namap2) 3]) * nan;
cm = jet(64);
cm(1,:) = [0.5 0.5 0.5];
minv = 0;
maxv = 1;
for u=1:size(namap2,1)
    for v=1:size(namap2,2)
        if ~isnan(namap2(u,v))
            colmap2(u,v,:) = cm(ceil(((namap2(u,v) - minv) ./ maxv).*63)+1,:);
        end
    end
end

pause(1)
figure
pause(1)
Utils.show_scalar_map(namap2, grid2, grid2, 0, 1);
colorbar()
axis([0 35 0 35])
daspect([1 1 1])
pause(1)
Utils.scalarmap_to_svg(colmap2, 1, dats.pxsize, ...
sprintf('/tmp/percambig_map_%s_%s_minLen=%d_dx=%g.svg', dats.data{2}, ...
params_2.track_strs{i1}, params_2.min_tr_lens(i2), dx));
pause(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause(1)
figure
pause(1)
bar([length(ds1) length(ds1_cut) length(ds2) length(ds2_cut)])
axis square
ylabel('Number of displacements')
pause(1)
print(sprintf('/tmp/ndisps_cut_%s_%s_minLen=%d.svg', dats.data{1}, ...
    params_2.track_strs{i1}, params_2.min_tr_lens(i2)), '-dsvg')
pause(1)

display(sprintf('1: %d %d ; 2: %d %d', size(ana_a1.ambig_idxs{i1}{i2}, 1), length(ds1), ...
    size(ana_a2.ambig_idxs{i1}{i2}, 1), length(ds2)));

pause(1)
figure
pause(1)
bar([ana_a1.ambig_disps{i1}(i2) ana_a2.ambig_disps{i1}(i2)] * 100)
axis square
ylabel('% ambiguity')
pause(1)
print(sprintf('/tmp/percambig_%s_%s_minLen=%d.svg', dats.data{1}, ...
    params_2.track_strs{i1}, params_2.min_tr_lens(i2)), '-dsvg')
pause(1)

ambig_trs1 = length(unique(ana_a1.ambig_idxs{i1}{i2}(:,1))) / length(unique(tab1(:,1))) * 100;
ambig_trs2 = length(unique(ana_a2.ambig_idxs{i1}{i2}(:,1))) / length(unique(tab2(:,1))) * 100;

pause(1)
figure
pause(1)
bar([ambig_trs1 ambig_trs2])
axis square
ylabel('% affected trajs.')
ylim([0 100])
pause(1)
print(sprintf('/tmp/perc_ambig_traj_%s_%s_minLen=%d.svg', dats.data{1}, ...
    params_2.track_strs{i1}, params_2.min_tr_lens(i2)), '-dsvg')
pause(1)