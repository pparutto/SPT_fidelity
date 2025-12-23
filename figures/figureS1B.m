addpath('../datasets/')
addpath('../external/')
addpath('..')

dist_ths = [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0 4.2 4.4 4.6 4.8 5.0 5.2 5.4 5.6 5.8 6.0];
trackm_ps = generate_track_params('tracks', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});



dats_true = simu_dens_freespace_time8('../analysis_simu/analysis/simu/freespace3/', 1:5);
dats = simu_dens_freespace_time8_track('../analysis_simu/analysis/simu/freespace3/', 1:5, trackm_ps);

DT = dats.spots_handler.dt;

ana_true = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats_true.proc_dir, dats_true.data{1}));
ana_true = ana_true.ana;
disps_true = Utils.displacements(ana_true.tabs{1}{1});

disps = cell(length(dist_ths), 1);
for k=1:length(dats)

    ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{1}));
    params = ana.params;
    ana = ana.ana;

    for l=1:length(ana.tabs)
        disps{l} = Utils.displacements(ana.tabs{l}{1});
    end
end

M = max(cellfun(@(x) max(x), disps));
bins = 0.05:0.1:(M+0.1);

cm = plasma(length(disps));

figure
hold on
for k=1:length(disps)
    [o,b] = hist(disps{k}, bins);
    plot(b, o / sum(o), 'Color', cm(k,:));
end
[o,b] = hist(disps_true, bins);
plot(b, o / sum(o), 'k--', 'LineWidth', 2)
hold off
axis square
xlim([0 6])
xlabel('Displacement (μm)')
ylabel('Frequency')
print(sprintf('/tmp/displacement_truncation_freespace_DT=%g.svg', DT), '-dsvg')

figure
hold on
for k=1:length(disps)
    [o,b] = hist(disps{k}, bins);
    plot(b, o / sum(o), 'Color', cm(k,:));
end
[o,b] = hist(disps_true, bins);
plot(b, o / sum(o), 'k--')
hold off
axis square
xlim([2 6])
ylim([0 0.005])
xlabel('Displacement (μm)')
ylabel('Frequency')
print(sprintf('/tmp/displacement_truncation_freespace_DT=%g_zoom.svg', DT), '-dsvg')