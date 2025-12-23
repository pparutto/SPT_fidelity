addpath('..')
addpath('../datasets')
addpath('../external/plot2svg')

datss = {yutong_nb_418_716_2(); yutong_nb_418_716_717_APP(); yutong_nb_418_716_717_nb()};
struct_ambig_fname = 'ambig_struct_mask=1_rad=0.7_th=0.35_maxdist=1.1.csv';

ps = struct();
ps.mask = 1;
ps.dist = 1;
ps.framegap = 0;
min_tr_len = 5;

smooth_factor = 5;
bins = 0.005:0.01:0.4;

show_exps = [1 5; 2 4; 3 5];

outdir = '/tmp/nanobody_alfatag';
if ~isfolder(outdir)
    mkdir(outdir)
end

avg_spts = [];
std_spts = [];

ambigs = cell(3, 1);
avg_tr_disps = cell(3, 1);
exp_cats = cell(3, 1);
cnt = 1;
cats = [];
nb_tabs = {};
for k=1:length(datss)
    dats = datss{k};
    ps_str = dats.track_handler.track_params(ps, dats.params);
    for n=1:length(dats.data)
        ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{n}));
        params = ana.params;
        ana = ana.ana;

        i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
        i2 = find(params.min_tr_lens == min_tr_len);

        tab = ana.tabs{i1}{i2};

        avg_spts = [avg_spts; mean(arrayfun(@(i) sum(tab(:,2) == i), unique(tab(:,2))))];
        std_spts = [std_spts; std(arrayfun(@(i) sum(tab(:,2) == i), unique(tab(:,2))))];

        spts = dats.spots_handler.load_spots(sprintf('%s/%s/%s', dats.base_dir, dats.data{n}, dats.spots_handler.fname));
        ambig_g_dat = csvread(sprintf('%s/%s/%s', dats.base_dir, dats.data{n}, struct_ambig_fname));
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

        tr_disps = [];
        for i=unique(tab_cut_dg(:,1))'
            tr = tab_cut_dg(tab_cut_dg(:,1) == i, :);
            disps = Utils.displacements(tr);
            if length(disps) >= min_tr_len
                tr_disps = [tr_disps sum(disps) / length(disps)];
            end
        end

        if strcmp(dats.name, 'yutong_nb_418_716_717_nb')
            nb_tabs = [nb_tabs; tab_cut_dg];
        end

        figure
        Utils.show_trajectories(tab_cut_dg, 'rand')
        daspect([1 1 1])

        if any(all([k n] == show_exps,2))
            pause(1)
            tr_idxs = unique(tab_cut_dg(:,1));
            cm = jet(64);
            Mdisp = 0.3;
            figure
            pause(1)
            hold on
            for i=1:length(tr_idxs)
                tr = tab(tab(:,1) == tr_idxs(i), :);
                cidx = floor(single(tr_disps(i) / Mdisp) * 63) + 1;
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
            plot2svg(sprintf('%s/trajs_avgspeed_%s_%s_minLen=%d.svg', outdir, ...
                dats.data{n}, params.track_strs{i1}, params.min_tr_lens(i2)))
            pause(1)
        end

        ambigs{k} = [ambigs{k}; sum(ambig_pos(:,2)) / ndisps];
        avg_tr_disps{k} = [avg_tr_disps{k} tr_disps];
        exp_cats{k} = [exp_cats{k}; cnt * ones(length(tr_disps), 1)];
        cnt = cnt + 1;
        cats = [cats k];
    end
end

[o,b] = hist(avg_tr_disps{1}, bins);
o_lum_smooth = smooth(o' / sum(o), smooth_factor);
[o,b] = hist(avg_tr_disps{2}, bins);
o_mem_smooth = smooth(o' / sum(o), smooth_factor);
[o,b] = hist(avg_tr_disps{3}, bins);
o_nb_smooth = smooth(o' / sum(o), smooth_factor);

writematrix(avg_tr_disps{1}', '/tmp/fig5d_lumen.csv');
writematrix(avg_tr_disps{2}', '/tmp/fig5d_mem.csv');
writematrix(avg_tr_disps{3}', '/tmp/fig5d_ib.csv');


[f_lum, gof_lum] = fit(b', o_lum_smooth, 'gauss1');
[f_mem, gof_mem] = fit(b', o_mem_smooth, 'gauss1');

pause(1)
figure
hold on
plot(bins, o_lum_smooth, 'r')
plot(bins, f_lum.a1 * exp(-((bins - f_lum.b1) / f_lum.c1).^2), 'k--', 'LineWidth', 1.2)
plot(bins, o_mem_smooth, 'b')
plot(bins, f_mem.a1 * exp(-((bins - f_mem.b1) / f_mem.c1).^2), 'k--', 'LineWidth', 1.2)
plot(bins, o_nb_smooth, 'm')
hold off
axis square
xlabel('AVG traj length (μm)')
ylabel('Frequency')
pause(1)
print(sprintf('%s/avgtr_disps_all_fit_hist_%s_minLen=%d.svg', outdir, params.track_strs{i1}, params.min_tr_lens(i2)), '-dsvg')
pause(1)



cols = [1 0 0; 0 0 1; 1 0 1];

all_ivels = [avg_tr_disps{1} avg_tr_disps{2} avg_tr_disps{3}];
all_cats = [exp_cats{1}' exp_cats{2}' exp_cats{3}'];

b_nbs = {};
o_nbs = {};
coeffs = [];
cints = {};
b_low = [];
b_high = [];
fits = {};
gofs = {};
nb_idxs = unique(exp_cats{3});
for k=1:length(nb_idxs)
    vel_nb = avg_tr_disps{3}(exp_cats{3} == nb_idxs(k));
    writematrix(vel_nb', sprintf('/tmp/fig5e_%d.csv', k));
    [o,b] = hist(vel_nb, bins);
    b = b(o > 0);
    o = o(o > 0);
    o_smooth = smooth(o' / sum(o), smooth_factor);
    [f_nb, gof_nb] = fit(b', o_smooth, 'Gauss2', 'Lower', [0 0 0 0 0.1 0], 'Upper', [inf 0.1 inf inf 0.3 inf]);
    if f_nb.b1 < f_nb.b2
        coeffs = [coeffs; [f_nb.a1 f_nb.a2] / (f_nb.a1 + f_nb.a2)];
        b_low = [b_low f_nb.b1];
        b_high = [b_high f_nb.b2];
    else
        coeffs = [coeffs; [f_nb.a2 f_nb.a1] / (f_nb.a1 + f_nb.a2)];
        b_low = [b_low f_nb.b2];
        b_high = [b_high f_nb.b1];
    end
    b_nbs{length(b_nbs)+1} = b;
    o_nbs{length(o_nbs)+1} = o_smooth;
    fits{length(fits)+1} = f_nb;
    gofs{length(gofs)+1} = gof_nb;
    cints{length(cints)+1} = confint(f_nb);

    vel_nb = avg_tr_disps{3}(exp_cats{3} == nb_idxs(k));
    pause(1)
    figure
    hold on
    plot(b, o_smooth, 'k')
    plot(b, fits{k}.a1 * exp(-((b - fits{k}.b1) / fits{k}.c1).^2) + fits{k}.a2 * exp(-((b - fits{k}.b2) / fits{k}.c2).^2), 'r--')
    hold off
    axis square
    ylim([0 0.15])
    title(sprintf('R2=%g', gofs{k}.adjrsquare))
    pause(1)
    print(sprintf('%s/avg_trdisp_nb_indiv_hist_fit_%s_minLen=%d_%s.svg', outdir, params.track_strs{i1}, params.min_tr_lens(i2), datss{3}.data{k}), '-dsvg')
    pause(1)


    tab = nb_tabs{k};
    tr_idxs = unique(tab(:,1));
    APP_tab = [];
    unb_tab = [];
    for i=1:length(tr_idxs)
        p_slow = normpdf(vel_nb(i), f_nb.b1, f_nb.c1) / sum(normpdf(bins, f_nb.b1, f_nb.c1));
        p_fast = normpdf(vel_nb(i), f_nb.b2, f_nb.c2) / sum(normpdf(bins, f_nb.b2, f_nb.c2));
        if p_slow > p_fast
            APP_tab = [APP_tab; tab(tab(:,1) == tr_idxs(i), :)];
        else
            unb_tab = [unb_tab; tab(tab(:,1) == tr_idxs(i), :)];
        end
    end

    pause(1)
    figure
    Utils.show_trajectories(tab, 'rand')
    daspect([1 1 1])
    pause(1)
    plot2svg(sprintf('/tmp/trajs_nb_all_%d.svg', k))

    pause(1)
    figure
    Utils.show_trajectories(APP_tab, 'rand')
    daspect([1 1 1])
    pause(1)
    plot2svg(sprintf('/tmp/trajs_nb_APP_%d.svg', k))

    pause(1)
    figure
    Utils.show_trajectories(unb_tab, 'rand')
    daspect([1 1 1])
    pause(1)
    plot2svg(sprintf('/tmp/trajs_nb_unbound_%d.svg', k))
end

pause(1)
figure
bar(coeffs, 'stacked')
axis square
ylabel('Coefficients [0 1]')
pause(1)
print(sprintf('%s/nb_proportions_bar_%s_minLen=%d.svg', outdir, params.track_strs{i1}, params.min_tr_lens(i2)), '-dsvg')
pause(1)

figure
hold on
plot(1:length(b_low), b_low, 'bx')
for k=1:length(cints)
    plot([k k], cints{k}(:,2), 'b')
end
plot([0 length(b_low)+1], f_mem.b1 * [1 1], 'b--')
plot(1:length(b_high), b_high, 'rx')
for k=1:length(cints)
    plot([k k], cints{k}(:,5), 'r')
end
plot([0 length(b_high)+1], f_lum.b1 * [1 1], 'r--')
hold off
axis square
ylabel('Categories average (μm)')
print(sprintf('%s/nb_fit_vels_%s_minLen=%d.svg', outdir, params.track_strs{i1}, params.min_tr_lens(i2)), '-dsvg')