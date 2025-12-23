addpath('../external/')

sim_cls = [0.010 0.024 0.050 0.075 0.100 0.125 0.250 0.382 0.500 0.625 0.750 0.875 1.000];

Ds = 0.001:0.05:10;
DT = 0.005:0.001:0.15;

cl = zeros(length(Ds), length(DT));
for i=1:length(Ds)
    for j=1:length(DT)
        cl(i,j) = sqrt(Ds(i) * DT(j));
    end
end

cols = viridis(length(sim_cls));

figure
hold on
imagesc(cl, 'YData', Ds, 'XData', DT)
for k=1:length(sim_cls)
    contour(DT, Ds, cl, [0 sim_cls(k)], 'Color', cols(k,:), 'LineWidth', 1.5);
end
hold off
colormap(flipud(gray))
set(gca, 'YDir', 'normal')
set(gca, 'YScale', 'log')
colorbar
%clim([0 1])
xlabel('Acquisition time (ms)')
ylabel('Diffusion coefficient (mum2/s)')
axis square
pause(2)
%plot2svg('/tmp/a.svg')
print('/tmp/charas_len_vs_D_vs_DT.svg', '-dsvg')

figure
hold on
for k=1:length(sim_cls)
    plot([0 0.1], sim_cls(k) * [1 1], 'Color', cols(k,:))
end
hold off
ylim([0 1])
pause(1)
print('/tmp/charas_len_axis.svg', '-dsvg')

figure
hold on
for k=1:length(sim_cls)
    plot([0 0.1], sim_cls(k) * [1 1], 'Color', cols(k,:))
end
hold off
set(gca, 'YScale', 'log')
%ylim([0.1 1])
pause(1)
print('/tmp/charas_len_axis_log.svg', '-dsvg')