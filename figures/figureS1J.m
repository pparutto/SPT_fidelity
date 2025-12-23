addpath('../datasets/')
addpath('../')
addpath('../external/')

trackm_ps = generate_track_params('track', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});
trackm_fbm_ps = generate_track_params('tracks', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});

Nreps = 3;
datss = {freespace_fbm_GT('', 1:Nreps, 0.25);
         freespace_GT('', 1:Nreps);
         freespace_fbm_GT('', 1:Nreps, 0.75)};

k1 = 8;
k2 = 5;

disps = cell(length(datss), 1);
SDs = cell(length(datss), 50);
for k=1:length(datss)
    for n=1:Nreps
        ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', datss{k}{k1}.proc_dir, datss{k}{k1}.data{k2+(n-1)*13}));
        ana = ana.ana;
        tab = ana.tabs{1}{1};

        for i=unique(tab(:,1))'
            tr = tab(tab(:,1) == i, :);
            for j=1:min([size(tr,1) 50])
                SDs{k,j} = [SDs{k,j}; sum((tr(j,3:4) - tr(1,3:4)).^2,2)];
            end
            disps{k} = [disps{k}; Utils.displacements(tr)'];
        end
    end
end

writematrix(disps{1}, '/tmp/figS1j_disp_0.25.csv')
writematrix(disps{2}, '/tmp/figS1j_disp_0.5.csv')
writematrix(disps{3}, '/tmp/figS1j_disp_0.75.csv')



pause(1)
figure
pause(1)
hold on
for k=1:length(datss)
    [o,b] = hist(disps{k}, 100);
    plot(b,o/sum(o))
end
hold off
axis square
ylabel('Frequency')
xlabel('Displacement (um)')
print(sprintf('/tmp/disps_distrib_bm_fbm025_075_%d_%d_nreps=%d.svg', k1, k2, Nreps), '-dsvg')
pause(1)

pause(1)
figure
pause(1)
hold on
for k=1:length(datss)
    tmp = SDs(k,:);
    avg_tmp = cellfun(@(x) mean(x), tmp(1:15));
    plot((0:14) * datss{1}{k1}.spots_handler.dt, avg_tmp)

    writematrix(avg_tmp', sprintf('/tmp/figS1j_msd_%d.csv', k))
end
hold off
axis square
xlim([0 2.1])
ylabel('Mean squared displacement (um²)')
xlabel('Time lag (s)')
print(sprintf('/tmp/MSD_bm_fbm025_075_%d_%d_nreps=%d.svg', k1, k2, Nreps), '-dsvg')
