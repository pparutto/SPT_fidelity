addpath('../datasets/')
addpath('..')

exps = {simu_dens_freespace_time8('', 1);
        simu_dens_ER_BSA_001_time8('', 1);
        simu_dens_mito_Tom20mNeonGreen4_time8('', 1)};

DT = exps{1}.spots_handler.dt;

disps = cell(length(exps), 1);
for i=1:length(exps)        
    ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', exps{i}.proc_dir, exps{i}.data{1}));
    params = ana.params;
    ana = ana.ana;

    disps{i} = Utils.displacements(ana.tabs{1}{1});
end

bins = 0.004:0.008:max([disps{:}]);

pause(1)
figure
pause(1)
hold on
for k=1:length(exps)
    [o,b] = hist(disps{k}, bins);
    plot(b, o / sum(o))
end
vs = raylpdf(b, sqrt(2 * 1 * DT));
plot(b, vs / sum(vs), 'k--')
hold off
axis square
xlim([0 3])
ylabel('Frequency')
xlabel('Displacement (µm)')
ylim([0 0.025])
pause(1)
print(sprintf('/tmp/disp_distrib_true_free_ER_mito_dt=%g.svg', DT), '-dsvg')
pause(1)

writematrix(disps{1}', '/tmp/figS2e_freespace.csv');
writematrix(disps{2}', '/tmp/figS2e_ER.csv');
writematrix(disps{3}', '/tmp/figS2e_mito.csv');