addpath('../datasets')
addpath('../')
addpath('../external/plot2svg/')

 
datss = {mem_210806_OA_nostruct(); mem_210806_OA()};
ps = struct();
ps.dist = 0.6;
ps.framegap = 0;
min_tr_len = 5;

all_disps = cell(length(datss), length(datss{1}.data));
all_disps_cut = cell(length(datss), length(datss{1}.data));
for l=1:length(datss)
    dats = datss{l};
    for k=1:length(dats.data)
        ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{k}));
        params = ana.params;
        ana = ana.ana;

        ps.mask = dats.constr.mask;
        ps_str = dats.track_handler.track_params(ps, dats.params);

        i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
        i2 = find(params.min_tr_lens == min_tr_len);
    
        tab = ana.tabs{i1}{i2};
    
        all_disps{l,k} = Utils.displacements(tab);
    
        aidxs = [];
        for i=unique(tab(:,1))'
            tr = tab(tab(:,1) == i, :);
            for j=1:size(tr,1)
                if tr(j,6) > 0
                    aidxs = [aidxs; i j];
                end
            end
        end
        tab = Utils.cut_ambiguities(tab, aidxs);
    
        all_disps_cut{l,k} = Utils.displacements(tab);
    end
end

fits = [];
bins = 0.005:0.01:0.6;
for k=1:length(all_disps)
    [f, fci] = lognfit(all_disps{k});
    fits = [fits; f(1) fci(1,1) fci(1,2) f(2) fci(2,1) fci(2,2)];
end

disps_pooled = cell(2,2);
disps_pooled_cut = cell(2,2);
for k=1:size(all_disps, 1)
    for l=1:size(all_disps, 2)
        i = datss{k}.cat_idxs(l);
        disps_pooled{k,i} = [disps_pooled{k,i} all_disps{k,l}];
        disps_pooled_cut{k,i} = [disps_pooled_cut{k,i} all_disps_cut{k,l}];
    end
end

pause(1)
figure
pause(1)
hold on
[o,b] = hist(disps_pooled_cut{2,1}, bins);
[f2_unt, gof2_unt] = fit(b', o' / sum(o), 'B1 * x / a1^2 * exp(-x^2/(2*a1^2)) + B2 * x / a2^2 * exp(-x^2/(2*a2^2))', 'Start', [0.1 0.05 0.1 0.15], 'Lower', [0 0 0 0], 'Upper', [inf bins(end)/4 inf bins(end)/2]);
plot(b, o / sum(o), 'Color', datss{1}.cat_cols(1,:))
[o,b] = hist(disps_pooled_cut{2,2}, bins);
[f2_OA, gof2_OA] = fit(b', o' / sum(o), 'B1 * x / a1^2 * exp(-x^2/(2*a1^2)) + B2 * x / a2^2 * exp(-x^2/(2*a2^2))', 'Start', [0.1 0.05 0.1 0.15], 'Lower', [0 0 0 0], 'Upper', [inf bins(end)/4 inf bins(end)/2]);
plot(b, o / sum(o), 'Color', datss{1}.cat_cols(2,:))
hold off
axis square
ylabel('Frequency')
xlabel('Displacement (um)')
axis square
legend({'UNT', 'OA'})
print(sprintf('/tmp/memOA_disps_hist_%s_%s_minLen=%d.svg', datss{1}.name, ps_str, min_tr_len), '-dsvg')
pause(1)

writematrix(disps_pooled_cut{2,1}', '/tmp/fig4g_raw.csv')
writematrix(disps_pooled_cut{2,2}', '/tmp/fig4g_structaware.csv')

[o,b] = hist(disps_pooled_cut{1,1}, bins);
[f2_unt_conv, gof2_unt_conv] = fit(b', o' / sum(o), 'B1 * x / a1^2 * exp(-x^2/(2*a1^2)) + B2 * x / a2^2 * exp(-x^2/(2*a2^2))', 'Start', [0.1 0.05 0.1 0.15], 'Lower', [0 0 0 0], 'Upper', [inf bins(end)/4 inf bins(end)/2]);

[o,b] = hist(disps_pooled_cut{1,2}, bins);
[f2_OA_conv, gof2_OA_conv] = fit(b', o' / sum(o), 'B1 * x / a1^2 * exp(-x^2/(2*a1^2)) + B2 * x / a2^2 * exp(-x^2/(2*a2^2))', 'Start', [0.1 0.05 0.1 0.15], 'Lower', [0 0 0 0], 'Upper', [inf bins(end)/4 inf bins(end)/2]);



DT = 0.006;
ci_unt = confint(f2_unt, 0.95);
ci_unt_conv = confint(f2_unt_conv, 0.95);
ci_OA =  confint(f2_OA, 0.95);
ci_OA_conv =  confint(f2_OA_conv, 0.95);
display(sprintf('B1 D1 B2 D2 Rsq n(disps) m(recs)'))
display(sprintf('UNT: %.4f (%.4f-%.4f) %.2f (%.2f-%.2f) %.4f (%.4f-%.4f) %.2f (%.2f-%.2f) %g %d %d', f2_unt.B1, ci_unt(:,1), ...
    f2_unt.a1^2 / DT / 2, ci_unt(:,3).^2 / DT / 2, f2_unt.B2, ci_unt(:,2), ...
    f2_unt.a2^2 / DT / 2, ci_unt(:,4).^2 / DT / 2, gof2_unt.adjrsquare, length(disps_pooled_cut{2,1}), ...
    sum(datss{1}.cat_idxs == 1)));
display(sprintf('OA: %.4f (%.4f-%.4f) %.2f (%.2f-%.2f) %.4f (%.4f-%.4f) %.2f (%.2f-%.2f) %g %d %d', f2_OA.B1, ci_OA(:,1), f2_OA.a1^2 / DT / 2, ci_OA(:,3).^2 / DT / 2, ...
    f2_OA.B2, ci_OA(:,2), f2_OA.a2^2 / DT / 2, ci_OA(:,4).^2 / DT / 2, gof2_OA.adjrsquare, length(disps_pooled_cut{2,2}), ...
    sum(datss{1}.cat_idxs == 2)));

display(sprintf('UNTconv : %.4f (%.4f-%.4f) %.2f (%.2f-%.2f) %.4f (%.4f-%.4f) %.2f (%.2f-%.2f) %g %d %d', f2_unt_conv.B1, ci_unt_conv(:,1), ...
    f2_unt_conv.a1^2 / DT / 2, ci_unt_conv(:,3).^2 / DT / 2, f2_unt_conv.B2, ci_unt_conv(:,2), ...
    f2_unt_conv.a2^2 / DT / 2, ci_unt_conv(:,4).^2 / DT / 2, gof2_unt_conv.adjrsquare, length(disps_pooled_cut{1,1}), ...
    sum(datss{1}.cat_idxs == 1)));
display(sprintf('OAconv: %.4f (%.4f-%.4f) %.2f (%.2f-%.2f) %.4f (%.4f-%.4f) %.2f (%.2f-%.2f) %g %d %d', f2_OA_conv.B1, ci_OA_conv(:,1), f2_OA_conv.a1^2 / DT / 2, ci_OA_conv(:,3).^2 / DT / 2, ...
    f2_OA_conv.B2, ci_OA_conv(:,2), f2_OA_conv.a2^2 / DT / 2, ci_OA_conv(:,4).^2 / DT / 2, gof2_OA_conv.adjrsquare, length(disps_pooled_cut{1,2}), ...
    sum(datss{1}.cat_idxs == 2)));


[no, p_nos, ks_nos] = kstest2(disps_pooled{1,1}, disps_pooled{1,2});
[no, p_s, ks_s] = kstest2(disps_pooled{2,1}, disps_pooled{2,2});
[no, p_nos_cut, ks_nos_cut] = kstest2(disps_pooled_cut{1,1}, disps_pooled_cut{1,2});
[no, p_s_cut, ks_s_cut] = kstest2(disps_pooled_cut{2,1}, disps_pooled_cut{2,2});

display(sprintf('KS_s_cut p=%g, n_unt=%d, noa=%d', p_s_cut, length(disps_pooled_cut{2,1}), length(disps_pooled_cut{2,2})))

pause(1)
figure
pause(1)
bar([ks_nos ks_nos_cut ks_s ks_s_cut])
ylim([0.035 0.038])
ylabel('KS statistics (um)')
axis square
print(sprintf('/tmp/memOA_ksstat_%s_%s_minLen=%d.svg', datss{1}.name, ps_str, min_tr_len), '-dsvg')
pause(1)