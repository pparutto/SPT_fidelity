addpath('../datasets/')
addpath('../')
addpath('../external/')



datss = freespace_GT('../simu/freespace/density3/sim', 1);

ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', datss{5}.proc_dir, datss{5}.data{5}));
params = ana.params;
ana = ana.ana;


tab = ana.tabs{1}{1};
tlens = arrayfun(@(i) sum(tab(:,1) == i), unique(tab(:,1)));

[o, b] = hist(tlens, 1:max(tlens));

figure
bar(b, o / sum(o));
axis square
ylabel('Frequency')
xlabel('Trajectory length (number of spots)')
print(sprintf('/tmp/tlens_GT_%s_%s.svg', datss{5}.name, strrep(datss{5}.data{5}, '/', '_')), '-dsvg');

writematrix(tlens, '/tmp/figS1i.csv');