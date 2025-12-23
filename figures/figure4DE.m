addpath('../datasets')
addpath('../external/plot2svg/')
addpath('../')


dats_raw = mito_210806_unt();
dats_ss = {mito_210806_unt_struct(); mito_210806_unt_struct_first(); mito_210806_unt_struct_last()};
struct_ambig_fname = 'ambig_struct_mask=1_rad=0.75_th=1.1_maxdist=2.1.csv';
ps.dist = 1;
ps.framegap = 0;
min_tr_len = 10;

% dats_raw = mito_210311();
% dats_ss = {mito_210311_struct(); mito_210311_struct_first(); mito_210311_struct_last()};
% struct_ambig_fname = 'ambig_struct_mask=1_rad=0.75_th=1.0_maxdist=2.1.csv';
% ps.mask = 1;
% ps.dist = 0.6;
% ps.framegap = 0;
% min_tr_len = 10;

% dats_raw = mem_210806();
% dats_ss = {mem_210806_struct(); mem_210806_struct_first(); mem_210806_struct_last()};
% struct_ambig_fname = 'ambig_struct_mask=1_rad=0.75_th=1.0_maxdist=2.1.csv';
% ps.mask = 1;
% ps.dist = 1.0;
% ps.framegap = 0;
% min_tr_len = 5;

outdir = sprintf('/tmp/%s', dats_ss{1}.name);
if ~isfolder(outdir)
    mkdir(outdir)
end

ps.mask = 0;
ps_str = dats_ss{1}.track_handler.track_params(ps, dats_ss{1}.params);

ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_raw.proc_dir, dats_raw.data{1}));
params = ana.params;
ana = ana.ana;

i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
i2 = find(params.min_tr_lens == min_tr_len);
tab = ana.tabs{i1}{i2};

pause(1)
figure
Utils.show_trajectories(tab, 'rand')
daspect([1 1 1])
axis([0 12 0 12])
title(sprintf('tab %s', dats_raw.name), 'Interpreter', 'None')
pause(1)
plot2svg(sprintf('%s/tab_raw_%s_dist=%g_minlen=%d.svg', outdir, dats_raw.name, ps.dist, min_tr_len))
pause(1)

clear ana params i1 i2 tab

ps.mask = 1;
ps_str = dats_ss{1}.track_handler.track_params(ps, dats_ss{1}.params);
for n=1:length(dats_ss{1}.data)
    display(sprintf('[%d/%d] %s', n, length(dats_ss{1}.data), dats_ss{1}.data{n}));

    ana_ss = cell(length(dats_ss), 1);
    for k=1:length(dats_ss)
        ana_s = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_ss{k}.proc_dir, dats_ss{k}.data{n}));
        params = ana_s.params;
        ana_ss{k} = ana_s.ana;
    end

    i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
    i2 = find(params.min_tr_lens == min_tr_len);

    sptss = cell(length(dats_ss), 1);
    for k=1:length(dats_ss)
        sptss{k} = dats_ss{k}.spots_handler.load_spots(sprintf('%s/%s/%s', dats_ss{k}.base_dir, dats_ss{k}.data{n}, dats_ss{k}.spots_handler.fname));
    end

    tab_ss = cell(length(dats_ss), 1);
    ambig_g_dats = cell(length(dats_ss), 1);
    ambig_poss = cell(length(dats_ss), 1);
    ndisps = cell(length(dats_ss), 1);
    for k=1:length(dats_ss)
        tab_ss{k} = ana_ss{k}.tabs{i1}{i2};
        ambig_g_dat = csvread(sprintf('%s/%s/%s', dats_ss{k}.base_dir, dats_ss{k}.data{n}, struct_ambig_fname));
        [ambig_pos, ndisp] = Utils.ambiguities_graph_dist(sptss{k}, ambig_g_dat, tab_ss{k}(:, [1 5 3 4]), ps.dist);
        ambig_poss{k} = ambig_pos;
        ndisps{k} = ndisp;
    end
    clear ambig_g_dat ambig_pos ndisp;


    tr_sizes_dgs = cell(length(dats_ss), 1);
    tr_ambigs_dgs = cell(length(dats_ss), 1);
    a_idxs_dgs = cell(length(dats_ss), 1);
    for k=1:length(dats_ss)
        tab_s = tab_ss{k};
        for i=unique(tab_s(:,1))'
            tr = tab_s(tab_s(:,1) == i, :);
    
            tr_ambigs_dgs{k} = [tr_ambigs_dgs{k}; 0];
            tr_sizes_dgs{k} = [tr_sizes_dgs{k}; size(tr,1)];
    
            tr_idxs = find(tab_s(:,1) == i);
            for j=1:size(tr,1)
                if ambig_poss{k}(tr_idxs(j),2) > 0
                    a_idxs_dgs{k} = [a_idxs_dgs{k}; tr(1,1) j];
                    tr_ambigs_dgs{k}(end) = tr_ambigs_dgs{k}(end) + 1;
                end
            end
        end
    end

    tab_s_cut_dgs = cell(length(dats_ss), 1);
    for k=1:length(dats_ss)
        tab_s_cut_dg = Utils.cut_ambiguities(tab_ss{k}, a_idxs_dgs{k});
        tab_s_cut_dgs{k} = Utils.filter_trajectories_npts(tab_s_cut_dg, min_tr_len);
    end
    clear tab_s_cut_dg;

    for u=1:length(tab_s_cut_dgs)
        pause(1)
        figure
        Utils.show_trajectories(tab_s_cut_dgs{u}, 'rand')
        daspect([1 1 1])
        axis([0 12 0 12])
        title(sprintf('tab %s cut dg', dats_ss{u}.name), 'Interpreter', 'None')
        pause(1)
        plot2svg(sprintf('%s/tab_s_cut_dg_%s_dist=%g_minlen=%d.svg', outdir, dats_ss{u}.name, ps.dist, min_tr_len))
        pause(1)
    end

    disps_ss = cell(length(dats_ss), 1);
    disps_s_cut_dgs = cell(length(dats_ss), 1);
    tr_sizes_ss = cell(length(dats_ss), 1);
    tr_sizes_s_cut_dgs = cell(length(dats_ss), 1);
    for k=1:length(dats_ss)
        disps_ss{k} = Utils.displacements(tab_ss{k});
        disps_s_cut_dgs{k} = Utils.displacements(tab_s_cut_dgs{k});
        tr_sizes_ss{k} = Utils.trajs_num_pts(tab_ss{k});
        tr_sizes_s_cut_dgs{k} = Utils.trajs_num_pts(tab_s_cut_dgs{k});
    end

    cols = lines(length(dats_ss)+1);

    all_spts = [];
    cats = [];
    for k=1:length(dats_ss)
        all_spts = [all_spts size(sptss{k}, 1)];
        cats = [cats k+1];
    end

    all_spts_rel = all_spts(2:end) / all_spts(1);
    pause(1)
    figure
    h = bar(all_spts_rel * 100, 'FaceColor', 'flat');
    for k=1:size(h.CData,1)
        h.CData(k,:) = cols(cats(k),:);
    end
    ylabel('Number of spots (relative to stack filter)')
    ylim([0 100])
    axis square
    pause(1)  
    print(sprintf('%s/spts_relstack_num_dist=%g_minlen=%d.svg', outdir, ps.dist, min_tr_len), '-dsvg')
    pause(1)
end