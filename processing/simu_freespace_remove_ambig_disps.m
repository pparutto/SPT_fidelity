addpath('../datasets/')
addpath('../external')
addpath('../')

Nreps = 5;

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

%dats_truth = freespace_fbm_GT('../simu_raw/simu/freespace_fbm2/density', 1:3, 0.25);
%dats_track = freespace_fbm_track('../simu_raw/simu/freespace_fbm2/density', 1:3, trackm_fbm_ps, 0.25);

%dats_truth = freespace_fbm_GT('../simu_raw/simu/freespace_fbm2/density', 1:3, 0.75);
%dats_track = freespace_fbm_track('../simu_raw/simu/freespace_fbm2/density', 1:3, trackm_fbm_ps, 0.75);

%dats_truth = freespace_mixed_GT('../simu_raw/simu/freespace_mixed', 1:3);
%dats_track = freespace_mixed_track('../simu_raw/simu/freespace_mixed', 1:3);

if ~isempty(strfind(dats_track{1}.name, 'utrack'))
    match_dist_th = 5e-5;
else
    match_dist_th = 1e-5;
end

ec = @(x,y) sqrt(sum((x - y).^2, 2));

rev_order = 1;

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
        out_fname = sprintf('%s/errors_rm_ambig_v3.mat', cur_outdir);

        if isfile(sprintf('%s/errors_rm_ambig_v2.mat', cur_outdir))
            display(sprintf('Skipped[%d][%d/%d]: %s', k1, k2, length(dats_track{k1}.data), dats_track{k1}.data{k2}));
            continue
        end

        if isfile(out_fname)
          display(sprintf('Skipped[%d][%d/%d]: %s', k1, k2, length(dats_track{k1}.data), dats_track{k1}.data{k2}));
          continue
        end

        if ~isfile(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_track{k1}.proc_dir, dats_track{k1}.data{k2}))
            display(sprintf('NOT FOUND: %s', dats_track{k1}.data{k2}))
            continue
        end

        ana_truth = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_truth{k1}.proc_dir, dats_truth{k1}.data{k2}));
        hash_truth = ana_truth.hash;
        ana_truth = ana_truth.ana;
        tab_truth = ana_truth.tabs{1}{1};
        tab_truth(:,2) = round(tab_truth(:,2) / DT);

        ana_track = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_track{k1}.proc_dir, dats_track{k1}.data{k2}));
        hash_track = ana_track.hash;
        params = ana_track.params;
        ana_track = ana_track.ana;

        deltas = zeros(length(ana_track.tabs), 1);
        all_nerrs_noa = zeros(length(ana_track.tabs), 1);
        all_nerrs = zeros(length(ana_track.tabs), 1);
        all_ndisps = zeros(length(ana_track.tabs), 1);
        all_ndisps_noa = zeros(length(ana_track.tabs), 1);
        all_runlen_noa = cell(length(ana_track.tabs), 1);
        all_runlen_norm_noa = cell(length(ana_track.tabs), 1);
        all_avg_trlens_track = zeros(length(ana_track.tabs), 1);
        all_avg_trlens_track_noa = zeros(length(ana_track.tabs), 1);
        for i1=1:length(ana_track.tabs)
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

            nerrs_noa = 0;
            nerrs = 0;
            ndisps = 0;
            ndisps_noa = 0;
            runlen_noa = [];
            runlen_norm_noa = [];
            tr_lens_noa = [];
            for i=unique(tab(:,1))'
                tr_idxs = find(tab(:,1) == i);
                tr_to_truth = tracks_to_truth(tr_idxs);
                tr = tab(tr_idxs, :);
                tr_disps = Utils.displacements(tr);
                prev_trid_truth = -1;
                rlens = [];
                len_cnt = 0;
                tr_l = 1;
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

                    if (prev_trid_truth == -1 || tab_truth(tr_to_truth(j), 1) == prev_trid_truth) && cnt <= 0
                        len_cnt = len_cnt + 1;
                    else
                        rlens = [rlens; len_cnt];
                        len_cnt = 1;
                    end
                    if cnt > 0
                        prev_trid_truth = -1;
                        tr_lens_noa = [tr_lens_noa; tr_l];
                        tr_l = 1;
                    else
                        prev_trid_truth = tab_truth(tr_to_truth(j), 1);
                        tr_l = tr_l + 1;
                    end

                    if ~(all(tr_to_truth(j:(j+1)) ~= -1) && tab_truth(tr_to_truth(j), 1) == tab_truth(tr_to_truth(j+1), 1))
                        if cnt <= 0
                            nerrs_noa = nerrs_noa + 1;
                        end
                        nerrs = nerrs + 1;
                    end

                    if cnt == 0
                        ndisps_noa = ndisps_noa + 1;
                    end
                end
                ndisps = ndisps + length(tr_disps);
                if prev_trid_truth == -1 || tab_truth(tr_to_truth(j), 1) == prev_trid_truth
                    len_cnt = len_cnt + 1;
                else
                    len_cnt = 1;
                end
                tr_lens_noa = [tr_lens_noa; tr_l];
                rlens = [rlens; len_cnt];
                assert(sum(rlens) == size(tr,1));
                runlen_noa = [runlen_noa; rlens];
                runlen_norm_noa = [runlen_norm_noa; rlens / size(tr,1)];
            end
            all_avg_trlens_track(i1) = mean(arrayfun(@(i) sum(tab(:,1) == i), unique(tab(:,1))));
            all_avg_trlens_track_noa(i1) = mean(tr_lens_noa);
            all_nerrs_noa(i1) = nerrs_noa;
            all_nerrs(i1) = nerrs;
            all_ndisps(i1) = ndisps;
            all_ndisps_noa(i1) = ndisps_noa;
            all_runlen_noa{i1} = runlen_noa;
            all_runlen_norm_noa{i1} = runlen_norm_noa;
        end

        in_exp_track = dats_track{k1}.data{k2};
        in_exp_truth = dats_truth{k1}.data{k2};

        ana = struct();
        ana.deltas = deltas;
        ana.all_nerrs_noa = all_nerrs_noa;
        ana.all_nerrs = all_nerrs;
        ana.all_ndisps = all_ndisps;
        ana.all_ndisps_noa = all_ndisps_noa;
        ana.all_runlen_noa = all_runlen_noa;
        ana.all_runlen_norm_noa = all_runlen_norm_noa;
        ana.all_avg_trlens_track = all_avg_trlens_track;
        ana.all_avg_trlens_track_noa = all_avg_trlens_track_noa;

        hash = DataHash(ana);
        save(out_fname, 'in_exp_track', 'in_exp_truth', 'ana', 'hash', 'hash_track', 'hash_truth', 'params');
    end
end