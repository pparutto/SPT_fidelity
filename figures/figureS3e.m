addpath('../datasets')
addpath('../external')
addpath('../')

Nreps = 5;

trackm_ps = generate_track_params('tracks', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});

dats_truth = freespace_GT('../analysis_simu/analysis/simu/freespace3/', 1:Nreps);
dats_track = freespace_track('../analysis_simu/analysis/simu/freespace3/', 1:Nreps, trackm_ps); %trackmate


if ~isempty(strfind(dats_track{1}.name, 'utrack'))
    match_dist_th = 0.5e-3;
else
    match_dist_th = 1e-5;
end

ec = @(x,y) sqrt(sum((x - y).^2, 2));

rev_order = 0;

idxs1 = 1:length(dats_truth);
if rev_order
    idxs1 = length(dats_truth):-1:1;
end


truth_ndisps = zeros(13, 11, Nreps);
track_ndisps = zeros(13, 11, Nreps);
track_noa_ndisps = zeros(13, 11, Nreps);
truth_diff = zeros(13, 11, Nreps);
track_diff = zeros(13, 11, Nreps);
track_noa_diff = zeros(13, 11, Nreps);
truth_ci = zeros(13, 11, Nreps, 2);
track_ci = zeros(13, 11, Nreps, 2);
track_noa_ci = zeros(13, 11, Nreps, 2);
for k1=idxs1
    display(sprintf('%s', dats_track{k1}.name))
    DT = dats_truth{k1}.spots_handler.dt;
    assert(dats_truth{k1}.spots_handler.dt == dats_track{k1}.spots_handler.dt);

    idxs2 = 1:length(dats_track{k1}.data);
    if rev_order
        idxs2 = length(dats_track{k1}.data):-1:1;
    end

    for k2=idxs2
        display(sprintf('%d %d: %s %s', k1, k2, dats_track{k1}.name, dats_track{k1}.data{k2}))
        cur_outdir = sprintf('%s/%s', dats_track{k1}.proc_dir, dats_track{k1}.data{k2});

        if ~isfile(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_track{k1}.proc_dir, dats_track{k1}.data{k2}))
            display(sprintf('NOT FOUND: %s', dats_track{k1}.data{k2}))
            continue
        end

        rep = floor((k2 - 1) / 11) + 1;
        kk2 = mod(k2 - 1, 11) + 1;
        display(sprintf('%d %d', kk2, rep));

        ana_m = load(sprintf('%s/%s/mapping_groundtruth_v2.mat', dats_track{k1}.proc_dir, dats_track{k1}.data{k2}));
        ana_m = ana_m.ana;

        ana_truth = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_truth{k1}.proc_dir, dats_truth{k1}.data{k2}));
        hash_truth = ana_truth.hash;
        ana_truth = ana_truth.ana;
        tab_truth = ana_truth.tabs{1}{1};
        tab_truth(:,2) = round(tab_truth(:,2) / DT);

        dsps_truth = Utils.displacements(tab_truth);
        truth_ndisps(k1,k2,rep) = length(dsps_truth);

        tmp = [];
        for u=1:1000
            idxs = randperm(length(dsps_truth));
            [f, fci] = raylfit(dsps_truth(idxs(1:1100)));
            tmp = [tmp; f^2 / DT / 2 (fci.^2 / DT / 2)'];
        end
        truth_diff(k1,kk2,rep) = mean(tmp(:,1));
        truth_ci(k1,kk2,rep,:) = mean(tmp(:,2:3),1);

        ana_track = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_track{k1}.proc_dir, dats_track{k1}.data{k2}));
        hash_track = ana_track.hash;
        params = ana_track.params;
        ana_track = ana_track.ana;

        i1 = ana_m.best_err_disps_f_idx;
        ps_vals = cellfun(@(x) str2num(x), strsplit(params.track_strs{i1}, '_'));
        tab = ana_track.tabs{i1}{1};
        tab(:,2) = round(tab(:,2) / DT);

        disps = Utils.displacements(tab);
        track_ndisps(k1,kk2,rep) = length(disps);

        tmp = [];
        for u=1:1000
            idxs = randperm(length(disps));
            [f, fci] = raylfit(disps(idxs(1:1100)));
            tmp = [tmp; f^2 / DT / 2 (fci.^2 / DT / 2)'];
        end
        track_diff(k1,kk2,rep) = mean(tmp(:,1));
        track_ci(k1,kk2,rep,:) = mean(tmp(:,2:3),1);

        tracks_to_truth = ones(size(tab,1), 1) * -1;
        for i=1:size(tab,1)
            nh_idxs = find(tab_truth(:,2) == tab(i,2));
            nh_pts = tab_truth(nh_idxs, :);
            idxs = find(ec(tab(i, 3:4), nh_pts(:,3:4)) < match_dist_th);
            if isempty(idxs)
                idxs = find(ec(tab(i, 3:4), nh_pts(:,3:4)) < 2*match_dist_th);
            end
            if length(idxs) == 1
                tracks_to_truth(i) = nh_idxs(idxs(1));
            elseif length(idxs) > 1
                assert(0)
            end
        end
        assert(all(tracks_to_truth ~= -1));

        disps_noa = [];
        for i=unique(tab(:,1))'
            tr_idxs = find(tab(:,1) == i);
            tr_to_truth = tracks_to_truth(tr_idxs);
            tr = tab(tr_idxs, :);
            tr_disps = Utils.displacements(tr);
            for j=1:length(tr_disps)
                idxs = [];
                for u=(tr(j,2)+1):tr(j+1,2)
                    idxs = [idxs; find(tab_truth(:,2) == u)];
                end

                if length(idxs) == 0
                    display(sprintf('displacement with no successor: %d, %d', i, j));
                    continue
                end
                cnt = sum(ec(tab_truth(idxs, 3:4), tr(j,3:4)) <= ps_vals(1)) - 1;
                if cnt == 0
                    disps_noa = [disps_noa; tr_disps(j)];
                end
            end
        end
        track_noa_ndisps(k1,kk2,rep) = length(disps_noa);

        tmp = [];
        for u=1:1000
            idxs = randperm(length(disps_noa));
            [f, fci] = raylfit(disps_noa(idxs(1:1100)));
            tmp = [tmp; f^2 / DT / 2 (fci.^2 / DT / 2)'];
        end
        track_noa_diff(k1,kk2,rep) = mean(tmp(:,1));
        track_noa_ci(k1,kk2,rep,:) = mean(tmp(:,2:3),1);

        %[f, gof] = fit(b', o' / sum(o), 'B * x / a^2 * exp(-x^2/(2*a^2))', 'Lower', [0 0], 'Upper', [inf M/2]);
    end
end

figure
h = heatmap(mean(truth_diff, 3));
h.CellLabelFormat = '%.2f';
colorbar
clim([0 1])

pause(1)
figure
pause(1)
h = heatmap(flipud(mean(track_diff,3)));
h.Colormap = brewermap(64, 'Greens');
h.CellLabelFormat = '%.2f';
h.YData = h.YData(end:-1:1);
h.Colormap = h.Colormap(end:-1:1,:);
colorbar
clim([0.2 1])
print(sprintf('/tmp/freespace_Dest_nreps=%d.svg', Nreps), '-dsvg')
pause(1)

display(sprintf('track_diff'))
display(sprintf('%s', Utils.show_3D_matrix(track_diff, 3)))


pause(1)
figure
pause(1)
h = heatmap(flipud(mean(track_noa_diff,3)));
h.Colormap = brewermap(64, 'Greens');
h.CellLabelFormat = '%.2f';
h.YData = h.YData(end:-1:1);
h.Colormap = h.Colormap(end:-1:1,:);
colorbar
clim([0.2 1])
print(sprintf('/tmp/freespace_Dest_noa_nreps=%d.svg', Nreps), '-dsvg')
pause(1)

display(sprintf('track_diff_noa'))
display(sprintf('%s', Utils.show_3D_matrix(track_noa_diff, 3)))