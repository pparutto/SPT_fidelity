addpath('../datasets/')
addpath('../')
addpath('../external/')

%approx to the higher 0.2
rayl999_len = [0.2 0.2 0.4 0.4 0.6 0.8 1.4 2.2 2.8 3.4 4.0 4.6 5.4];

trackm_ps = generate_track_params('tracks', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});
trackm_fbm_ps = generate_track_params('tracks', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});
trackm_nn_ps = generate_track_params('tracks_nn', [1 5 3 4], {'dist'});
trackm_fn_ps = generate_track_params('tracks_fn', [1 5 3 4], {'dist'});
utrack_ps = generate_track_params('tracks_utrack', [1 2 3 4], {'dist'});

Nreps = 5;
dats = freespace_track('../analysis_simu/analysis/simu/freespace3/', 1:Nreps, trackm_ps); %trackmate
%dats = freespace_track('../simu/freespace/density3/sim', 1:Nreps, trackm_nn_ps); %nearest neighb
%dats = freespace_track('../simu/freespace/density3/sim', 1:Nreps, trackm_fn_ps); %furthest neighb
%dats = freespace_track('../simu/freespace/density3/sim', 1:Nreps, utrack_ps); %utrack

%Nreps = 3;
%dats = freespace_fbm_track('../simu/freespace_fbm2/density', 1:Nreps, trackm_fbm_ps, 0.25);
%dats = freespace_fbm_track('../simu/freespace_fbm2/density', 1:Nreps, trackm_fbm_ps, 0.75);
%dats = freespace_mixed_track('../simu/freespace_mixed', 1:Nreps);

denss = [];
for k=1:length(dats{1}.cat_names)
    elts = strsplit(dats{1}.cat_names{k}, '_');
    denss = [denss str2num(elts{1})];
end

DTs = cellfun(@(x) x.spots_handler.dt, dats);
dist_ths = [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0 4.2 4.4 4.6 4.8 5.0 5.2 5.4 5.6 5.8 6.0];
rayl999_idx = arrayfun(@(i) find(i == dist_ths), rayl999_len);


Nframes = [60000 12000 6000 4000 3000 2400 2000 1715 1500 1334 1200];
exp_disp = sqrt(1 * DTs);
pxsize = 0.024195525;
area = (420 * pxsize)^2;
Nspts = [1 5 10 15 20 25 30 35 40 45 50];
spts_dens = round(Nspts / area * 100, 1);


errs = zeros(length(DTs), length(dist_ths), length(denss), Nreps);
best_ndisps = zeros(length(exp_disp), length(denss), Nreps);
best_disp_errs = zeros(length(exp_disp), length(denss), Nreps) * nan;
best_disp_dists = zeros(length(exp_disp), length(denss), Nreps);
best_disp_idxs = zeros(length(exp_disp), length(denss), Nreps);
best_disp_ambigs = zeros(length(exp_disp), length(denss), Nreps);
best_disp_run = zeros(length(exp_disp), length(denss), Nreps);
ambigs = zeros(length(exp_disp), length(dist_ths), length(denss), Nreps);
truth_run_lens = zeros(length(exp_disp), length(denss), Nreps);
match_run = zeros(length(exp_disp), length(dist_ths), length(denss), Nreps);
best_errs_bwd_noa = zeros(length(exp_disp), length(denss), Nreps);
best_runlen_noa = zeros(length(exp_disp), length(denss), Nreps);
best_errs_bwd = zeros(length(exp_disp), length(denss), Nreps);
best_cnt_disps_noa = zeros(length(exp_disp), length(denss), Nreps);
best_cnt_disps = zeros(length(exp_disp), length(denss), Nreps);
best_errs_inside = zeros(length(exp_disp), length(denss), Nreps);
best_errs_end = zeros(length(exp_disp), length(denss), Nreps);
best_avg_tr_len_GT = zeros(length(exp_disp), length(denss), Nreps);
best_avg_tr_len = zeros(length(exp_disp), length(denss), Nreps);
best_avg_tr_len_noa = zeros(length(exp_disp), length(denss), Nreps);
for k=1:length(exp_disp)
    for n=1:Nreps
        for l=1:length(denss)
            if ~isfile(sprintf('%s/%s/mapping_groundtruth_v2.mat', dats{k}.proc_dir, dats{k}.data{l + (n-1)*length(dats{k}.cat_names)}))
                display(sprintf('NOT FOUND: %s', dats{k}.data{l + (n-1)*length(dats{k}.cat_names)}))
                continue
            end
            ana = load(sprintf('%s/%s/mapping_groundtruth_v2.mat', dats{k}.proc_dir, dats{k}.data{l + (n-1)*length(dats{k}.cat_names)}));
            ana = ana.ana;

            v3 = 0;
            if  isfile(sprintf('%s/%s/errors_rm_ambig_v3.mat', dats{k}.proc_dir, dats{k}.data{l + (n-1)*length(dats{k}.cat_names)}))
                v3 = 1;
                ana_a = load(sprintf('%s/%s/errors_rm_ambig_v3.mat', dats{k}.proc_dir, dats{k}.data{l + (n-1)*length(dats{k}.cat_names)}));
            else
                ana_a = load(sprintf('%s/%s/errors_rm_ambig_v2.mat', dats{k}.proc_dir, dats{k}.data{l + (n-1)*length(dats{k}.cat_names)}));
            end
            ana_a = ana_a.ana;

            errs(k,:,l,n) = ana.err_disps_f';
            ambigs(k,:,l,n) = cellfun(@(x) sum(x > 0) / size(x,1), ana.all_ambig_n_tab);
            truth_run_lens(k,l,n) = ana.truth_avg_tlens;
            match_run(k,:,l,n) = cellfun(@(x) mean(x(:,2)), ana.all_run_len)';

            best_disp_idxs(k,l,n) = ana.best_err_disps_f_idx;
            best_ndisps(k,l,n) = ana.err_disps_cnt_disps(ana.best_err_disps_f_idx) / Nframes(l);
            best_disp_errs(k,l,n) = ana.err_disps_f(best_disp_idxs(k,l,n));
            best_disp_dists(k,l,n) = dist_ths(best_disp_idxs(k,l,n));
            best_disp_ambigs(k,l,n) = ambigs(k, best_disp_idxs(k,l,n), l, n);
            best_disp_run(k,l,n) = match_run(k, best_disp_idxs(k,l,n),l,n);

            best_errs_bwd_noa(k,l,n) = ana_a.all_nerrs_noa(ana.best_err_disps_f_idx);
            best_cnt_disps_noa(k,l,n) = ana_a.all_ndisps_noa(ana.best_err_disps_f_idx);
            best_errs_bwd(k,l,n) = ana_a.all_nerrs(ana.best_err_disps_f_idx);
            best_cnt_disps(k,l,n) = ana_a.all_ndisps(ana.best_err_disps_f_idx);

            errs_end = cellfun(@(x) size(x, 1), ana.all_disps_errs_ext);
            errs_inside = cellfun(@(x) size(x, 1), ana.all_disps_errs_inside);
            best_errs_inside(k,l,n) = errs_inside(ana.best_err_disps_f_idx);
            best_errs_end(k,l,n) = errs_end(ana.best_err_disps_f_idx);

            best_avg_tr_len_GT(k,l,n) =  ana.truth_avg_tlens;
            if v3
                best_avg_tr_len(k,l,n) = ana_a.all_avg_trlens_track(ana.best_err_disps_f_idx);
                best_avg_tr_len_noa(k,l,n) = ana_a.all_avg_trlens_track_noa(ana.best_err_disps_f_idx);
            end
        end
    end
end

pause(1)
figure
h = heatmap(flipud(mean(best_disp_dists,3)));
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 6];
%h.ColorLimits = [0.4 1];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG Best dist disp')
print(sprintf('/tmp/avg_distth_best_dist_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('best_disp_dists'))
display(sprintf('%s', Utils.show_3D_matrix(best_disp_dists, 3)))

pause(1)
figure
h = heatmap(flipud(mean(1 - best_disp_errs, 3)) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'Oranges');
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
h.ColorLimits = [10 100];
%h.ColorLimits = [90 100];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG Correct displacement disp')
print(sprintf('/tmp/avg_disp_errs_best_disp_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('best_disp_errs'))
display(sprintf('%s', Utils.show_3D_matrix((1 - best_disp_errs)*100, 1)))


best_bwd_err_f = (best_cnt_disps - best_errs_bwd) ./ best_cnt_disps;
best_bwd_err_f_noa = (best_cnt_disps_noa - best_errs_bwd_noa) ./ best_cnt_disps_noa;

rat = (best_bwd_err_f_noa - best_bwd_err_f) ./ best_bwd_err_f;
rat(best_cnt_disps_noa == best_cnt_disps) = nan;

pause(1)
figure
h = heatmap(flipud(mean(rat, 3)) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'Reds');
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
title('AVG Correct disps enrichment after ambig removal')
h.ColorLimits = [0 65];
pause(1)
print(sprintf('/tmp/avg_disp_errs_perc_rat_noa_a_best_disp_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('correct disps after removal'))
display(sprintf('%s', Utils.show_3D_matrix(rat, 3)))

pause(1)
figure
h = heatmap(flipud(mean(best_cnt_disps_noa ./ best_cnt_disps, 3)) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'Reds');
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 100];
title('AVG Remaining displacements after ambig removal (%)')
pause(1)
print(sprintf('/tmp/avg_disp_cnt_perc_rat_noa_a_best_disp_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('remaining disps after removal'))
display(sprintf('%s', Utils.show_3D_matrix((best_cnt_disps_noa ./ best_cnt_disps) * 100, 2)))


pause(1)
figure
h = heatmap(flipud(mean(best_disp_ambigs, 3) * 100));
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'YlGnBu');
h.Colormap = h.Colormap(end:-1:1,:);
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 100];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG best Ambiguity disp')
print(sprintf('/tmp/avg_ambig_best_disp_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('Ambgiguous displacements'))
display(sprintf('%s', Utils.show_3D_matrix(best_disp_ambigs * 100, 2)))

col =  parula(15);
ok_disps_avg = mean(best_ndisps .* (1 - best_disp_errs) / area, 3);
ok_disps_std = std(best_ndisps .* (1 - best_disp_errs) / area, 1, 3);
pause(1)
figure
pause(1)
hold on
for k=1:length(exp_disp)
    shadedErrorBar(denss / area, ok_disps_avg(k,:), ok_disps_std(k,:) / sqrt(Nreps), 'lineProps', {'Color', col(k,:)})
end
plot(denss / area, denss / area, 'k--', 'LineWidth', 2)
hold off
axis square
xlabel('Spots Density (spots/um2)')
ylabel('Recovered disps. Density (disps/um2)')
title('ok disps err')
pause(1)
print(sprintf('/tmp/avg_ok_disps_response_err_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('OK disps err'))
display(sprintf('%s', Utils.show_3D_matrix(best_ndisps .* (1 - best_disp_errs) / area, 2)))


ok_disp_ambigs_nos_avg = mean(best_ndisps .* (1 - best_disp_ambigs) / area, 3);
ok_disp_ambigs_nos_std = std(best_ndisps .* (1 - best_disp_ambigs) / area, 1, 3);
pause(1)
figure
pause(1)
hold on
for k=1:length(exp_disp)
    shadedErrorBar(denss / area, ok_disp_ambigs_nos_avg(k,:), ok_disp_ambigs_nos_std(k,:) / sqrt(5), 'lineProps', {'Color', col(k,:)})
end
plot(denss / area, denss / area, 'k--', 'LineWidth', 2)
hold off
axis square
title('ok disps ambig')
xlabel('Spots Density (spots/um2)')
ylabel('Recovered disps. Density (disps/um2)')
pause(1)
print(sprintf('/tmp/avg_ok_disps_response_ambig_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display(sprintf('ambig disps err'))
display(sprintf('%s', Utils.show_3D_matrix(best_ndisps .* (1 - best_disp_ambigs) / area, 2)))


fits_ok_disps_err = [];
for k=1:length(exp_disp)
    [f, gof] = fit(denss(1:4)' / area, ok_disps_avg(k,1:4)', 'poly1');
    fits_ok_disps_err = [fits_ok_disps_err; f.p1 gof.adjrsquare];
end
fits_ok_disps_ambig = [];
for k=1:length(exp_disp)
    [f, gof] = fit(denss(1:4)' / area, ok_disp_ambigs_nos_avg(k,1:4)', 'poly1');
    fits_ok_disps_ambig = [fits_ok_disps_ambig; f.p1 gof.adjrsquare];
end

pause(1)
figure
pause(1)
hold on
plot(exp_disp, fits_ok_disps_err(:,1), 'k')
plot(exp_disp, fits_ok_disps_ambig(:,1), 'r')
hold off
axis square
xlabel('Characteristic length (um)')
ylabel('Fit coeff (correct disps. dens / spot dens)')
legend({'Err', 'Ambig de'})
pause(1)
print(sprintf('/tmp/avg_ok_disps_response_fit_coeff_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)


[XS, YS] = meshgrid(exp_disp, dist_ths);

dens_idxs = [1 4 7 10];
avg_rayl999_correct = zeros(length(dens_idxs), length(exp_disp)) * nan;
std_rayl999_correct = zeros(length(dens_idxs), length(exp_disp)) * nan;
max_correct = zeros(length(dens_idxs), length(exp_disp), Nreps) * nan;
avg_max_correct = zeros(length(dens_idxs), length(exp_disp)) * nan;
std_max_correct = zeros(length(dens_idxs), length(exp_disp)) * nan;
max_best_dist = zeros(length(dens_idxs), length(exp_disp), Nreps) * nan;
avg_best_dist = zeros(length(dens_idxs), length(exp_disp)) * nan;
std_best_dist = zeros(length(dens_idxs), length(exp_disp)) * nan;
max_best_ambig = zeros(length(dens_idxs), length(exp_disp), Nreps) * nan;
avg_best_ambig = zeros(length(dens_idxs), length(exp_disp)) * nan;
std_best_ambig = zeros(length(dens_idxs), length(exp_disp)) * nan;
for l=1:length(dens_idxs)
    dens_idx = dens_idxs(l);
    avg_cur_correct = mean(1 - errs(:,:,dens_idx, :), 4);
    std_cur_correct = std(1 - errs(:,:,dens_idx, :), 1, 4);
    avg_cur_ambig = mean(ambigs(:,:,dens_idx, :), 4);
    std_cur_ambig = std(ambigs(:,:,dens_idx, :), 1, 4);
    avg_cur_run = mean(squeeze(match_run(:,:,dens_idx, :)) ./ repmat(truth_run_lens(:,dens_idx, :), 1, length(dist_ths)), 3);
    std_cur_run = std(squeeze(match_run(:,:,dens_idx, :)) ./ repmat(truth_run_lens(:,dens_idx, :), 1, length(dist_ths)), 1, 3);

    if dens_idx == 7
        pause(1)
        figure
        hold on
        avg_norm_cur_correct = avg_cur_correct ./ repmat(max(avg_cur_correct')', 1, length(dist_ths));
        std_norm_cur_correct = std_cur_correct ./ repmat(max(avg_cur_correct')', 1, length(dist_ths));
        surface(XS, YS, avg_norm_cur_correct' * 100)
        for k=1:size(avg_norm_cur_correct,1)
            kk = squeeze(best_disp_idxs(k, dens_idx, :));
            plot3(exp_disp(k), mean(dist_ths(kk)), mean(avg_norm_cur_correct(k,kk)) * 100, 'or', 'MarkerSize', 5, 'MarkerFaceColor','#ff0000')
        end
        hold off
        xlabel('Characteristic length (µm)')
        ylabel('Maximum linking distance (µm)')
        zlabel('Normalised correct disps')
        axis square
        view([-57.965479395353988,49.038003607937242])
        print(sprintf('/tmp/avg_disp_errs_norm_3D_%s_dens=%d_%dreps.svg', dats{1}.name, dens_idx, Nreps), '-dsvg')
        pause(1)

        cur_correct = 1 - errs(:,:,dens_idx, :);
        display(sprintf('err surface dens=%g', spts_dens(dens_idx)))
        for w=1:size(cur_correct, 4)
            display(sprintf('%s', Utils.show_3D_matrix(cur_correct ./ repmat(max(cur_correct(:,:,1,w)')', 1, length(dist_ths)) * 100, 2)))
        end
    end

    for k=1:size(avg_cur_correct,1)
        kk = squeeze(best_disp_idxs(k, dens_idx, :));
        avg_rayl999_correct(l,k) = mean(avg_cur_correct(k, rayl999_idx(k)));
        std_rayl999_correct(l,k) = std(avg_cur_correct(k, rayl999_idx(k)));
        max_correct(l,k,:) = avg_cur_correct(k, kk);
        avg_max_correct(l,k) = mean(avg_cur_correct(k, kk));
        std_max_correct(l,k) = std(avg_cur_correct(k, kk));
        max_best_dist(l,k,:) = dist_ths(kk);
        avg_best_dist(l,k) = mean(dist_ths(kk));
        std_best_dist(l,k) = std(dist_ths(kk));
        max_best_ambig(l,k,:) = avg_cur_ambig(k,kk);
        avg_best_ambig(l,k) = mean(avg_cur_ambig(k,kk));
        std_best_ambig(l,k) = std(avg_cur_ambig(k,kk));
    end
end


pause(1)
figure
hold on
for i=1:length(dens_idxs)
    errorbar(exp_disp, avg_max_correct(i,:) * 100, std_max_correct(i,:) * 100);
end
hold off
axis square
xlabel('Characteristic length (µm)')
ylabel('Correct displacements')
print(sprintf('/tmp/plot_best_err_dens_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display('max correct');
display(sprintf('%s', Utils.show_3D_matrix(max_correct * 100, 2)))


pause(1)
figure
hold on
for i=1:length(dens_idxs)
    errorbar(exp_disp, avg_best_dist(i,:), std_best_dist(i,:));
end
plot(exp_disp, rayl999_len, 'k--')
hold off
axis square
xlabel('Characteristic length (µm)')
ylabel('Linking distance (um)')
print(sprintf('/tmp/plot_best_dist_dens_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display('max best dist');
display(sprintf('%s', Utils.show_3D_matrix(max_best_dist, 2)))


pause(1)
figure
hold on
for i=1:size(dens_idxs,2)
    plot((1 - avg_max_correct(i,:)) * 100, avg_best_ambig(i,:) * 100)
end
hold off
axis square
xlim([0 100])
ylim([0 100])
xlabel('% erroneous displacements')
ylabel('% ambiguous displacements')
print(sprintf('/tmp/plot_error_disp_vs_ambig_%s_%dreps.svg', dats{1}.name, Nreps), '-dsvg')
pause(1)

display('ambig vs err - err');
display(sprintf('%s', Utils.show_3D_matrix((1 - max_correct) * 100, 1)))

display('ambig vs err - ambig');
display(sprintf('%s', Utils.show_3D_matrix(max_best_ambig * 100, 1)))

pause(1)
avg_best_errs_inside_ratio = mean(best_errs_inside ./ (best_errs_inside + best_errs_end), 3);
avg_best_errs_inside_ratio(isnan(avg_best_errs_inside_ratio)) = 0;
figure
h = heatmap(flipud(avg_best_errs_inside_ratio) * 100);
h.Colormap = brewermap(64, 'Purples');
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 75];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('AVG Err inside')
print(sprintf('/tmp/avg_inside_err_perc_n=%d.svg', Nreps), '-dsvg')
pause(1)

display('Error inside');
display(sprintf('%s', Utils.show_3D_matrix(best_errs_inside ./ (best_errs_inside + best_errs_end) * 100, 2)))


pause(1)
avg_best_trlen = mean(best_avg_tr_len ./ best_avg_tr_len_GT, 3);
figure
h = heatmap(flipud(avg_best_trlen) * 100);
h.Colormap = brewermap(64, 'PuRd');
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 200];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('Runlen')
pause(1)
print(sprintf('/tmp/avg_best_trlens_track_over_GT_n=%d.svg', Nreps), '-dsvg')
pause(1)

display('Traj Run lengths');
display(sprintf('%s', Utils.show_3D_matrix((best_avg_tr_len ./ best_avg_tr_len_GT) * 100, 2)))



pause(1)
avg_best_trlen_noa = mean(best_avg_tr_len_noa ./ best_avg_tr_len_GT, 3);
figure
h = heatmap(flipud(avg_best_trlen_noa) * 100);
h.Colormap = brewermap(64, 'PuRd');
h.YData = h.YData(end:-1:1);
h.ColorLimits = [0 200];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('Runlen noa')
pause(1)
print(sprintf('/tmp/avg_best_trlens_tracknoa_over_GT_n=%d.svg', Nreps), '-dsvg')
pause(1)

display('Traj Run lengths no ambig');
display(sprintf('%s', Utils.show_3D_matrix((best_avg_tr_len_noa ./ best_avg_tr_len_GT) * 100, 2)))