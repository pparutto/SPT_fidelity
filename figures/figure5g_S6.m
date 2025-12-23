addpath('../')
addpath('../datasets/')
addpath('../external/plot2svg/')
addpath('../external/')

ec = @(x,y) sqrt(sum((x - y).^2, 2));

dats = roger_250226_struct();
dt = 0.01;

noa = 0;
ps.mask = dats.constr.mask;
ps.dist = 2;
ps.framegap = 0;
min_tr_len = 10;
ps_str = dats.track_handler.track_params(ps, dats.params);


noteres_dist_th = 1;
npts_in_eres_th = 10;

trajs_ERES_cnt = [];
trajs_notERES_cnt = [];
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

    imER = Utils.read_tiff_stack(sprintf('%s/C2-%s_preview_Simple_Segmentation_bin_open1pxcirc.tif_stabN=1.tif', dats.base_dir, fname));
    imER = (imER - min(imER(:))) / (max(imER(:)) - min(imER(:)));
    xpxs = 0:dats.pxsize:((size(imER,2)-1)*dats.pxsize);
    ypxs = 0:dats.pxsize:((size(imER,3)-1)*dats.pxsize);
    cm = gray();
    cm = cm(end:-1:1,:);

    avg_imER = flipud(squeeze(mean(imER, 1)));

    eres_tab = csvread(sprintf('%s/C3-%s/%s', dats.base_dir, fname, dats.eres_trck_fname), 1, 0);
    eres_tab = eres_tab(:, [1 5 3 4 6]);
    eres_tab = Utils.filter_trajectories_npts(eres_tab, 100);

    eres_pos = [];
    for i=unique(eres_tab(:,1))'
        eres_tr = eres_tab(eres_tab(:,1) == i, :);
        eres_pos = [eres_pos; mean(eres_tr(:,3:4), 1)];
    end

    % noteres_pos = zeros(0, 2);
    % for i=1:length(unique(eres_tab(:,1)))
    %     display(sprintf('%d', i));
    %     done = 0;
    %     while ~done
    %         pos = rand(1, 2) * (max([xpxs(end) ypxs(end)]) - 0.5) + 0.5;
    %         if any(ec(pos, eres_pos) < noteres_dist_th)
    %             continue;
    %         end
    %         if any(ec(pos, noteres_pos) < noteres_dist_th)
    %             continue
    %         end
    %         px = floor(pos / dats.pxsize) + 1;
    %         if avg_imER(px(2), px(1)) < 0.7
    %             continue;
    %         end
    %         noteres_pos = [noteres_pos; pos];
    %         done = 1;
    %     end
    % end
    tmp = load(sprintf('%s/noteres.mat', dats.base_dir));
    noteres_pos = tmp.noteres_pos;


    figure
    hold on
    plot(noteres_pos(:,1), noteres_pos(:,2), '.r', 'MarkerSize', 5)
    hold off
    axis([0 31.8 0 31.8])
    daspect([1 1 1])
    plot2svg('/tmp/noteres.svg')

    ana = load(ana_file);
    params = ana.params;
    ana = ana.ana;

    i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
    i2 = find(params.min_tr_lens == min_tr_len);

    tab = ana.tabs{i1}{i2};

    map_ERES = zeros(size(tab, 1), 2) -1;
    for i=1:size(tab,1)
        idxs = find(tab(i,5) == eres_tab(:,5) & sqrt(sum((tab(i,3:4) - eres_tab(:,3:4)).^2, 2)) < 0.15);
        if ~isempty(idxs)
            [v, idx] = min(sqrt(sum((tab(i,3:4) - eres_tab(idxs,3:4)).^2, 2)));
            map_ERES(i,:) = [idxs(idx), eres_tab(idxs(idx), 1)];
        end
    end

    map_notERES = zeros(size(tab, 1), 1) -1;
    for i=1:size(tab,1)
        idxs = find(sqrt(sum((tab(i,3:4) - noteres_pos).^2, 2)) < 0.15);
        if ~isempty(idxs)
            [v, idx] = min(sqrt(sum((tab(i,3:4) - noteres_pos(idxs)).^2, 2)));
            map_notERES(i,:) = idxs(idx);
        end
    end

    tidxs = unique(tab(:,1));
    for i=tidxs'
        trajs_ERES_cnt = [trajs_ERES_cnt; sum(map_ERES(find(tab(:,1) == i)) > -1)];
        trajs_notERES_cnt = [trajs_notERES_cnt; sum(map_notERES(find(tab(:,1) == i)) > -1)];
    end

    display(sprintf('Trajs in not ERES: %d', sum(trajs_notERES_cnt >= 2)))
end

figure
bar([mean(trajs_notERES_cnt(trajs_notERES_cnt >= 5)) mean(trajs_ERES_cnt(trajs_ERES_cnt >= 5))] * dt)
ylabel('AVG residence time')
axis square
print('/tmp/residenceTime_ERES_notERES.svg', '-dsvg')

figure
bar([1124 775])
ylabel('Num. trajs. in not ERES')
axis square
print('/tmp/trajs_notERES_fidlYesNo.svg', '-dsvg')
