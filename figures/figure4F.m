addpath('..')
addpath('../datasets/')

dists = [1.0 1.0 0.6 0.6 1.0 1.0];
min_tr_lens = [10 10 10 10 5 5];
DT = 0.006;
datss = {mito_210806_unt();
         mito_210806_unt_struct();
         mito_210311();
         mito_210311_struct();
         mem_210806();
         mem_210806_struct()};
names = {'mitoMat', 'mitoMat', 'TOMM20', 'TOMM20', 'Sec61b', 'Sec61b'};

all_disps = cell(length(datss), 1);
Dmles = zeros(length(datss), 3);
for k=1:length(datss)
    ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', datss{k}.proc_dir, datss{k}.data{1}));
    params = ana.params;
    ana = ana.ana;

    if ~isempty(strfind(datss{k}.name, 'struct'))
        ps = struct('mask', 1, 'dist', dists(k), 'framegap', 0);
    else
       ps = struct('mask', 0, 'dist', dists(k), 'framegap', 0);
    end
    ps_str = datss{k}.track_handler.track_params(ps, datss{k}.params);

    i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
    i2 = find(params.min_tr_lens == min_tr_lens(k));

    tab = ana.tabs{i1}{i2};
    disps = Utils.displacements(tab);
    all_disps{k} = disps;
end

cols = {'k', 'b', 'r', 'm', 'c'};

fits2 = cell(3, 1);
gofs2 = cell(3, 1);
cis = cell(3,1);
bins = 0.005:0.01:1;
for k=1:2:length(all_disps)
    figure
    hold on
    for u=0:1
        v = k+u;
        [o,b] = hist(all_disps{v}(all_disps{v} < bins(end)), bins);
        plot(b, o / sum(o))
        [f2, gof2] = fit(b', o' / sum(o), 'B1 * x / a1^2 * exp(-x^2/(2*a1^2)) + B2 * x / a2^2 * exp(-x^2/(2*a2^2))', 'Start', [0.1 0.05 0.1 0.15], 'Lower', [0 0 0 0], 'Upper', [inf bins(end)/4 inf bins(end)/2]);
        fits2{v} = f2;
        gofs2{v} = gof2;
        cis{v} = confint(f2, 0.95);
        plot(b, f2.B1 * b / f2.a1^2 .* exp(-b.^2 / (2 * f2.a1^2)) + f2.B2 * b / f2.a2^2 .* exp(-b.^2 / (2 * f2.a2^2)), 'r--')
    end
    hold off
    axis square
    xlabel('Displacement (um)')
    ylabel('Frequency')
    ylim([0 0.12])
    print(sprintf('/tmp/fits2pop_%s.svg', names{k}), '-dsvg')
end

for i=2:2:length(all_disps)
    writematrix(all_disps{i}', sprintf('/tmp/fig4f_%d.csv', i))
end

display(sprintf('a1 D1 a2 D2 R2 n(disps)'))
for k=1:length(fits2)
    display(sprintf('%s %.4f (%.4f, %.4f) %.2f (%.2f, %.2f) %.4f (%.4f, %.4f) %.2f (%.2f, %.2f) %.4f %d', datss{k}.name, ...
        fits2{k}.B1, cis{k}(:,1), fits2{k}.a1^2 / DT / 2, cis{k}(:,3).^2 / DT / 2, fits2{k}.B2, cis{k}(:,2), ...
        fits2{k}.a2^2 / DT / 2, cis{k}(:,4).^2 / DT / 2, gofs2{k}.adjrsquare, sum(all_disps{k} < bins(end))));
end