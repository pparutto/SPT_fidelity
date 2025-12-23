addpath('../datasets/')
addpath('../external')
addpath('../')

Nreps = 1;


trackm_ps = generate_track_params('track', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});

dats_truth = freespace_GT('../simu/freespace/density3/sim', 1); %1:Nreps
dats_track = freespace_track('../simu/freespace/density3/sim', 1:Nreps, trackm_ps); %trackmate

rev_order = 0;

ec = @(x,y) sqrt(sum((x - y).^2, 2));


cur_failed = 0;

all_tracks_to_truth_ratio = zeros(13, 11);
all_tracks_to_truth_ratio_sup1 = zeros(13, 11);
for k1=1:length(dats_track)
    display(sprintf('%s', dats_track{k1}.name))
    assert(dats_truth{k1}.spots_handler.dt == dats_track{k1}.spots_handler.dt);

    for k2=1:length(dats_track{k1}.data)
        display(sprintf('%d %d: %s %s', k1, k2, dats_track{k1}.name, dats_track{k1}.data{k2}))
        cur_outdir = sprintf('%s/%s', dats_track{k1}.proc_dir, dats_track{k1}.data{k2});

        truth_mat_f = sprintf('%s/%s/pipeline_1_trajectories.mat', dats_truth{k1}.proc_dir, dats_truth{k1}.data{k2});
        ana_truth = load(truth_mat_f);
        hash_truth = ana_truth.hash;
        ana_truth = ana_truth.ana;
        tab_truth = ana_truth.tabs{1}{1};

        truth_tlens = arrayfun(@(i) sum(tab_truth(:,1) == i), unique(tab_truth(:,1)));


        trck_mat_f = sprintf('%s/%s/pipeline_1_trajectories.mat', dats_track{k1}.proc_dir, dats_track{k1}.data{k2});
        ana_track = load(trck_mat_f);
        hash_track = ana_track.hash;
        params = ana_track.params;
        ana_track = ana_track.ana;

        ana_m = load(sprintf('%s/%s/mapping_groundtruth_v2.mat', dats_track{k1}.proc_dir, dats_track{k1}.data{k2}));
        ana_m = ana_m.ana;

        tab = ana_track.tabs{ana_m.best_err_disps_f_idx}{1};

        all_tracks_to_truth_ratio(k1,k2) = size(tab,1) / size(tab_truth,1);
        all_tracks_to_truth_ratio_sup1(k1,k2) = size(tab,1) / sum(truth_tlens(truth_tlens > 1));
    end
end


pause(1)
figure
h = heatmap(flipud(all_tracks_to_truth_ratio) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'Greys');
h.Colormap = h.Colormap(end:-1:1,:);
%h.YData = h.YData(end:-1:1);
%h.ColorLimits = [15 100];
h.ColorLimits = [90 100];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('number of spot ratio track / truth')
print(sprintf('/tmp/spot_ratio_truth_track_%s_%dreps.svg', dats_track{1}.name, Nreps), '-dsvg')
pause(1)

pause(1)
figure
h = heatmap(flipud(all_tracks_to_truth_ratio_sup1) * 100);
h.CellLabelFormat = '%.1f';
h.Colormap = brewermap(64, 'Greys');
h.Colormap = h.Colormap(end:-1:1,:);
%h.YData = h.YData(end:-1:1);
%h.ColorLimits = [15 100];
h.ColorLimits = [90 100];
xlabel('Density (points / µm2)')
ylabel('Characteristic length (µm)')
title('number of spot ratio track / truth (> 1pt)')
print(sprintf('/tmp/spot_ratio_truthSup1_track_%s_%dreps.svg', dats_track{1}.name, Nreps), '-dsvg')
pause(1)