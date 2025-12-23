classdef Pipeline
    methods(Static)
        function st = initialise_arrays(cell_names, arr_names, n1, n2)
            tmp_cell = cell(length(cell_names), 1);
            for k=1:length(cell_names)
                tmp_cell{k} = cell(n1, 1);
            end
            tmp_arr = cell(length(arr_names), 1);
            for k=1:length(arr_names)
                tmp_arr{k} = cell(n1, 1);
            end

            for i1=1:n1
                for k=1:length(cell_names)
                    tmp_cell{k}{i1} = cell(n2, 1);
                end
                for k=1:length(arr_names)
                    tmp_arr{k}{i1} = zeros(n2, 1) * nan;
                end
            end

            st = struct();
            for k=1:length(cell_names)
                st = setfield(st, cell_names{k}, tmp_cell{k});
            end
            for k=1:length(arr_names)
                st = setfield(st, arr_names{k}, tmp_arr{k});
            end
        end

        function process_trajectories(dats, constr, min_tr_lens, force, rev)
            %trajs
            if ~isfolder(dats.proc_dir)
                mkdir(dats.proc_dir);
            end

            idxs = 1:length(dats.data);
            if rev
                idxs = length(dats.data):-1:1;
            end

            for n=idxs
                cur_outdir = sprintf('%s/%s', dats.proc_dir, dats.data{n});
                if ~isfolder(cur_outdir)
                    mkdir(cur_outdir);
                end

                out_fname = sprintf('%s/pipeline_1_trajectories.mat', cur_outdir);
                if isfile(out_fname) && ~force
                    display(sprintf('Skipped[%d/%d]: %s %s', n, length(dats.data), dats.name, dats.data{n}));
                    continue;
                end
                display(sprintf('Processing[%d/%d]: %s %s %s', n, length(dats.data), dats.name, dats.data{n}));

                trcks = dats.track_handler.find_tracks(dats.data{n}, constr);

                if isempty(trcks)
                    display(sprintf('Error: no tracks folder found'));
                    continue;
                end

                ps_vals = Parser.extract_params(trcks, dats.params);
                ps_vals.min_tr_lens = min_tr_lens;

                if isempty(dats.params)
                    ps_combs = [];
                    ps_vals.track_strs = {''};
                else
                    ps_combs = Parser.all_track_params(ps_vals, dats.track_handler.combinatorial_params(dats.params));
                    ps_vals.track_strs = cell(length(ps_combs), 1);
                end

                for k=1:length(ps_combs)
                    ps_vals.track_strs{k} = dats.track_handler.track_params(ps_combs{k}, dats.params);
                end

                if isempty(trcks)
                    display(sprintf('  Skipping: no tracks found'));
                    continue
                end

                arrays_name = {'tabs', 'sum_disps', 'max_dist', 'tlengths', 'intens'};
                if dats.track_handler.ambig_col ~= -1
                    arrays_name{end+1} = 'tabs_noa';
                    arrays_name{end+1} = 'ambigs';
                end

                ana = Pipeline.initialise_arrays(arrays_name, {'npts', 'ntrajs'}, ...
                    length(ps_vals.track_strs), length(ps_vals.min_tr_lens));


                failed = 0;
                for k=1:length(trcks)
                    if ~isfile(trcks{k}.file)
                        display(sprintf(' Skipped: File not found'))
                        failed = 1;
                        continue
                    end
                    tab = dats.track_handler.load_tracks(trcks{k}.file);
                    tab_noa = [];
                    if dats.track_handler.ambig_col ~= -1
                        aidxs = [];
                        for idx = find(tab(:,end) > 0)'
                            aidxs = [aidxs; tab(idx,1) (idx - min(find(tab(:,1) == tab(idx,1)))) + 1];
                        end
                        tab_noa = Utils.cut_ambiguities(tab, aidxs);
                    end

                    trck_str = dats.track_handler.track_params(trcks{k}.ps, dats.params);
                    if isempty(dats.params) %simu
                        i1 = 1;
                    else
                        i1 = find(cellfun(@(x) strcmp(x, trck_str), ps_vals.track_strs));
                    end

                    for i2=1:length(min_tr_lens)
                        display(sprintf('[%d/%d][%d/%d]', k, length(trcks), i2, length(min_tr_lens)));
                        cur_tab_noa = [];

                        min_tr_len = min_tr_lens(i2);
                        if min_tr_len > 0
                            cur_tab = Utils.filter_trajectories_npts(tab, min_tr_len);
                            keep_arr = Utils.filter_trajectories_npts_array(tab, min_tr_len);
                            if ~isempty(tab_noa)
                                cur_tab_noa = Utils.filter_trajectories_npts(tab_noa, min_tr_len);
                            end
                        else
                            cur_tab = tab;
                            keep_arr = ones(1, size(tab,1));
                            if ~isempty(tab_noa)
                                cur_tab_noa = tab_noa;
                            end
                        end

                        ana.tabs{i1}{i2} = cur_tab;
                        if ~isempty(cur_tab_noa)
                            ana.ambigs{i1}{i2} = ana.tabs{i1}{i2}(:,end);
                            ana.tabs{i1}{i2} = ana.tabs{i1}{i2}(:,1:(end-1)); %remove the ambig column
                            ana.tabs_noa{i1}{i2} = cur_tab_noa;
                        end

                        if ~isempty(cur_tab)
                            ana.tlengths{i1}{i2} = arrayfun(@(i) sum(cur_tab(:,1) == i), unique(cur_tab(:,1)))';
                            ana.sum_disps{i1}{i2} = [];
                            ana.max_dist{i1}{i2} = [];
                            for u=unique(cur_tab(:,1))'
                                disps = Utils.disps_traj(cur_tab(cur_tab(:,1) == u, :));
                                ana.sum_disps{i1}{i2} = [ana.sum_disps{i1}{i2} sum(disps)];
                                ana.max_dist{i1}{i2} = [ana.max_dist{i1}{i2} Utils.tr_max_dist(cur_tab(cur_tab(:,1) == u, :))];
                            end
                            ana.npts{i1}(i2) = size(cur_tab, 1);
                            ana.ntrajs{i1}(i2) = length(unique(cur_tab(:,1)));
                        end
                    end
                end

                if failed == 1
                    continue
                end

                in_exp = dats.data{n};
                hash = DataHash(ana);
                params = ps_vals;
                save(out_fname, 'ana', 'in_exp', 'hash', 'params', 'trcks');
            end
        end

        function compute_ambiguities(dats, force)
            %Ambiguities
            for n=1:length(dats.data)
                cur_outdir = sprintf('%s/%s', dats.proc_dir, dats.data{n});
                if ~isfolder(cur_outdir)
                    mkdir(cur_outdir);
                end

                out_fname = sprintf('%s/pipeline_5_ambiguities.mat', cur_outdir);
                if isfile(out_fname) && ~force
                    display(sprintf('Skipped[%d/%d]: %s', n, length(dats.data), dats.data{n}));
                    continue
                end
                if ~isfile(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{n}))
                    display(sprintf('Error[%d/%d]: pipeline_1_trajectories.mat not found', n, length(dats.data)));
                    continue;
                end
                display(sprintf('Processing[%d/%d]: %s', n, length(dats.data), dats.data{n}));

                ana_t = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{n}));
                params = ana_t.params;
                ana_t = ana_t.ana;

                ana = Pipeline.initialise_arrays({'ambig_trajs', 'ambig_pos', 'ambig_idxs', 'tabs_no_ambigs', 'tab_cut_ambigs'}, {'ambig_disps'}, ...
                    length(params.track_strs), length(params.min_tr_lens));

                spts = dats.spots_handler.load_spots(sprintf('%s/%s/%s', dats.base_dir, dats.data{n}, dats.spots_handler.fname));
                spts(:,1) = round(spts(:,1), 5);

                for i1=1:length(params.track_strs)
                    ps_vals = Parser.params_track_struct(params.track_strs{i1}, dats.params);
                    for i2=1:length(params.min_tr_lens)
                        tab = ana_t.tabs{i1}{i2};

                        if isempty(tab)
                            continue;
                        end

                        if isfield(dats.track_handler, 'frameid')
                            tab(:,2) = tab(:,5);
                        end

                        nsuccs = sum(arrayfun(@(i) sum(tab(:,1) == i) - 1, unique(tab(:,1))));
                        [ambig_trs, cnt_ambig, ambig_pos, ambig_idxs] = Utils.ambiguities_per_traj(tab, spts, ps_vals.dist, 5);
                        assert(all(ambig_trs > -2))
                        ana.ambig_trajs{i1}{i2} = ambig_trs;
                        ana.ambig_disps{i1}(i2) = cnt_ambig / nsuccs;
                        ana.ambig_pos{i1}{i2} = ambig_pos;
                        ana.ambig_idxs{i1}{i2} = ambig_idxs;

                        tab_no_ambigs = [];
                        tab_cut_ambigs = [];
                        midx = max(tab(:,1)) + 1;
                        for i=unique(tab(:,1))'
                            tr = ana_t.tabs{i1}{i2}(tab(:,1) == i, 1:4);
                            
                            if isempty(ambig_idxs)
                                tab_no_ambigs = [tab_no_ambigs; tr];
                                tab_cut_ambigs = [tab_cut_ambigs; tr i * ones(size(tr,1), 1)];
                                continue
                            end

                            aidxs = ambig_idxs(ambig_idxs(:,1) == i, 2);
                            if isempty(aidxs)
                                tab_no_ambigs = [tab_no_ambigs; tr];
                                tab_cut_ambigs = [tab_cut_ambigs; tr i * ones(size(tr,1), 1)];
                            else
                                sub_tr = [];
                                for j=1:size(tr,1)
                                    if any(aidxs == j)
                                        if ~isempty(sub_tr)
                                            tab_cut_ambigs = [tab_cut_ambigs; [midx * ones(size(sub_tr,1), 1) sub_tr(:,2:end) i * ones(size(sub_tr, 1),1)]];
                                            midx = midx + 1;
                                            sub_tr = [];
                                        end
                                    else
                                        sub_tr = [sub_tr; tr(j,:)];
                                    end
                                end

                                if ~isempty(sub_tr)
                                    tab_cut_ambigs = [tab_cut_ambigs; [midx * ones(size(sub_tr,1), 1) sub_tr(:,2:end) i * ones(size(sub_tr, 1),1)]];
                                    midx = midx + 1;
                                    sub_tr = [];
                                end
                            end
                        end

                        ana.tabs_no_ambigs{i1}{i2} = tab_no_ambigs;
                        ana.tabs_cut_ambigs{i1}{i2} = tab_cut_ambigs;
                    end
                end

                in_exp = dats.data{n};
                hash = DataHash(ana);
                traj_hash = DataHash(ana_t);
                save(out_fname, 'ana', 'in_exp', 'hash', 'traj_hash', 'params', '-v7.3');
            end
        end
    end
end

