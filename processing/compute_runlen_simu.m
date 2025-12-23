addpath('../datasets/')
addpath('../external')
addpath('../')

Nreps = 1;

trackm_ps = generate_track_params('tracks', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});
trackm_fbm_ps = generate_track_params('tracks', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});
trackm_nn_ps = generate_track_params('tracks_nn', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});
trackm_fn_ps = generate_track_params('tracks_fn', [1 5 3 4], {'dist'});
utrack_ps = generate_track_params('tracks_utrack', [1 2 3 4], {'dist'});

dats_truth = freespace_GT('../simu_raw/simu/freespace/', 1:5);
dats_track = freespace_track('../simu_raw/simu/freespace/', 1:Nreps, trackm_ps); %trackmate
%dats_track = freespace_track('../simu_raw/simu/freespace/', 1:5, trackm_nn_ps); %nearest neighb
%dats_track = freespace_track('../simu_raw/simu/freespace/', 1:5, trackm_fn_ps); %furthest neighb
%dats_track = freespace_track('../simu_raw/simu/freespace/', 1:5, utrack_ps); %utrack


%dats_truth = ER_GT('../simu_raw/simu/ER', 1:Nreps);
%dats_track = ER_track('../simu_raw/simu/ER', 1:Nreps); %trackmate
%dats_track = ER_track_struct('../simu_raw/simu/ER', 1:Nreps);

%dats_truth = mito_GT('../simu_raw/simu/mito', 1:Nreps);
%dats_track = mito_track('../simu_raw/simu/mito', 1:Nreps); %trackmate
%dats_track = mito_track_struct('../simu_raw/simu/mito', 1:Nreps);

%dats_truth = freespace_fbm_GT('../simu_raw/simu/freespace_fbm2/density', 1:3, 0.25);
%dats_track = freespace_fbm_track('../simu_raw/simu/freespace_fbm2/density', 1:3, trackm_fbm_ps, 0.25);

%dats_truth = freespace_fbm_GT('../simu_raw/simu/freespace_fbm2/density', 1:3, 0.75);
%dats_track = freespace_fbm_track('../simu_raw/simu/freespace_fbm2/density', 1:3, trackm_fbm_ps, 0.75);

%dats_truth = lines_GT('../simu_raw/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly.poly', 1:Nreps);
%dats_track = lines_track('../simu_raw/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly.poly', 1:Nreps);
%dats_track = lines_track_struct('../simu_raw/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly.poly', 1:3);

%dats_truth = freespace_mixed_GT('../simu_raw/simu/freespace_mixed', 1:3);
%dats_track = freespace_mixed_track('../simu_raw/simu/freespace_mixed', 1:3);

rev_order = 0;

ec = @(x,y) sqrt(sum((x - y).^2, 2));

if ~isempty(strfind(dats_track{1}.name, 'utrack'))
    match_dist_th = 0.5e-3;
else
    match_dist_th = 1e-5;
end

cur_failed = 0;
failed = {};


idxs1 = 1:length(dats_truth);
if rev_order
    idxs1 = length(dats_truth):-1:1;
end

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
        out_fname = sprintf('%s/mapping_runlens.mat', cur_outdir);

        if isfile(out_fname)
          display(sprintf('Skipped[%d][%d/%d]: %s', k1, k2, length(dats_track{k1}.data), dats_track{k1}.data{k2}));
          continue
        end

        truth_mat_f = sprintf('%s/%s/pipeline_1_trajectories.mat', dats_truth{k1}.proc_dir, dats_truth{k1}.data{k2});
        if ~isfile(truth_mat_f)
            display(sprintf('FILE NOT FOUND: %s', truth_mat_f));
            continue
        end
        ana_truth = load(truth_mat_f);
        hash_truth = ana_truth.hash;
        ana_truth = ana_truth.ana;
        tab_truth = ana_truth.tabs{1}{1};
        tab_truth(:,2) = round(tab_truth(:,2) / DT);

        bad = 0;
        for u=unique(tab_truth(:,1))'
            tt = tab_truth(tab_truth(:,1) == u,:);
            if any(tt(2:end,2) - tt(1:(end-1), 2) > 1)
                failed = [failed; k1 k2];
                bad = 1;
                break
            end
        end

        if bad
            display(sprintf('  FAILED'))
            continue
        end

        disps_true = Utils.displacements(tab_truth);
        ndisps_truth = length(disps_true);
        tmp = Utils.trajs_num_pts(tab_truth);
        truth_avg_tdisps = mean(tmp(tmp > 1) - 1);

        trck_mat_f = sprintf('%s/%s/pipeline_1_trajectories.mat', dats_track{k1}.proc_dir, dats_track{k1}.data{k2});
        if ~isfile(trck_mat_f)
            display(sprintf('FILE NOT FOUND: %s', trck_mat_f));
            continue
        end

        ana_track = load(trck_mat_f);
        hash_track = ana_track.hash;
        params = ana_track.params;
        ana_track = ana_track.ana;


        all_run_len = cell(length(ana_track.tabs), 1);
        all_run_len_norm = cell(length(ana_track.tabs), 1);
        all_run_len_noa = cell(length(ana_track.tabs), 1);
        all_run_len_noa_norm = cell(length(ana_track.tabs), 1);
        for i1=1:length(ana_track.tabs)
            cur_failed = 0;

            ps_vals = cellfun(@(x) str2num(x), strsplit(params.track_strs{i1}, '_'));
            if length(ps_vals) > 1
                if ps_vals(3) ~= 0
                    continue
                end
                assert(ps_vals(3) == 0)
            end

            tab = ana_track.tabs{i1}{1};
            if isempty(strfind(dats_track{k1}.name, 'utrack'))
                tab(:,2) = round(tab(:,2) / DT);
            else
                idxs = find(ec(tab(1,3:4), tab_truth(:,3:4)) < match_dist_th);
                assert(length(idxs) == 1)
                tab(:,2) = tab(:,2) - deltas(i1);
            end

            for u=unique(tab(:,1))'
                tt = tab(tab(:,1) == u,:);
                assert(all(tt(2:end,2) - tt(1:(end-1), 2) == 1))
            end

            truth_to_tracks = ones(size(tab_truth,1), 1) * -1;
            for i=1:size(tab_truth,1)
                nh_idxs = find(tab(:,2) == tab_truth(i,2));
                nh_pts = tab(nh_idxs, :);
                idxs = find(ec(tab_truth(i, 3:4), nh_pts(:,3:4)) < match_dist_th);
                if isempty(idxs)
                    idxs = find(ec(tab_truth(i, 3:4), nh_pts(:,3:4)) < 2*match_dist_th);
                end
                if length(idxs) == 1
                    assert(nh_idxs(idxs(1)) <= size(tab,1))
                    truth_to_tracks(i) = nh_idxs(idxs(1));
                elseif length(idxs) > 1
                    assert(0)
                end
            end

            for i=unique(tab_truth(:,1))'
                tr_idxs = find(tab_truth(:,1) == i);
                tr_to_track = truth_to_tracks(tr_idxs);
                tr = tab_truth(tr_idxs, :);
                tr_disps = Utils.displacements(tr);

                run_len = [];
                run_len_noa = [];
                run = 1;
                run_noa = 1;
                for j=1:length(tr_disps)
                    if all(tr_to_track(j:(j+1)) > 0) && tab(tr_to_track(j), 1) == tab(tr_to_track(j+1), 1)
                        if j == 1 || (tr_to_track(j-1) > 0 && tab(tr_to_track(j-1), 1) == tab(tr_to_track(j), 1))
                            run = run + 1;
                        else
                            run_len = [run_len; run];
                            run = 1;
                        end
                    else
                        run_len = [run_len; run];
                        run = 1;
                    end

                    idxs = [];
                    for u=(tr(j,2)+1):tr(j+1,2)
                        idxs = [idxs; find(tab(:,2) == u)];
                    end

                    if length(idxs) == 0
                        display(sprintf('displacement with no successor: %d, %d', i, j));
                        continue
                    end
                    cnt = sum(ec(tab(idxs, 3:4), tr(j,3:4)) <= ps_vals(1)) - 1;
                    if all(tr_to_track(j:(j+1)) > 0) && tab(tr_to_track(j), 1) == tab(tr_to_track(j+1), 1)
                        if (j == 1 || (tr_to_track(j-1) > 0 && tab(tr_to_track(j-1), 1) == tab(tr_to_track(j), 1))) && cnt <= 0
                            run_noa = run_noa + 1;
                        else
                            run_len_noa = [run_len_noa; run_noa];
                            run_noa = 1;
                        end
                    else
                        run_len_noa = [run_len_noa; run_noa];
                        run_noa = 1;
                    end

                end
                run_len = [run_len; run];
                run_len_noa = [run_len_noa; run_noa];

                assert(sum(run_len) == size(tr,1))
                assert(sum(run_len_noa) == size(tr,1))

                all_run_len{i1} = [all_run_len{i1}; run_len];
                all_run_len_norm{i1} = [all_run_len_norm{i1}; run_len / size(tr,1)];
                all_run_len_noa{i1} = [all_run_len_noa{i1}; run_len_noa];
                all_run_len_noa_norm{i1} = [all_run_len_noa_norm{i1}; run_len_noa / size(tr,1)];
            end
        end

        in_exp_track = dats_track{k1}.data{k2};
        in_exp_truth = dats_truth{k1}.data{k2};

        ana = struct();
        ana.all_run_len = all_run_len;
        ana.all_run_len_norm = all_run_len_norm;

        hash = DataHash(ana);
        save(out_fname, 'in_exp_track', 'in_exp_truth', 'ana', 'hash', 'hash_track', 'hash_truth', 'params');
    end
end
