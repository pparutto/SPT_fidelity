addpath('../datasets/')
addpath('../external/plot2svg/')
addpath('..')

dats_nos = ineuron_737_290124();
dats = ineuron_737_290124_struct();
ps = struct();
ps.dist = 6;
ps.framegap = 0;
min_tr_len = 5;
ps.mask = 0;
ps_str = dats.track_handler.track_params(ps, dats.params);


ana_nos = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_nos.proc_dir, dats_nos.data{1}));
params = ana_nos.params;
ana_nos = ana_nos.ana;

i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
i2 = find(params.min_tr_lens == min_tr_len);

tab_nos = ana_nos.tabs{i1}{i2};

pause(1)
figure
pause(1)
Utils.show_trajectories(tab_nos, 'rand')
title('tab nos')
daspect([1 1 1])
pause(1)
plot2svg(sprintf('/tmp/neurons_nos_%s.svg', ps_str))
pause(1)

ps.mask = 0;
ps_str = dats.track_handler.track_params(ps, dats.params);

ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{1}));
ana = ana.ana;

tab = ana.tabs{i1}{i2};

pause(1)
figure
pause(1)
Utils.show_trajectories(tab, 'rand')
title('tab struct')
daspect([1 1 1])
pause(1)
plot2svg(sprintf('/tmp/neurons_s_%s.svg', ps_str))
pause(1)

%path names got changed btw raw and analysis archives
%dats.base_dir = '../tracking/290124_ineurons_737/data/';
spts = dats.spots_handler.load_spots(sprintf('%s/%s/%s', dats.base_dir, dats.data{1}, dats.spots_handler.fname));
spts(:,1) = round(spts(:,1), 1);
tab(:,5) = round(tab(:,5), 1);

ambig_fname = sprintf('%s/%s/ambig_struct_mask=1_rad=1.5_th=0.2_maxdist=8.csv', dats.base_dir, dats.data{1});
ambig_dat = csvread(ambig_fname);
ambig = cell(size(spts, 1), 1);
u = 1;
while u <= size(ambig_dat, 1)
    tmp = [];
    for v=1:ambig_dat(u,2)
        tmp = [tmp; ambig_dat(u+v,:)];
    end
    tmp(:,1) = tmp(:,1) + 1;
    ambig{ambig_dat(u,1)+1} = tmp;
    u = u + ambig_dat(u,2) + 1;
end

ec = @(p,q) sqrt(sum((p - q).^2, 2));
ambig_pos = zeros(0, 3);
ndisps = 0;
for u=1:(size(tab,1)-1)
    if tab(u+1, 1) ~= tab(u,1)
        continue
    end
    ndisps = ndisps + 1;

    p = tab(u,:);
    p_idx = find(ec(p(3:4), spts(:,2:3)) < 1e-7 & tab(u,5) == spts(:,1));
    assert(length(p_idx) == 1)
    p_ambigs = ambig{p_idx};

    if isempty(p_ambigs)
        continue
    end
    p_ambigs(:,2) = round(p_ambigs(:,2), 4);
    p_ambigs(:,3) = round(p_ambigs(:,3), 4);

    n_de = max([sum(p_ambigs(:,2) < ps.dist) - 1, 0]);
    n_dg = max([sum(p_ambigs(:,3) < ps.dist) - 1, 0]);

    if n_de > 0 || n_dg > 0
        ambig_pos = [ambig_pos; u, n_de, n_dg];
    end
end

pause(1)
figure
pause(1)
bar(sum(ambig_pos(:,2:3) / ndisps) * 100)
ylabel('% ambiguous displacements')
axis square
pause(1)
print(sprintf('/tmp/neurons_ambig_de_dg_%s.svg', ps_str), '-dsvg')
pause(1)

pause(1)
figure
pause(1)
[o,b] = hist(Utils.displacements(tab), 0.025:0.05:6);
plot(b, o / sum(o))
axis square
xlabel('Displacement (um)')
ylabel('Frequency')
pause(1)
print(sprintf('/tmp/neurons_disp_distrib_%s.svg', ps_str), '-dsvg')
pause(1)

writematrix(Utils.displacements(tab)', '/tmp/ineuron_cyto_disps.csv')