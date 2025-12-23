addpath('../')
addpath('../datasets')
addpath('../external/')
addpath('../external/plot2svg/')

datss = {cos931_wt_bace1(); cos931_wt_bace1_struct()};

ps = struct();
ps.dist = 1;
ps.framegap = 0;
min_tr_len = 20;


pxsize = 0.0645;

max_t = [80, 20];
cm = jet(64);
Mdisp = 0.25;

bins = 0.005:0.01:0.4;

all_fits = cell(2, length(datss{1}.data));
all_gofs = cell(2, length(datss{1}.data));
all_cis = cell(2, length(datss{1}.data));
for n=1:length(datss)
    dats = datss{n};
    ps.mask = dats.constr.mask;
    ps_str = dats.track_handler.track_params(ps, dats.params);

    for k=1:length(dats.data)
        display(sprintf('%s', dats.data{k}));
        ana = load(sprintf('%s/%s/pipeline_1_trajectories.mat', dats.proc_dir, dats.data{k}));
        params = ana.params;
        ana = ana.ana;
    
        i1 = find(cellfun(@(x) strcmp(x, ps_str), params.track_strs));
        i2 = find(params.min_tr_lens == min_tr_len);
    
        display(sprintf('%g', dats.noa))
        if dats.noa
            tab = ana.tabs_noa{i1}{i2};
        else
            tab = ana.tabs{i1}{i2};
        end
        ambigs = ana.ambigs{i1}{i2};
    
        tidxs = unique(tab(:,1));
    
        display(sprintf('AVG spots = %g', mean(arrayfun(@(i) sum(tab(:,2) == i), unique(tab(:,2))))));
        display(sprintf('STD spots = %g', std(arrayfun(@(i) sum(tab(:,2) == i), unique(tab(:,2))))));

        avg_disps = [];
        std_disps = [];
        vals = cell(2,20);
        for i=1:length(tidxs)
            tr = tab(tab(:,1) == tidxs(i), :);
            dsps = Utils.displacements(tr);
            avg_disps = [avg_disps; mean(dsps)];
            std_disps = [std_disps; std(dsps)];

            if avg_disps(i) > 0.15
                dsps = smooth(Utils.displacements(tr), 3);
                for u=1:20
                    vals{1,u} = [vals{1,u}; dsps(u)];
                end
            elseif  avg_disps(i) < 0.1
                dsps = smooth(Utils.displacements(tr), 3);
                for u=1:20
                    vals{2,u} = [vals{2,u}; dsps(u)];
                end
            end
        end

        cnt_cleaved = 0;
        for i=1:length(tidxs)
            tr = tab(tab(:,1) == tidxs(i), :);
            tra = ambigs(tab(:,1) == tidxs(i));
            rdsps = Utils.displacements(tr);
            dsps = smooth(Utils.displacements(tr), 3);

            if max(dsps) > 0.6
                continue
            end

            if mean(dsps((end-5):end)) < 2 * mean(dsps(1:5))
                continue
            end

            transi = dsps(2:end) - dsps(1:(end-1));
            v = find(transi > 0.075 & transi < 0.5);
            if isempty(v)
                continue
            end
            v = v(1);
    
            if v <= 5
                continue
            end

            if v > length(dsps) - 10
                continue
            end

            if ~(mean(dsps(1:v)) < 0.1 && mean(dsps(v:end)) > 0.15)
                continue
            end

            if std(dsps(1:v)) > 0.03 || std(dsps(v:end)) < 0.05
                continue
            end

            if any(dsps > 2 * mean(cellfun(@(u) mean(u), vals(1,:))))
                continue
            end

            if n == 2 && k > 3
                cm = jet(64);
                Mdisp = 0.3;
                pause(1)
                figure
                pause(1)
                hold on
                for j=(size(tr,1)-1):-1:1
                    cidx = floor(single(dsps(j) / Mdisp) * 63) + 1;
                    if cidx > 64
                        cidx = 64;
                    end
                    plot(tr([j j+1],3), tr([j j+1],4), 'Color', cm(cidx, :))
                end
                plot(tr(1,3), tr(1,4), '*r')
                hold off
                daspect([1 1 1])
                axis([0 23.5 0 23.5])
                pause(1)
                plot2svg(sprintf('/tmp/traj_cleaved_traj_%s_%s_noa=%g_%d.svg', dats.name, strrep(dats.data{k}, '/', '_'), dats.noa, i))

                pause(1)
                figure
                pause(1)
                hold on
                plot([1 size(tr,1)-1], [1 1] * mean(cellfun(@(u) mean(u), vals(1,:))), 'r')
                plot([1 size(tr,1)-1], [1 1] * mean(cellfun(@(u) mean(u), vals(2,:))), 'b')
                plot(1:(size(tr,1)-1), dsps, 'LineWidth', 2)
                plot(1:(size(tr,1)-1), rdsps, 'k')
                if ~dats.noa
                    for j=1:size(tra,1)
                        if tra(j) > 0
                            plot(j, rdsps(j), 'og')
                        end
                    end
                end
                plot(v, rdsps(v), '*r')
                hold off
                ylim([0 0.35])
                axis square
                pause(1)
                plot2svg(sprintf('/tmp/traj_cleaved_disp_%s_%s_noa=%g_%d.svg', dats.name, strrep(dats.data{k}, '/', '_'), dats.noa, i))
            end
        end

        [o,b] = hist(avg_disps, bins);
        [f, gof] = fit(b', o' / sum(o), 'Gauss2', 'Robust', 'LAR', 'Lower', [0 0 0 0 0.15 0], 'Upper', [inf 0.1 inf inf 0.2 inf]);
        ci = confint(f);
        display(sprintf('%.1f [%.1f %.1f]; %.1f [%.1f %.1f]', f.a1 / (f.a1 + f.a2) * 100, ...
            ci(2,1) / (ci(2,1) + ci(2,4)) * 100, ci(1,1) / (ci(1,1) + ci(1,4)) * 100, ...
            f.a2 / (f.a1 + f.a2) * 100, ci(1,4) / (ci(2,1) + ci(2,4)) * 100, ci(2,4) / (ci(1,1) + ci(1,4)) * 100));

        all_fits{n,k} = f;
        all_gofs{n,k} = gof;
        all_cis{n,k} = ci;

        if k == 2 || k == 4
            writematrix(avg_disps, sprintf('/tmp/figS7d_%d_%d.csv', n, k))
            pause(1)
            cm = jet(64);
            Mdisp = 0.3;
            figure
            pause(1)
            hold on
            for i=1:length(tidxs)
                tr = tab(tab(:,1) == tidxs(i), :);
                if avg_disps(i) < 0.135
                    plot(tr(:,3), tr(:,4), 'b')
                else
                    plot(tr(:,3), tr(:,4), 'r')
                end
            end
            hold off
            daspect([1 1 1])
            clim([0 Mdisp])
            colormap('Jet');
            colorbar
            axis([0 23.5 0 23.5])
            pause(1)
            plot2svg(sprintf('/tmp/trajs_avgdisp_%s_%s_%s_minLen=%d_noa=%d.svg', dats.name, ...
                strrep(dats.data{k}, '/', '_'), params.track_strs{i1}, params.min_tr_lens(i2), dats.noa))
            pause(1)

            pause(1)
            figure
            pause(1)
            hold on
            plot(b, o / sum(o))
            plot(b, f.a1 * exp(-((b - f.b1) / f.c1).^2) + f.a2 * exp(-((b - f.b2) / f.c2).^2), 'r')
            plot(b, f.a1 * exp(-((b - f.b1) / f.c1).^2), 'b--')
            plot(b, f.a2 * exp(-((b - f.b2) / f.c2).^2), 'b--')
            hold off
            axis square
            xlabel('Displacement (mum)')
            ylabel('Frequency')
            pause(1)
            print(sprintf('/tmp/disp_hist_%s_%s_noa=%g.svg', dats.name, strrep(dats.data{k}, '/', '_'), dats.noa), '-dsvg')
            'a'
        end
    end
end


cleaved_percs = zeros(size(all_fits,1), size(all_fits,2));
for l=1:size(all_fits,2)
    fnos = all_fits{1,l};
    cleaved_percs(1,l) = fnos.a2 / (fnos.a1 + fnos.a2) * 100;

    fs = all_fits{2,l};
    cleaved_percs(2,l) = fs.a2 / (fs.a1 + fs.a2) * 100;
end

cols = {'k', 'k', 'k', 'r', 'r', 'r'};

figure
hold on
bar([mean(cleaved_percs(1,1:3))  mean(cleaved_percs(2,1:3)) mean(cleaved_percs(1,4:6)) mean(cleaved_percs(2,4:6))])
for l=1:3
    plot([1 2], cleaved_percs(:, l), 'ok', 'LineWidth', 2)
    plot([1 2], cleaved_percs(:, l), 'k', 'LineWidth', 2)
end
for l=4:6
    plot([3 4], cleaved_percs(:, l), 'or', 'LineWidth', 2)
    plot([3 4], cleaved_percs(:, l), 'r', 'LineWidth', 2)
end
hold off
axis square
ylabel('Percent cleaved trajs')
print('/tmp/APP_perc_cleaved_trajs.svg', '-dsvg')

figure
bar([mean(cleaved_percs(1,4:6)) / mean(cleaved_percs(1,1:3)) mean(cleaved_percs(2,4:6)) / mean(cleaved_percs(2,1:3))])
ylabel('Fold increase WT to BACE1 OE')
print('/tmp/APP_cleaved_fold_inc.svg', '-dsvg')