addpath('../datasets/')
addpath('..')

dats = yutong_nb_418_716_717_240123();

ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{1}));
params = ana.params;
ana = ana.ana;

min_tr_len = 10;

ps = struct();
ps.mask = 1;
ps.dist = 3;
ps.framegap = 0;
ps_str = dats.track_handler.track_params(ps, dats.params);


i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
i2 = find(params.min_tr_lens == min_tr_len);

tab = ana.tabs{i1}{i2};

avg_tr_nos = [];
for i=unique(tab(:,1))'
    avg_tr_nos = [avg_tr_nos; mean(Utils.displacements(tab(tab(:,1) == i, :)))];
end

pause(1)
tr_idxs = unique(tab(:,1));
cm = jet(64);
Mdisp = 0.6;
figure
pause(1)
hold on
for i=1:length(tr_idxs)
    tr = tab(tab(:,1) == tr_idxs(i), :);
    cidx = floor(single(avg_tr_nos(i) / Mdisp) * 63) + 1;
    if cidx > 64
        cidx = 64;
    end
    plot(tr(:,3), tr(:,4), 'Color', cm(cidx, :))
end
hold off
daspect([1 1 1])
clim([0 Mdisp])
colormap('Jet');
colorbar
pause(1)
plot2svg(sprintf('/tmp/trajs_disp_%s_%s.svg', dats.name, strrep(dats.data{1}, '/', '_')))


dats = yutong_nb_418_716_717_240123_struct();

ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{1}));
params = ana.params;
ana = ana.ana;

ps.mask = 1;
ps.dist = 1;
ps_str = dats.track_handler.track_params(ps, dats.params);


i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
i2 = find(params.min_tr_lens == min_tr_len);

tab = ana.tabs{i1}{i2};

struct_ambig_fname = 'ambig_struct_mask=1_rad=0.5_th=0.7_maxdist=2.1.csv';
spts = dats.spots_handler.load_spots(sprintf('%s/%s/%s', dats.base_dir, dats.data{1}, dats.spots_handler.fname));
ambig_g_dat = csvread(sprintf('%s/%s/%s', dats.base_dir, dats.data{1}, struct_ambig_fname));
[ambig_pos, ndisps] = Utils.ambiguities_graph_dist(spts, ambig_g_dat, tab(:, [1 5 3 4]), ps.dist);

a_idxs_dg = [];
for i=unique(tab(:,1))'
    tr = tab(tab(:,1) == i, :);
    tr_idxs = find(tab(:,1) == i);
    for j=1:size(tr,1)
        if ambig_pos(tr_idxs(j),2) > 0
            a_idxs_dg = [a_idxs_dg; tr(1,1) j];
        end
    end
end

tab_cut_dg = Utils.cut_ambiguities(tab, a_idxs_dg);
tab_cut_dg = Utils.filter_trajectories_npts(tab_cut_dg, min_tr_len);

tab = tab_cut_dg;

avg_tr_s = [];
for i=unique(tab(:,1))'
    avg_tr_s = [avg_tr_s; mean(Utils.displacements(tab(tab(:,1) == i, :)))];
end

pause(1)
tr_idxs = unique(tab(:,1));
cm = jet(64);
Mdisp = 0.3;
figure
pause(1)
hold on
for i=1:length(tr_idxs)
    tr = tab(tab(:,1) == tr_idxs(i), :);
    cidx = floor(single(avg_tr_s(i) / Mdisp) * 63) + 1;
    if cidx > 64
        cidx = 64;
    end
    plot(tr(:,3), tr(:,4), 'Color', cm(cidx, :))
end
hold off
daspect([1 1 1])
clim([0 Mdisp])
colormap('Jet');
colorbar
pause(1)
plot2svg(sprintf('/tmp/trajs_disp_%s_%s.svg', dats.name, strrep(dats.data{1}, '/', '_')))


bins = (0.002:0.004:1.5) * 100;
bins2 = (0.0015:0.003:1.5) * 100;

writematrix(avg_tr_nos, '/tmp/figS7b_nofidl.csv');
writematrix(avg_tr_s, '/tmp/figS7b_fidl.csv');


[o_nos, b_nos] = hist(avg_tr_nos / 0.03, bins2);
o_nos = smooth(o_nos, 5)';
[f_nos, gof_nos] = fit(b_nos', o_nos' / sum(o_nos), 'Gauss2', 'Robust', 'LAR', 'Lower', [0 0 0 0 8 0], 'Upper', [inf 10 inf inf 15 10], ...
     'Start', [0.025 3.4 2 0.02 11 10]);
ci_nos = confint(f_nos);
[o_s, b_s] = hist(avg_tr_s / 0.006, bins);
o_s = smooth(o_s, 5)';
[f_s, gof_s] = fit(b_s', o_s' / sum(o_s), 'Gauss2', 'Robust', 'LAR', 'Lower', [0 0 0 0 10 0], 'Upper', [inf 15 10 inf 30 10]);
ci_s = confint(f_s);



display(sprintf('%.1f [%.1f %.1f]', f_nos.a1 / (f_nos.a1 + f_nos.a2) * 100, ...
    ci_nos(1,1) / (f_nos.a1 + f_nos.a2) * 100, ci_nos(2,1) / (f_nos.a1 + f_nos.a2) * 100));

display(sprintf('%.1f [%.1f %.1f]', f_s.a1 / (f_s.a1 + f_s.a2) * 100, ...
    ci_s(1,1) / (f_s.a1 + f_s.a2) * 100, ci_s(2,1) / (f_s.a1 + f_s.a2) * 100));

figure
hold on
plot(b_nos * 0.03, o_nos / sum(o_nos), 'k')
plot(b_nos * 0.03, f_nos.a1 * exp(-((b_nos - f_nos.b1) / f_nos.c1).^2), 'b--')
plot(b_nos * 0.03, f_nos.a2 * exp(-((b_nos - f_nos.b2) / f_nos.c2).^2), 'b--')
plot(b_nos * 0.03, f_nos.a1 * exp(-((b_nos - f_nos.b1) / f_nos.c1).^2) + f_nos.a2 * exp(-((b_nos - f_nos.b2) / f_nos.c2).^2), 'r')
hold off
axis square
xlim([0 1])
print(sprintf('/tmp/disp_distrib_nos_%s.svg', strrep(dats.data{1}, '/', '_')), '-dsvg')


figure
hold on
plot(b_s * 0.006, o_s / sum(o_s), 'k')
plot(b_s * 0.006, f_s.a1 * exp(-((b_s - f_s.b1) / f_s.c1).^2), 'b--')
plot(b_s * 0.006, f_s.a2 * exp(-((b_s - f_s.b2) / f_s.c2).^2), 'b--')
plot(b_s * 0.006, f_s.a1 * exp(-((b_s - f_s.b1) / f_s.c1).^2) + f_s.a2 * exp(-((b_s - f_s.b2) / f_s.c2).^2), 'r')
hold off
axis square
xlim([0 0.4])
print(sprintf('/tmp/disp_distrib_s_%s.svg', strrep(dats.data{1}, '/', '_')), '-dsvg')

figure
hold on
bar([f_nos.a1 / (f_nos.a1 + f_nos.a2) f_s.a1 / (f_s.a1 + f_s.a2)] * 100)
plot([1 1], [ci_nos(:,1) / (f_nos.a1 + f_nos.a2)] * 100, 'k')
plot([2 2], [ci_s(:,1) / (f_s.a1 + f_s.a2)] * 100, 'k')
hold off
axis square
ylabel('Bound fraction (%)')
ylim([40 60])
print(sprintf('/tmp/bound_perc_s_nos_%s.svg', strrep(dats.data{1}, '/', '_')), '-dsvg')