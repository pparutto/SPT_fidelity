addpath('../')
addpath('../datasets/')
addpath('../external/plot2svg/')
addpath('../external/')

%dats = roger_250226();
dats = roger_250226_struct();


noa = 0;
ps.mask = dats.constr.mask;
ps.dist = 2;
ps.framegap = 0;
min_tr_len = 10;
ps_str = dats.track_handler.track_params(ps, dats.params);

npts_in_eres_th = 10;

all_eres_perc = zeros(length(dats.data), 1);
all_full_in = [];
all_in_out = [];
all_end_in = [];
all_durs = cell(length(unique(dats.cat_idxs)), 1);
all_ambig = zeros(length(dats.data), 1);
for n=1
    display(sprintf('[%d/%d] %s', n, length(dats.data), dats.data{n}));

    ana_file = sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{n});
    if ~isfile(ana_file)
        display(sprintf('   Skipping: mat file not found'))
        continue
    end
    cat_idx = dats.cat_idxs(n);

    dat_name = strrep(dats.data{n}, '/', '_');
    fname = dats.data{n}(4:end);

    imER = Utils.read_tiff_stack(sprintf('%s/%s/C2-%s_preview_Simple_Segmentation_bin_open1pxcirc.tif_stabN=1.tif', dats.data_dir, dats.data{n}, fname));
    imER = (imER - min(imER(:))) / (max(imER(:)) - min(imER(:)));
    xpxs = 0:dats.pxsize:((size(imER,2)-1)*dats.pxsize);
    ypxs = 0:dats.pxsize:((size(imER,3)-1)*dats.pxsize);
    cm = gray();
    cm = cm(end:-1:1,:);

    eres_tab = csvread(sprintf('%s/C3-%s/%s', dats.base_dir, fname, dats.eres_trck_fname), 1, 0);
    eres_tab = eres_tab(:, [1 5 3 4 6]);
    eres_tab = Utils.filter_trajectories_npts(eres_tab, 100);

    ana = load(ana_file);
    params = ana.params;
    ana = ana.ana;

    eres_pt_col = magma(max(eres_tab(:,5))+1);

    i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
    i2 = find(params.min_tr_lens == min_tr_len);

    tab = ana.tabs{i1}{i2};

    figure
    plot(unique(tab(:,2)), arrayfun(@(i) sum(tab(:,2) == i), unique(tab(:,2))))
    axis square
    xlabel('Time (s)')
    ylabel('Number of spots')
    print(sprintf('/tmp/spots_per_frame_%s.svg', dats.data{n}), '-dsvg')

    disps = Utils.displacements(tab);
    tab_noa = ana.tabs_noa{i1}{i2};
    adisps = ana.ambigs{i1}{i2};


    tmp = [];
    for u=1:size(tab,1)
        if adisps(u) > 0
            tmp = [tmp; tab(u,1) u - min(find(tab(:,1) == tab(u,1)))];
        end
    end

    tab2_noa2 = Utils.cut_ambiguities(tab, tmp);
    tab2_noa2 = Utils.filter_trajectories_npts(tab2_noa2, min_tr_len);
    tab_noa = tab2_noa2;
    display(sprintf('Ambigs = %.3f', sum(adisps > 0) / length(adisps) * 100))

    if noa
        tab = tab_noa;
    end

    map_ERES = zeros(size(tab, 1), 2) -1;
    for i=1:size(tab,1)
        idxs = find(tab(i,5) == eres_tab(:,5) & sqrt(sum((tab(i,3:4) - eres_tab(:,3:4)).^2, 2)) < 0.15);
        if ~isempty(idxs)
            [v, idx] = min(sqrt(sum((tab(i,3:4) - eres_tab(idxs,3:4)).^2, 2)));
            map_ERES(i,:) = [idxs(idx), eres_tab(idxs(idx), 1)];
        end
    end

    tidxs = unique(tab(:,1));
    trajs_ERES_cnt = [];
    trajs_in = [];
    for i=unique(tab(:,1))'
        trajs_ERES_cnt = [trajs_ERES_cnt; sum(map_ERES(find(tab(:,1) == i)) > -1)];
        if trajs_ERES_cnt(end) > npts_in_eres_th
            trajs_in = [trajs_in; i];
        end
    end

    figure
    pause(1)
    subplot(1,2,1)
    bar([0 1], [sum(trajs_ERES_cnt == 0) sum(trajs_ERES_cnt > 0)])
    xlabel('Trajs in ERES')
    ylabel('Num trajs')
    set(gca, 'XTickLabel', {'No', 'Yes'})
    all_eres_perc(n) = sum(trajs_ERES_cnt > 0) / length(trajs_ERES_cnt) * 100;
    title(sprintf('%.1f %%', all_eres_perc(n)))
    axis square
    subplot(1,2,2)
    bar(1:max(trajs_ERES_cnt), arrayfun(@(i) sum(trajs_ERES_cnt == i), 1:max(trajs_ERES_cnt)))
    xlabel('Number of frames spent in ERES')
    ylabel('Num trajs')
    axis square
    pause(1)
    print(sprintf('/tmp/%s_%s_stats_trajs_dur_in_ERES_ambig=%d_distTh=%g_minLen=%d.svg', dats.name, dat_name, 1-noa, ps.dist, min_tr_len), '-dsvg')
    pause(1)
    display(sprintf('Trajs in ERES: %d', sum(trajs_ERES_cnt >= 2)))

    eidxs = unique(eres_tab(:,1));
    tab_in_per_eres = cell(length(eidxs), 1);
    eres_tr_map = cell(length(eidxs), 1);
    for i=1:length(eidxs)
        eres_tr_map{i} = zeros(0, 2);
    end
    for i=unique(tab(:,1))'
        tr_map = map_ERES(find(tab(:,1) == i), :);
        for j=unique(tr_map(:,2))'
            if j == -1
                continue
            end
            if sum(tr_map(:,2) == j) > 0
                tab_in_per_eres{find(eidxs==j)} = [tab_in_per_eres{find(eidxs==j)}; sum(tr_map(:,2) == j)];
                eres_tr_map{find(eidxs==j)} = [eres_tr_map{find(eidxs==j)}; i * ones(sum(tr_map(:,2) == j), 1) find(tr_map(:,2) == j)];
            end
        end
    end
    tab_in_per_eres_cnt = cellfun(@(x) length(x), tab_in_per_eres);

    figure
    bar(0:max(tab_in_per_eres_cnt), arrayfun(@(i) sum(tab_in_per_eres_cnt == i), 0:max(tab_in_per_eres_cnt)))

    rat = [];
    for i=1:length(tab_in_per_eres)
        t = tab_in_per_eres{i};
        if length(t) >= 7
            rat = [rat; sum(t >= 3) / sum(t < 3)];
        else
            rat = [rat; nan];
        end

    end

    figure
    [o, b] = hist(rat, 20);
    bar(b, o / sum(o), 'hist')
    axis square
    xlabel('Ratio')
    ylabel('Frequency')
    print(sprintf('/tmp/%s_%s_ERES_passing_staying_ratio_hist_distTh=%g_minLen=%d.svg', dats.name, dat_name, ps.dist, min_tr_len), '-dsvg')

    cm = plasma(10);
    cm = [0 0 0; cm; 0.75 0.75 0.75];
    Mrat = max(rat(~isinf(rat)));
    figure
    hold on
    for i=1:length(eidxs)
        tr = eres_tab(eres_tab(:,1) == eidxs(i), :);
        if isnan(rat(i))
            col = cm(1,:);
        elseif isinf(rat(i))
            col = cm(end,:);
        else
            col = cm(ceil((rat(i) ./ Mrat) * (size(cm,1)-1))+1,:);
        end
        plot(mean(tr(:,3)), mean(tr(:,4)), '.', 'Color', col, 'Markersize', 20)
    end
    hold off
    daspect([1 1 1])
    axis([0 31.8 0 31.8])
    print(sprintf('/tmp/%s_%s_ERES_passing_staying_ratio_map_distTh=%g_minLen=%d.svg', dats.name, dat_name, ps.dist, min_tr_len), '-dsvg')

    for i=1:length(eidxs)
        if length(unique(eres_tr_map{i}(:,1))) < 10
            continue
        end
        if rat(i) < 1.2
            continue
        end

        pause(1)
        figure
        hold on
        for j=unique(eres_tr_map{i}(:,1))'
            tr = tab(tab(:,1) == j, :);
            plot(tr(:,3), tr(:,4))
        end
        et = eres_tab(eres_tab(:,1) == eidxs(i), :);
        plot(mean(et(:,3)), mean(et(:,4)), 'or', 'MarkerSize', 10)
        hold off
        axis([0 31.8 0 31.8])
        title(sprintf('rat=%g', rat(i)))
        daspect([1 1 1])
        pause(1)
        print(sprintf('/tmp/%s_%s_ERES_passing_staying_trajs_%d_distTh=%g_minLen=%d.svg', dats.name, dat_name, eidxs(i), ps.dist, min_tr_len), '-dsvg')
        pause(1)
    end

    res_time_per_eres = [];
    for i=1:length(eidxs)
        tmp = [];
        for j=unique(eres_tr_map{i}(:,1))'
            s = sum(eres_tr_map{i}(:,1) == j);
            if s >= 5
                tmp = [tmp; s];
            end
        end
        if length(tmp) >= 5
            res_time_per_eres = [res_time_per_eres; mean(tmp)];
        end
    end

    trajs_in_cols = zeros(length(trajs_in), 3);
    for u=1:size(trajs_in_cols,1)
        trajs_in_cols(u,:) = rand(1,3);
    end

    % sel_trajs = [19768 19424 48693 48304 46670];
    % sel_trajs = unique(trajs_in)';
    % for i=sel_trajs
    %     pause(1)
    %     figure
    %     pause(1)
    %     hold on
    %     tr = tab(tab(:,1) == i, :);
    %     colormap(cm)
    %     imagesc(squeeze(mean(imER(tr(1,5):tr(end,5),:,:),1)), 'XData', xpxs, 'YData', ypxs);
    %     idxs = find(tab(:,1) == i);
    %     for v=unique(map_ERES(idxs, 2))'
    %         trr = eres_tab(eres_tab(:,1) == v, :);
    %         trr = trr(find(trr(:,5) == min(tr(:,5))):find(trr(:,5) == max(tr(:,5))), :);
    %         scatter(trr(:,3), trr(:,4), 0.5, eres_pt_col(trr(:,5)+1,:), 'filled')
    %     end
    % 
    %     col = rand(1,3);
    %     tr_ambigs = adisps(idxs);
    %     todo = zeros(0, 2);
    %     for j=1:length(tr_ambigs)
    %         if tr_ambigs(j) > 0
    %             todo = [todo; tr([j j+1], 3) tr([j j+1], 4); nan nan];
    %         end
    %     end
    %     text(tr(1,3), tr(1,4), sprintf('%d', i), 'FontSize', 4)
    %     plot(tr(1,3), tr(1,4), '*', 'Color', col, 'MarkerSize', 0.5)
    %     plot(tr(:,3), tr(:,4), 'Color', col, 'LineWidth', 0.1)
    %     plot(todo(:,1), todo(:,2), 'r', 'LineWidth', 3)
    %     for j=1:length(idxs)
    %         if map_ERES(idxs(j), 1) > -1
    %             plot(tr(j,3), tr(j,4), '.g', 'MarkerSize', 0.5)
    %         end
    %     end
    %     hold off
    %     axis([min(tr(:,3)) max(tr(:,3)) min(tr(:,4)) max(tr(:,4))])
    %     daspect([1 1 1])
    %     pause(1)
    %     exportgraphics(gcf, sprintf('/tmp/%s_%s_traj_%d_ERES_ambig=%d_distTh=%g_minLen=%d.pdf', dats.name, dat_name, i, 1-noa, ps.dist, min_tr_len), 'ContentType', 'vector')
    %     %print(sprintf('/tmp/%s_%s_trajs_in_ERES_distTh=%g_minLen=%d.svg', dats.name, dat_name, ps.dist, min_tr_len), '-dsvg')
    %     %plot2svg(sprintf('/tmp/%s_%s_trajs_in_ERES_distTh=%g_minLen=%d.svg', dats.name, dat_name, ps.dist, min_tr_len))
    %     pause(1)
    % end

    %close all

    pause(1)
    figure
    pause(1)
    hold on
    colormap(cm)
    imagesc(squeeze(mean(imER,1)), 'XData', xpxs, 'YData', ypxs);
    for i=unique(trajs_in)'
        idxs = find(tab(:,1) == i);
        for v=unique(map_ERES(idxs, 2))'
            tr = eres_tab(eres_tab(:,1) == v, :);
            scatter(tr(:,3), tr(:,4), 0.5, eres_pt_col(tr(:,5)+1,:))
        end
    end
    for u=1:length(trajs_in)
        i = trajs_in(u);
        col = trajs_in_cols(u,:);
        tr = tab(tab(:,1) == i, :);
        idxs = find(tab(:,1) == i);
        text(tr(1,3), tr(1,4), sprintf('%d', i), 'FontSize', 4)
        plot(tr(1,3), tr(1,4), '*', 'Color', col, 'MarkerSize', 0.5)
        plot(tr(:,3), tr(:,4), 'Color', col, 'LineWidth', 0.1)
        for j=1:length(idxs)
            if map_ERES(idxs(j), 1) > -1
                plot(tr(j,3), tr(j,4), '.g', 'MarkerSize', 0.5)
            end
        end
    end
    hold off
    daspect([1 1 1])
    pause(1)
    exportgraphics(gcf, sprintf('/tmp/%s_%s_trajs_in_ERES_ambig=%d_distTh=%g_minLen=%d.pdf', dats.name, dat_name, 1-noa, ps.dist, min_tr_len), 'ContentType', 'vector')
    pause(1)

    pause(1)
    figure
    pause(1)
    hold on
    colormap(cm)
    imagesc(squeeze(mean(imER,1)), 'XData', xpxs, 'YData', ypxs);
    for i=unique(trajs_in)'
        idxs = find(tab(:,1) == i);
        for v=unique(map_ERES(idxs, 2))'
            tr = eres_tab(eres_tab(:,1) == v, :);
            plot(tr(:,3), tr(:,4), 'r', 'LineWidth', 0.1)
        end
    end
    for u=1:length(trajs_in)
        i = trajs_in(u);
        col = trajs_in_cols(u,:);
        tr = tab(tab(:,1) == i, :);
        idxs = find(tab(:,1) == i);
        for j=1:(size(tr,1)-1)
            if adisps(idxs(j)) > 0
                plot(tr([j j+1], 3), tr([j j+1], 4), 'm', 'LineWidth', 0.1)
            else
                plot(tr([j j+1], 3), tr([j j+1], 4), 'k', 'LineWidth', 0.1)
            end
        end
        for j=1:length(idxs)
            if map_ERES(idxs(j), 1) > -1
                plot(tr(j,3), tr(j,4), '.g', 'MarkerSize', 0.5)
            end
        end
    end
    hold off
    daspect([1 1 1])
    pause(1)
    plot2svg(sprintf('/tmp/%s_%s_ambig_trajs_in_ERES_ambig=%d_distTh=%g_minLen=%d.svg', dats.name, dat_name, 1-noa, ps.dist, min_tr_len))
    pause(1)

    % for i=trajs_in'
    %     tr = tab(tab(:,1) == i, :);
    %     idxs = find(tab(:,1) == i);
    %     figure
    %     hold on
    %     disps = Utils.displacements(tr);
    %     plot(1:length(disps), disps)
    %     plot(1:length(disps), smooth(disps, 11), 'k')
    %     for j=1:(length(idxs)-1)
    %         if map_ERES(idxs(j), 1) > -1
    %             plot(j, disps(j), 'or')
    %         end
    %     end
    %     hold off
    %     'a'
    % end

    pause(1)
    figure
    pause(1)
    hold on
    for u=1:length(trajs_in)
        i = trajs_in(u);
        col = trajs_in_cols(u,:);
        tr = tab(tab(:,1) == i, :);
        idxs = find(tab(:,1) == i);
        eres_idxs = map_ERES(idxs, 2);

        plot(tr(:,3), tr(:,4), 'Color', rand(1,3))
        for j=1:size(tr,1)
            if eres_idxs(j) > 0
                plot(tr(j,3), tr(j,4), 'ro')
            end
        end
    end
    hold off
    daspect([1 1 1])
    axis([0 31.8 0 31.8])
    pause(1)
    plot2svg(sprintf('/tmp/%s_%s_all_ERES_traj_ambig=%d_distTh=%g_minLen=%d.svg', dats.name, dat_name, 1-noa, ps.dist, min_tr_len))
    pause(1)



    % for u=1:length(trajs_in)
    %     i = trajs_in(u);
    %     col = trajs_in_cols(u,:);
    %     tr = tab(tab(:,1) == i, :);
    %     idxs = find(tab(:,1) == i);
    %     eres_idxs = map_ERES(idxs, 2);
    % 
    %     pause(1)
    %     figure
    %     pause(1)
    %     hold on
    %     % for eidx=unique(eres_idxs(eres_idxs > 0))'
    %     %     tr_eres = eres_tab(eres_tab(:,1) == eidx,:);
    %     %     plot(tr_eres(:,3), tr_eres(:,4), 'r')
    %     % end
    %     plot(tr(:,3), tr(:,4), 'Color', rand(1,3))
    %     for j=1:size(tr,1)
    %         if eres_idxs(j) > 0
    %             plot(tr(j,3), tr(j,4), 'ro')
    %         end
    %     end
    %     hold off
    %     daspect([1 1 1])
    %     axis([0 31.8 0 31.8])
    %     pause(1)
    %     plot2svg(sprintf('/tmp/%s_%s_ERES_traj_%d_ambig=%d_distTh=%g_minLen=%d.svg', dats.name, dat_name, i, 1-noa, ps.dist, min_tr_len))
    %     pause(1)
    % 
    % 
    %     pause(1)
    %     figure
    %     pause(1)
    %     subplot(2,1,1)
    %     title(sprintf('%d', i))
    %     hold on
    %     for eidx=unique(eres_idxs(eres_idxs > 0))'
    %         tr_eres = eres_tab(eres_tab(:,1) == eidx,:);
    %         cur_dists = zeros(size(tr,1), 1) * nan;
    %         for j=1:size(tr,1)
    %             pt = tr_eres(tr_eres(:, 5) == tr(j,5), 3:4);
    %             if isempty(pt)
    %                 continue
    %             end
    %             cur_dists(j) = sqrt(sum((tr(j,3:4) - pt).^2));
    %         end
    %         plot(1:length(cur_dists), cur_dists, 'Color', col)
    %     end
    %     plot([1 size(tr,1)], [0.15 0.15], 'r--')
    %     hold off
    %     ylabel('Distance to ERES (um)')
    %     xlim([0, size(tr,1)])
    %     subplot(2,1,2)
    %     disps = Utils.displacements(tr);
    %     hold on
    %     plot(1:(size(tr,1)-1), disps, 'k')
    %     plot(1:(size(tr,1)-1), smooth(disps, 5), 'b--', 'LineWidth', 2)
    %     hold off
    %     xlim([0, size(tr,1)])
    %     ylabel('Displacement length (um)')
    %     pause(1)
    %     plot2svg(sprintf('/tmp/%s_%s_ERES_traj_%d_caracs_ambig=%d_distTh=%g_minLen=%d.svg', dats.name, dat_name, i, 1-noa, ps.dist, min_tr_len))
    %     pause(1)
    % end

    %%%% PASSING TRAJS
    % trajs_todo = tidxs(find(trajs_ERES_cnt == 2));
    % for u=1:40%length(trajs_todo)
    %     i = trajs_todo(u);
    %     col = rand(1,3);%trajs_in_cols(u,:);
    %     tr = tab(tab(:,1) == i, :);
    %     idxs = find(tab(:,1) == i);
    %     eres_idxs = map_ERES(idxs, 2);
    % 
    %     pause(1)
    %     figure
    %     pause(1)
    %     hold on
    %     % for eidx=unique(eres_idxs(eres_idxs > 0))'oouMai
    %     %     tr_eres = eres_tab(eres_tab(:,1) == eidx,:);
    %     %     plot(tr_eres(:,3), tr_eres(:,4), 'r')
    %     % end
    %     plot(tr(:,3), tr(:,4), 'Color', rand(1,3))
    %     for j=1:size(tr,1)
    %         if eres_idxs(j) > 0
    %             plot(tr(j,3), tr(j,4), 'ro')
    %         end
    %     end
    %     hold off
    %     daspect([1 1 1])
    %     axis([0 31.8 0 31.8])
    %     pause(1)
    %     plot2svg(sprintf('/tmp/%s_%s_ERES_traj_%d_ambig=%d_distTh=%g_minLen=%d.svg', dats.name, dat_name, i, 1-noa, ps.dist, min_tr_len))
    %     pause(1)
    % 
    % 
    %     pause(1)
    %     figure
    %     pause(1)
    %     subplot(2,1,1)
    %     title(sprintf('%d', i))
    %     hold on
    %     for eidx=unique(eres_idxs(eres_idxs > 0))'
    %         tr_eres = eres_tab(eres_tab(:,1) == eidx,:);
    %         cur_dists = zeros(size(tr,1), 1) * nan;
    %         for j=1:size(tr,1)
    %             pt = tr_eres(tr_eres(:, 5) == tr(j,5), 3:4);
    %             if isempty(pt)
    %                 continue
    %             end
    %             cur_dists(j) = sqrt(sum((tr(j,3:4) - pt).^2));
    %         end
    %         plot(1:length(cur_dists), cur_dists, 'Color', col)
    %     end
    %     plot([1 size(tr,1)], [0.15 0.15], 'r--')
    %     hold off
    %     ylabel('Distance to ERES (um)')
    %     xlim([0, size(tr,1)])
    %     subplot(2,1,2)
    %     disps = Utils.displacements(tr);
    %     hold on
    %     plot(1:(size(tr,1)-1), disps, 'k')
    %     plot(1:(size(tr,1)-1), smooth(disps, 5), 'b--', 'LineWidth', 2)
    %     hold off
    %     xlim([0, size(tr,1)])
    %     ylabel('Displacement length (um)')
    %     pause(1)
    %     plot2svg(sprintf('/tmp/%s_%s_ERES_traj_%d_caracs_ambig=%d_distTh=%g_minLen=%d.svg', dats.name, dat_name, i, 1-noa, ps.dist, min_tr_len))
    %     pause(1)
    % end

    close all
end

writematrix(trajs_ERES_cnt, '/tmp/fig5h.csv');

dt = 0.01;
figure
hold on 
bar((5:50) * dt, arrayfun(@(i) sum(trajs_ERES_cnt == i), 5:50))
[f, gof] = fit((1:46)' * dt, arrayfun(@(i) sum(trajs_ERES_cnt == i), 5:50)', 'exp2', 'robust', 'LAR');
plot((5:50) * dt, f.a * exp(f.b * (1:46) * dt) + f.c * exp(f.d * (1:46) * dt), 'r')
hold off
xlabel('Time spent in ERES (s)')
ylabel('Frequency')
xlim([4 51] * dt)
ylim([0 80])
axis square
print(sprintf('/tmp/%s_frames_in_eres_ambig=%d_distTh=%g_minLen=%d', dats.name, 1-noa, ps.dist, min_tr_len), '-dsvg')

display(sprintf('fit: a=%.3f, tau1=%.3f ms, c=%.3f, tau2=%.3f ms, Rsq=%.3f', f.a, -1/f.b * 1000, f.c, -1/f.d * 1000, gof.adjrsquare));
