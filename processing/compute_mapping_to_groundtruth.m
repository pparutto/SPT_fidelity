addpath('../datasets/')
addpath('../external')
addpath('../')

Nreps = 2;


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
    match_dist_th = 5e-5;
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
        out_fname = sprintf('%s/mapping_groundtruth_v2.mat', cur_outdir);

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

        deltas = zeros(length(ana_track.tabs), 1);
        all_tracks_to_truth = cell(length(ana_track.tabs), 1);
        all_truth_to_tracks = cell(length(ana_track.tabs), 1);
        all_disps_tracks_to_truth = cell(length(ana_track.tabs), 1);
        all_ambig_n_tab = cell(length(ana_track.tabs), 1);
        all_ambig_idxs = cell(length(ana_track.tabs), 1);
        all_disps_truth_to_tracks = cell(length(ana_track.tabs), 1);
        all_disps_errs_ext = cell(length(ana_track.tabs), 1);
        all_disps_errs_inside = cell(length(ana_track.tabs), 1);
        all_errs_inside_dists_tracks = cell(length(ana_track.tabs), 1);
        all_errs_inside_dists_truths = cell(length(ana_track.tabs), 1);
        all_run_len = cell(length(ana_track.tabs), 1);
        err_disps_n = zeros(length(ana_track.tabs), 1);
        err_disps_cnt_disps = zeros(length(ana_track.tabs), 1);
        err_disps_f = zeros(length(ana_track.tabs), 1);
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
                ncnt = 1;
                while ncnt <= 50 && isempty(idxs)
                    idxs = find(ec(tab(1,3:4), tab_truth(:,3:4)) < ncnt*match_dist_th);
                    ncnt = ncnt + 1;
                end
                assert(length(idxs) == 1)
                deltas(i1) = tab(1,2) - tab_truth(idxs(1),2);
                tab(:,2) = tab(:,2) - deltas(i1);
            end

            for u=unique(tab(:,1))'
                tt = tab(tab(:,1) == u,:);
                assert(all(tt(2:end,2) - tt(1:(end-1), 2) == 1))
            end

            tracks_to_truth = ones(size(tab,1), 1) * -1;
            for i=1:size(tab,1)
                nh_idxs = find(tab_truth(:,2) == tab(i,2));
                nh_pts = tab_truth(nh_idxs, :);
                idxs = find(ec(tab(i, 3:4), nh_pts(:,3:4)) < match_dist_th);
                ncnt = 1;
                while ncnt <= 50 && isempty(idxs)
                    idxs = find(ec(tab(i, 3:4), nh_pts(:,3:4)) < ncnt*match_dist_th);
                    ncnt = ncnt + 1;
                end

                if length(idxs) == 1
                    tracks_to_truth(i) = nh_idxs(idxs(1));
                elseif length(idxs) > 1
                    assert(0)
                end
            end
            assert(all(tracks_to_truth ~= -1));
            all_tracks_to_truth{i1} = tracks_to_truth;

            truth_to_tracks = ones(size(tab_truth,1), 1) * -1;
            for i=1:size(tab_truth,1)
                nh_idxs = find(tab(:,2) == tab_truth(i,2));
                nh_pts = tab(nh_idxs, :);
                idxs = find(ec(tab_truth(i, 3:4), nh_pts(:,3:4)) < match_dist_th);
                ncnt = 1;
                while ncnt <= 50 && isempty(idxs)
                    idxs = find(ec(tab_truth(i, 3:4), nh_pts(:,3:4)) < ncnt*match_dist_th);
                    ncnt = ncnt + 1;
                end

                if length(idxs) == 1
                    assert(nh_idxs(idxs(1)) <= size(tab,1))
                    truth_to_tracks(i) = nh_idxs(idxs(1));
                elseif length(idxs) > 1
                    assert(0)
                end
            end
            assert(sum(truth_to_tracks ~= -1) == size(tracks_to_truth, 1))
            all_truth_to_tracks{i1} = truth_to_tracks;

            disps_tracks_to_truth = [];
            ambig_n_tab = [];
            ambig_idxs = [];
            pt_cnt = 1;
            for i=unique(tab(:,1))'
                tr_idxs = find(tab(:,1) == i);
                tr_to_truth = tracks_to_truth(tr_idxs);
                tr = tab(tr_idxs, :);
                tr_disps = Utils.displacements(tr);
                for j=1:length(tr_disps)
                    if all(tr_to_truth(j:(j+1)) ~= -1) && tab_truth(tr_to_truth(j), 1) == tab_truth(tr_to_truth(j+1), 1)
                        disps_tracks_to_truth = [disps_tracks_to_truth; i j pt_cnt tr_to_truth(j) tr_disps(j)];
                    else
                        disps_tracks_to_truth = [disps_tracks_to_truth; i j pt_cnt -1 tr_disps(j)];
                    end

                    pt_cnt = pt_cnt + 1;

                    idxs = [];
                    for u=(tr(j,2)+1):tr(j+1,2)
                        idxs = [idxs; find(tab_truth(:,2) == u)];
                    end

                    if length(idxs) == 0
                        display(sprintf('displacement with no successor: %d, %d', i, j));
                        continue
                    end
                    cnt = sum(ec(tab_truth(idxs, 3:4), tr(j,3:4)) <= ps_vals(1)) - 1;

                    ambig_n_tab = [ambig_n_tab; cnt];
                    if cnt >= 1
                        ambig_idxs = [ambig_idxs; i j];
                    end
                end

                pt_cnt = pt_cnt + 1;
            end
            all_disps_tracks_to_truth{i1} = disps_tracks_to_truth;
            all_ambig_n_tab{i1} = ambig_n_tab;
            all_ambig_idxs{i1} = ambig_idxs;

            disps_truth_to_tracks = [];
            disps_errs_ext = [];
            disps_errs_inside = [];
            run_len = [];
            errs_inside_dists_tracks = [];
            errs_inside_dists_truths = [];
            pt_cnt = 1;
            for i=unique(tab_truth(:,1))'
                tr_idxs = find(tab_truth(:,1) == i);
                tr_to_track = truth_to_tracks(tr_idxs);
                tr = tab_truth(tr_idxs, :);
                tr_disps = Utils.displacements(tr);
                run = 0;
                for j=1:length(tr_disps)
                    if all(tr_to_track(j:(j+1)) > 0) && tab(tr_to_track(j), 1) == tab(tr_to_track(j+1), 1)
                        disps_truth_to_tracks = [disps_truth_to_tracks; i j pt_cnt tr_to_track(j) tr_disps(j)];

                        if j == 1 || (disps_truth_to_tracks(end-1, 4) > 0 && tab(disps_truth_to_tracks(end-1, 4), 1) == tab(tr_to_track(j), 1))
                            run = run + 1;
                        else
                            if run == 0
                                run_len = [run_len; i 1];
                            else
                                run_len = [run_len; i run];
                            end
                            run = 0;
                        end
                    else
                        run_len = [run_len; i run];
                        run = 0;

                        if all(tr_to_track(j:(j+1)) ~= -1) && tab(tr_to_track(j), 1) ~= tab(tr_to_track(j+1), 1) && ...
                                tr_to_track(j) < size(tab, 1) && tab(tr_to_track(j)+1, 1) == tab(tr_to_track(j), 1)
                            disps_truth_to_tracks = [disps_truth_to_tracks; i, j, pt_cnt, -1, tr_disps(j)];
                            disps_errs_inside = [disps_errs_inside; i, j, tr_to_track(j), tr_to_track(j+1)];

                            d_track = ec(tab(tr_to_track(j)+1, 3:4), tab(tr_to_track(j), 3:4));

                            errs_inside_dists_tracks = [errs_inside_dists_tracks d_track];

                            if d_track > ps_vals(1)+1e-3
                                assert(0)
                            end

                            errs_inside_dists_truths = [errs_inside_dists_truths tr_disps(j)];
                        else
                            disps_truth_to_tracks = [disps_truth_to_tracks; i, j, pt_cnt, -2, tr_disps(j)];
                        end
                    end

                    pt_cnt = pt_cnt + 1;
                end
                pt_cnt = pt_cnt + 1;

                if run > 0
                    run_len = [run_len; i run];
                    run = 0;
                end

                if tr_to_track(1) > 1 && tab(tr_to_track(1), 1) == tab(tr_to_track(1) - 1, 1)
                    disps_errs_ext = [disps_errs_ext; i, tr_to_track(1)-1, tab(tr_to_track(1), 1)];
                end
                if tr_to_track(end) ~= -1 && tr_to_track(end) < size(tab,1) && tab(tr_to_track(end), 1) == tab(tr_to_track(end) + 1, 1)
                    disps_errs_ext = [disps_errs_ext; i, tr_to_track(end), tab(tr_to_track(end), 1)];
                end
            end
            all_disps_truth_to_tracks{i1} = disps_truth_to_tracks;
            all_disps_errs_ext{i1} = disps_errs_ext;
            all_disps_errs_inside{i1} = disps_errs_inside;
            all_errs_inside_dists_tracks{i1} = errs_inside_dists_tracks;
            all_errs_inside_dists_truths{i1} = errs_inside_dists_truths;
            all_run_len{i1} = run_len;

            % for u=unique(tab_truth(:,1))'
            %     tr_idxs = find(tab_truth(:,1) == u);
            % 
            %     tr_idxs(truth_to_tracks(tr_idxs) < 1) = [];
            %     if isempty(tr_idxs)
            %         if sum(run_len(:,1) == u) > 0
            %             assert(0)
            %         end
            %         continue
            %     end
            % 
            %     tr_tab = tab(truth_to_tracks(tr_idxs), :);
            %     n = 0;
            %     for uu=unique(tr_tab(:,1))'
            %         ttt = tr_tab(tr_tab(:,1) == uu, :);
            %         for uuu=1:(size(ttt,1)-1)
            %             if ttt(uuu,2) +1 == ttt(uuu+1,2)
            %                 n = n + 1;
            %             end
            %         end
            %     end
            %     assert(n == sum(run_len(run_len(:,1)==u,2)))
            % end

            assert(sum(disps_tracks_to_truth(:,4) > 0) == sum(run_len(:,2)))
            assert(all(errs_inside_dists_tracks <= ps_vals(1) + 10*match_dist_th));

            for i=unique(tab_truth(:,1))'
                assert((sum(tab_truth(:,1) == i) - 1) >= sum(run_len(run_len(:,1) == i, 2)))
            end
            for i=1:size(disps_tracks_to_truth, 1)
                if disps_tracks_to_truth(i,4) ~= -1
                    assert(sum(disps_tracks_to_truth(i,4) == disps_truth_to_tracks(:,3)) == 1)
                end
            end
            for i=1:size(disps_truth_to_tracks, 1)
                if disps_truth_to_tracks(i,4) > 0
                    assert(sum(disps_truth_to_tracks(i,4) == disps_tracks_to_truth(:,3)) == 1)
                end
            end

            assert(sum(disps_truth_to_tracks(:,4) > 0) == sum(disps_tracks_to_truth(:,4) > 0))

            disps_diff = max(0, size(disps_tracks_to_truth, 1) - size(disps_truth_to_tracks, 1));
            err_disps_n(i1) = sum(disps_truth_to_tracks(:,4) < 0) + disps_diff;
            err_disps_cnt_disps(i1) = max(size(disps_tracks_to_truth, 1), size(disps_truth_to_tracks, 1));
            err_disps_f(i1) = err_disps_n(i1) / err_disps_cnt_disps(i1);
        end

        best_err_disps_f_idx = max(find(err_disps_f == min(err_disps_f)));
        best_err_disps_f_idx = best_err_disps_f_idx(1);


        in_exp_track = dats_track{k1}.data{k2};
        in_exp_truth = dats_truth{k1}.data{k2};

        ana = struct();
        ana.deltas = deltas;
        ana.truth_avg_tlens = truth_avg_tdisps;
        ana.all_ambig_n_tab = all_ambig_n_tab;
        ana.all_ambig_idxs = all_ambig_idxs;
        ana.all_disps_errs_ext = all_disps_errs_ext;
        ana.all_disps_errs_inside = all_disps_errs_inside;
        ana.all_errs_inside_dists_tracks = all_errs_inside_dists_tracks;
        ana.all_errs_inside_dists_truths = all_errs_inside_dists_truths;
        ana.all_run_len = all_run_len;
        ana.err_disps_n = err_disps_n;
        ana.err_disps_cnt_disps = err_disps_cnt_disps;
        ana.err_disps_f = err_disps_f;
        ana.best_err_disps_f_idx = best_err_disps_f_idx;

        hash = DataHash(ana);
        save(out_fname, 'in_exp_track', 'in_exp_truth', 'ana', 'hash', 'hash_track', 'hash_truth', 'params');
    end
end
