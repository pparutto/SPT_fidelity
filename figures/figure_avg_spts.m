avg_spts = [2.6948 5.3522 2.2343 1.6054 2.4142 1.4031 1.3383 1.8422 1.6370 1.4030 6.2278 4.5900 2.5518 3.7152 6.6349 48.2867 37.459];
std_spts = [1.3789 2.2179 1.1896 0.7548 1.2522 0.6821 0.6381 0.9295 0.8473 0.6558 2.7441 1.5988 1.3777 1.7415 2.3726 12.866 5.3951];

figure
hold on
bar(avg_spts)
for i=1:length(std_spts)
    plot([i i], std_spts(i) * [-1 1] + avg_spts(i), 'k')
end
hold off
axis square
ylabel('Number of spots per frame')
print('/tmp/showcases_spots_per_frame.svg', '-dsvg')
