classdef Utils
    methods(Static)
        function res = npts_per_frame(tab, dt)
            res = zeros(floor(single(max(tab(:,2)) / dt))+1, 1);
            for i=1:size(tab,1)
                idx = floor(single(tab(i,2) / dt))+1;
                res(idx) = res(idx) + 1;
            end
        end

        function stck = read_tiff_stack(fname)
            tiff_info = imfinfo(fname);
            stck = zeros(size(tiff_info, 1), tiff_info(1).Height, tiff_info(1).Width);
            for i=1:size(tiff_info, 1)
                stck(i,:,:) = imread(fname, i);
            end
        end

        function [files, cats] = find_all_files(based, fname)
            files = {};
            cats = {};

            todo = {based};
            while ~isempty(todo)
                curd = todo{1};
                todo = todo(2:end);

                subds = dir(curd);
                for k=1:length(subds)
                    if ~strcmp(subds(k).name, '.') && ~strcmp(subds(k).name, '..') && subds(k).isdir
                        todo{length(todo)+1} = sprintf('%s/%s', subds(k).folder, subds(k).name);
                    elseif strcmp(subds(k).name, fname)
                        files{length(files)+1} = sprintf('%s/%s', subds(k).folder, fname);
                        cats{length(cats)+1} = strsplit(subds(k).folder(length(based)+1:end), '/');
                    end
                end
            end
        end

        function dt = find_dt(tab)
            dts = [];
            for k=unique(tab(:,1))'
                tr = round(tab(tab(:,1) == k, 2), 5);
                dts = unique([dts; unique(round(tr(2:end) - tr(1:(end-1)),5))]);
            end

            dt = min(dts);
        end

        function tab = load_trackmate(fname)
            dat = dlmread(fname, ',', 1, 1);
            tab = dat(:, [2, 7, 4, 5]);
        end

        function tab = load_trackmate_script(fname)
            dat = dlmread(fname, ',', 1, 0);
            tab = dat(:, [1, 5, 3, 4]);
        end

        function tab = load_trackmate_spots(fname)
            dat = dlmread(fname, ',', 1, 0);
            tab = dat(:, [4, 2, 3]);
        end

        function grid = gen_grid(tab, r)
            Xmax=max(tab(:,3));
            Ymax=max(tab(:,4));

            Nx=ceil(Xmax/r)+1;
            Ny=ceil(Ymax/r)+1;
            N=max(Nx,Ny);
            
            grid = (0:N) .* r;
        end

        function cat = antitryps_cat(fname)
            if contains(fname, '-M_')
                cat = 'M';
            elseif contains(fname, '-Z_')
                cat = 'Z';
            else
                assert(false);
            end
        end
        
        function ivels = ivels(tab)
            ivels = [];
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                ivels = [ivels; sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2)) ./ (tr(2:end, 2) - tr(1:(end-1), 2))];
            end
        end

        function disps = disps_traj(tr)
            disps = sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2));
        end
        
        function ivels = ivels_traj(tr)
            ivels = sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2)) ./ (tr(2:end, 2) - tr(1:(end-1), 2));
        end

        function avg_disps = trajs_avg_disps(tab)
            avg_disps = [];
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                avg_disps = [avg_disps; mean(sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2)))];
            end
        end
        
        function [disps, ivels] = disps_and_ivels(tab)
            dt = Utils.find_dt(tab);
            disps = [];
            ivels = [];

            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                d = sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2));
                delta_t = tr(2:end, 2) - tr(1:(end-1), 2);
                disps = [disps; d ./ (delta_t / dt)];
                ivels = [ivels;  d ./ delta_t];
            end
        end
        
        function ivels_tr = ivels_along_traj(tab)
            ivels_tr = {};

            cnt = 1;
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                ivels_tr{cnt} = sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2)) ./ ...
                                     (tr(2:end, 2) - tr(1:(end-1), 2));
                cnt = cnt + 1;
            end
        end

        function disps_tr = disps_along_traj(tab)
            disps_tr = {};

            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                disps_tr{i+1} = sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2))';
            end
        end

        function ivels_cats = ivels_cats(tab, cats)
            %cats must start at 0 and end at >= max(ivels)
            ivels = [];
            ivels_cats = cell(length(cats)-1, 1);
            for k=1:length(ivels_cats)
                ivels_cats{k} = zeros(0, 2);
            end

            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                cur_ivels = sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2)) ./ ...
                    (tr(2:end, 2) - tr(1:(end-1), 2));
                ivels = [ivels; cur_ivels];

                for j=1:length(cur_ivels)
                    cidx = max(find(cur_ivels(j) - cats >= 0));
                    ivels_cats{cidx} = [ivels_cats{cidx}; tr([j j+1], 3:4); nan nan];
                end
            end
        end

        function vel_cats = ivels_cats_percs(b, o, perc)
            %perc in [0 1]
            vel_cats = [0];

            co = cumsum(o) / sum(o);
            cur_perc = perc;
            for i=1:(length(co)-1)
                if co(i) >= cur_perc
                    vel_cats = [vel_cats b(i)];
                    cur_perc = cur_perc + perc;
                end
            end

            vel_cats = [vel_cats b(end) + (b(2) - b(1))];
        end

        function tidxs = filter_trajectories_idxs_npts(tab, npts)
            tidxs = unique(tab(:,1))';
            keep = [];
            for i=1:length(tidxs)
                if sum(tab(:,1) == tidxs(i)) > npts
                    keep = [keep tidxs(i)];
                end
            end
            tidxs = keep;
        end

        function idxs = filter_trajectories_npts_array(tab, npts)
            idxs = [];
            for i=unique(tab(:,1))'
                s = sum(tab(:,1) == i);
                if sum(tab(:,1) == i) > npts
                    idxs = [idxs ones(1, s)];
                else
                    idxs = [idxs zeros(1,s)];
                end
            end
        end

        function tab_new = filter_trajectories_npts(tab, npts)
            tab_new = [];
            for i=unique(tab(:,1))'
                if sum(tab(:,1) == i) > npts
                    tab_new = [tab_new; tab(tab(:,1) == i, :)];
                end
            end
        end

        function [gx, gy] = gen_grid_from_mat(minp, maxp, dx)
            Nx=ceil(single(maxp(1) - minp(1)) / dx) + 1;
            Ny=ceil(single(maxp(2) - minp(2)) / dx) + 1;
            N=max(Nx, Ny);

            gx = minp(1) + (0:N) .* dx;
            gy = minp(2) + (0:N) .* dx;
        end

        function ambig = ambig_map(a_pos, gx, gy)
            r = gx(2) - gx(1);
            ambig = zeros(length(gx), length(gy));
            for k=1:size(a_pos, 1)
                cx = floor(single((a_pos(k,1) - gx(1)) / r)) + 1;
                cy = floor(single((a_pos(k,2) - gy(1)) / r)) + 1;
                
                if cx > 0 && cy > 0 && cx <= length(gx) && cy <= length(gy)
                    ambig(cx, cy) = ambig(cx, cy) + 1;
                end
            end
        end

        function ndisps = ndisps_map(tab, gx, gy)
            r = gx(2) - gx(1);
            ndisps = zeros(length(gx), length(gy));
            for k = 1:size(tab, 1)
                cx = floor(single((tab(k,3) - gx(1)) / r)) + 1;
                cy = floor(single((tab(k,4) - gy(1)) / r)) + 1;

                if cx > 0 && cy > 0 && cx <= length(gx) && cy <= length(gy)
                    ndisps(cx, cy) = ndisps(cx, cy) + 1;
                end
            end
        end
        
        function disp_map = disp_cnt_map(tab, gx, gy)
            r = gx(2) - gx(1);
            disp_map = zeros(length(gx), length(gy));
            for k=1:(size(tab, 1)-1)
                if tab(k+1, 1) ~= tab(k,1)
                    continue
                end

                cx = floor(single((tab(k,3) - gx(1)) / r)) + 1;
                cy = floor(single((tab(k,4) - gy(1)) / r)) + 1;
                
                if cx > 0 && cy > 0 && cx <= length(gx) && cy <= length(gy)
                    disp_map(cx, cy) = disp_map(cx, cy) + 1;
                end
            end
        end

        function dens = density_map(tab, gx, gy, types)
            assert(any(cellfun(@(x) strcmp(x, 'dens'), types) | cellfun(@(x) strcmp(x, 'npts'), types) | ...
                cellfun(@(x) strcmp(x, 'log'), types)))
            r = gx(2) - gx(1);
            dens = zeros(length(gx), length(gy));

            for k = 1:size(tab, 1)
                cx = floor(single((tab(k,3) - gx(1)) / r)) + 1;
                cy = floor(single((tab(k,4) - gy(1)) / r)) + 1;

                if cx > 0 && cy > 0 && cx <= length(gx) && cy <= length(gy)
                    dens(cx, cy) = dens(cx, cy) + 1;
                end
            end

            if any(cellfun(@(x) strcmp(x, 'dens'), types))
                dens = dens / r^2;
            end
            if any(cellfun(@(x) strcmp(x, 'log'), types))
                dens = log(dens);
            end
        end

        function D = diffusion_map(tab, gx, gy, npts_th)
            r = gx(2) - gx(1);
            sigmaxx= zeros(length(gx), length(gy));
            sigmayy= zeros(length(gx), length(gy));
            cpt = zeros(length(gx), length(gy));

            for i=1:length(tab)-1
                line = tab(i,:);
                line2 = tab(i+1,:);

                if line(1)==line2(1)
                    if ~isnan(line(3) + line2(3))
                        x = floor(single((line(3)-gx(1)) / r)) + 1;
                        y = floor(single((line(4)-gy(1)) / r)) + 1;

                        dx = (line2(3) - line(3))^2;
                        dy = (line2(4) - line(4))^2;
                        dt = line2(2) - line(2);

                        if x > 0 && y > 0
                            sigmaxx(x,y) = sigmaxx(x,y) + dx / dt;
                            sigmayy(x,y) = sigmayy(x,y) + dy / dt;
                            cpt(x,y) = cpt(x,y) + 1;
                        end
                    end
                end
            end

            sigmaxx = sigmaxx ./ cpt;
            sigmayy = sigmayy ./ cpt;
            D = (sigmaxx + sigmayy) / 4;
            D(cpt < npts_th) = nan;
        end

        function drift = drift_map(tab, gx, gy, npts_th)
            r = gx(2) - gx(1);
            drift = zeros(length(gx), length(gy), 2);
            cpt = zeros(length(gx), length(gy));

            for i=1:(size(tab,1)-1)
                line=tab(i,:);
                line2=tab(i+1,:);

                if line(1)==line2(1)
                    if ~isnan(line(3)+line2(3))
                        x = floor(single(line(3) - gx(1)) / r) + 1;
                        y = floor(single(line(4) - gy(1)) / r) + 1;

                        assert(line2(2) ~= line(2))
                        if x > 0 && y > 0 && x <= size(drift,1) && y <= size(drift,2)
                            drift(x, y, 1) = drift(x, y, 1) + (line2(3)-line(3))  / (line2(2)-line(2));
                            drift(x, y, 2) = drift(x, y, 2) + (line2(4)-line(4)) / (line2(2)-line(2));
                            cpt(x, y) = cpt(x, y) + 1;
                        end
                    end
                end
            end

            drift(:,:,1) = drift(:,:,1) ./ cpt;
            drift(:,:,2) = drift(:,:,2) ./ cpt;

            for i=1:size(drift, 1)
                for j=1:size(drift, 2)
                    if cpt(i,j) < npts_th
                        drift(i,j,:) = [nan, nan];
                    end
                end
            end
        end

        function res = gen_scalar_map_from_mat(gx, gy, s)
            res = zeros(length(gx), length(gy)) * nan;
            ss = strsplit(s, ';');
            
            for i=1:length(ss)
                tmp = strsplit(ss{i}, ':');
                res(str2num(tmp{1})+1, str2num(tmp{2})+1) = str2double(tmp{3});
            end
        end

        function res = gen_vector_map_from_mat(gx, gy, s)
            res = zeros(length(gx), length(gy), 2) * nan;
            ss = strsplit(s, ';');

            for i=1:length(ss)
                tmp = strsplit(ss{i}, ':');
                res(str2num(tmp{1})+1, str2num(tmp{2})+1, :) = str2double(tmp(3:4));
            end
        end

        function show_trajectories(tab, col)
            if isempty(tab)
                return;
            end
            
            ih = ishold;
            if ~ih
                hold on
            end

            if strcmp(col, 'rand')
                for i=unique(tab(:,1))'
                    plot(tab(tab(:,1) == i, 3), tab(tab(:,1) == i, 4), 'Color', rand(1,3), 'LineWidth', 0.2)
                end
            else
                tmp = [];
                for i=unique(tab(:,1))'
                    tmp = [tmp; tab(tab(:,1) == i, 3:4); nan nan];
                end
                plot(tmp(:,1), tmp(:,2), 'Color', col, 'LineWidth', 0.2)
            end

            if ~ih
                hold off
            end
        end

        function show_trajectories_ivels(tab, min_disp_v, max_disp_v)
            ih = ishold;
            if ~ih
                hold on
            end
            
            cm = jet(64);
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                ivels = Utils.ivels_traj(tr);
                for j=1:length(ivels)
                    plot(tr([j j+1], 3), tr([j j+1], 4), 'Color', cm(min(floor((ivels(j) - min_disp_v) / max_disp_v * 63) + 1, 64), :))
                end
            end

            if ~ih
                hold off
            end
        end


        function show_scalar_map(scalmap, gx, gy, minval, maxval)
            ih = ishold;
            if ~ih
                hold on
            end

            r = gx(2) - gx(1);

            scalmap = scalmap(floor(single((gx-gx(1))/ r)) + 1, floor(single((gy-gy(1)) / r)) + 1);

            cm = jet(256);
            cm(1,:) = [1, 1, 1];
            colormap(gca, cm);

            M = min([maxval max(scalmap(:))]) - minval;

            for i=1:size(scalmap, 1)
                for j=1:size(scalmap, 2)
                    if scalmap(i,j) >= minval && scalmap(i,j) <= maxval
                        fill(gx(i) + [0 0 1 1] * r, gy(j) + [0 1 1 0] * r, ...
                                ind2rgb(ceil(((scalmap(i,j) - minval) ./ M).*255)+1, cm), 'EdgeColor', 'none')
                    end
                end
            end
            caxis([0 M]);

            %imagesc needs the center of the pixel hence the + r/2
            %imagesc(scalmap', 'XData', [gx(1), gx(end)], 'YData', [gy(1), gy(end)]);
            %set(gca,'YDir','normal')
            if ~ih
                hold off
            end
        end

        function show_vector_map(drift, gx, gy, scaling, lw)
            function [] = my_quiver(lx, ly, ldx, ldy, mult)
                alpha = 0.33; % Size of arrow head relative to the length of the vector
                beta = 0.33;  % Width of the base of the arrow head relative to the
                eps=0.0001;

                cm = [1 0 1; 1 0 0; 0 1 0; 0 1 1];

                ih = ishold;
                if ~ih
                    hold on
                end

                for k=1:length(lx)
                    x = lx(k);
                    y = ly(k);
                    dx = ldx(k);
                    dy = ldy(k);

                    DX=dx/sqrt(dx^2+dy^2);
                    DY=dy/sqrt(dx^2+dy^2);

                    th = mod(atan2(DY, DX) + 2*pi, 2*pi);

                    if th >= 7*pi/4 || th < pi/4
                        cidx = 1;
                    elseif th >= pi/4 && th < 3*pi/4
                        cidx = 2;
                    elseif th >= 3*pi/4 && th < 5*pi/4
                        cidx = 3;
                    else
                        cidx = 4;
                    end

                    if mult > 0
                        dx = DX * mult;
                        dy = DY * mult;
                    elseif mult <= 0
                        dx = abs(mult) * dx;
                        dy = abs(mult) * dy;
                    end

                    plot([x x+dx],[y y+dy],'Color',cm(cidx,:), 'LineWidth', lw);
                    plot([x+dx, x+dx-alpha*(dx+beta*(dy+eps))] , ...
                        [y+dy, y+dy-alpha*(dy-beta*(dx+eps))] , ...
                        'Color',cm(cidx,:), 'LineWidth', lw);
                    plot([x+dx, x+dx-alpha*(dx-beta*(dy+eps))] , ...
                        [y+dy, y+dy-alpha*(dy+beta*(dx+eps))] , ...
                        'Color',cm(cidx,:), 'LineWidth',lw);
                end

                if ~ih
                    hold off
                end
            end

            r = gx(2) - gx(1);
            d = [];
            for i=1:length(gx)
                for j=1:length(gy)
                    ix = floor(single(gx(i) - min(gx)) / r) + 1;
                    jx = floor(single(gy(j) - min(gy)) / r) + 1;
                    if all(~isnan(drift(ix, jx, 1:2)))
                        d = [d; [gx(i) + r/2, gy(j) + r/2, ...
                            drift(ix, jx, 1), drift(ix, jx, 2)]];
                    end
                end
            end
            if ~isempty(d)
                my_quiver(d(:, 1), d(:,2), d(:,3), d(:,4), scaling);
            end
        end

        function show_ellipse(e, col)
            ih = ishold;
            if ~ih
                hold on
            end

            %plot(mu(1), mu(2), 'x', 'Color', col);

            theta = linspace(0,2*pi,50);
            theta = [theta 2*pi + (theta(2) - theta(1))];
            plot(e(1) + e(3)*cos(theta)*cos(e(5)) - e(4)*sin(theta)*sin(e(5)), ...
                 e(2) + e(3)*cos(theta)*sin(e(5)) + e(4)*sin(theta)*cos(e(5)), ...
                'Color', col, 'LineWidth', 1)
            
            if ~ih
                hold off
            end
        end

        function idx = val_to_idx(v, vmin, vmax, cm_size)
            idx = floor(single((v - vmin) / vmax) * (cm_size - 1)) + 1;
        end

        function [res, tr_id] = trajs_num_pts(tab)
            res = [];
            tr_id = [];
            for i=unique(tab(:,1))'
                res = [res; sum(tab(:,1) == i)];
                tr_id = [tr_id; i];
            end
        end

        function [tab_reg, tr_ids] = trajs_in_reg(tab, reg)
            tr_ids = [];
            tab_reg = [];
            for i=unique(tab(:,1))'
                if all(inpolygon(tab(tab(:,1) == i, 3), tab(tab(:,1) == i, 4), ...
                        reg(:,1), reg(:,2)))
                    tr_ids = [tr_ids; i];
                    tab_reg = [tab_reg; tab(tab(:,1) == i, :)];
                end
            end
        end

        function res = tr_max_dist(tr)
            tmp = [];
            for u=1:size(tr,1)
                for v=1:size(tr,1)
                    tmp = [tmp max(sum((tr(u, 3:4) - tr(v, 3:4)).^2))];
                end
            end
            res = sqrt(max(tmp));
        end

        function [res, tr_id] = trajs_max_dist(tab)
            res = [];
            tr_id = [];
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, 3:4);
                M = 0;
                for u=1:size(tr,1)
                    M = max([M max(sum((tr(u+1:end, :) - tr(u, :)).^2, 2))]);
                end
                res = [res; sqrt(M)];
                tr_id = [tr_id; i];
            end
        end

        function [res, tr_id] = trajs_max_radius(tab)
            res = [];
            tr_id = [];
            for i=unique(tab(:,1))'
                m = mean(tab(tab(:,1) == i, 3:4), 1);
                res = [res; max(sqrt(sum((tab(tab(:,1) == i, 3:4) - m).^2, 2)))];
                tr_id = [tr_id; i];
            end
        end

        function [res, tr_id] = total_distance(tab)
            res = [];
            tr_id = [];
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);

                if size(tr, 1) < 2
                    continue
                end

                res = [res; sqrt(sum((tr(end, 3:4) - tr(1, 3:4)).^2, 2)) / size(tr,1)];
                tr_id = [tr_id; i];
            end
        end

        function [res, res_trajs, tr_id] = trajs_max_conf_points(tab, r)
            rr = r * r;
            res = [];
            res_trajs = {};
            tr_id = [];
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                cur_max = 0;
                res_trajs{length(res_trajs)+1} = [];
                for j=1:size(tr, 1)
                    for k=(j+1):size(tr, 1)
                        m = mean(tr(j:k, 3:4), 1);
                        if any(sum((tr(j:k, 3:4) - m).^2, 2) > rr)
                            break
                        end
                    end
                    if k-j-1 > cur_max
                        cur_max = k - j - 1;
                        res_trajs{end} = zeros(size(tr, 1), 1);
                        res_trajs{end}(j:(k-1)) = 1;
                    end
                end
                res = [res; cur_max];
                tr_id = [tr_id; i];
            end
        end

        function cross_pos = detect_recursion(tr, tau_min)
            cross_pos = [];
            for i=1:(size(tr, 1) - 1)
                for j=(i+tau_min):(size(tr, 1) - 1)
                    if polyxpoly(tr([i i+1], 3), tr([i i+1], 4), ...
                                 tr([j j+1], 3), tr([j j+1], 4))
                        cross_pos = [cross_pos; j];
                    end
                end
            end

            if isempty(cross_pos)
                return;
            end

            cross_pos = sort(cross_pos);
            tmp = cross_pos(1);
            for i=2:length(cross_pos)
                if cross_pos(i) ~= cross_pos(i-1) + 1
                    tmp = [tmp; cross_pos(i)];
                end
            end
            cross_pos = tmp;
        end

        function scalarmap_to_svg(m, max_val, px_size, outf)
            fid = fopen(outf, 'w');
            fprintf(fid, '<?xml version="1.0" standalone="yes"?>\n');
            fprintf(fid, '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" ');
            fprintf(fid, '"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n');
            fprintf(fid, sprintf('<svg viewBox="0 0 %g %g" ', size(m,1)*px_size, size(m,2)*px_size));
            fprintf(fid, 'xmlns="http://www.w3.org/2000/svg" version="1.1" ');
            fprintf(fid, 'xmlns:xlink="http://www.w3.org/1999/xlink">\n');
            fprintf(fid, '<rect x="0" y="0" width="%g" height="%g" fill="rgb(255, 255, 255)"/>\n', (size(m,1)-1)*px_size, (size(m, 2)-1)*px_size);
            fprintf(fid, sprintf("<!--\nmax: %.3f\n-->\n", max_val));
            fprintf(fid, '<g>\n');

            for i = 1:size(m, 2)
                for j=1:size(m, 1)
                    if ~all(m(i,j,:) == 0) && all(~isnan(m(i,j,:)))
                        fprintf(fid, '<rect x="%g" y="%g" width="%g" height="%g" ', ...
                            (i-1)*px_size, (size(m,2) - j)*px_size, px_size, px_size);
                        fprintf(fid, 'fill="rgb(%g,%g,%g)"/>\n', m(i,j,:) .* 255);
                    end
                end
            end
            fclose(fid);
        end

        function res = ta_MSD_tab(tab)
            idxs = unique(tab(:,1))';
            res = cell(length(idxs), 1);
            
            for k=1:length(idxs)
                t = tab(tab(:,1) == idxs(k), :);

                res{k} = cell(size(t, 1) - 1, 1);
                for tau=1:size(t, 1)-1
                    for j=1:(size(t, 1)-1-tau)
                        res{k}{tau} = [res{k}{tau}; sum((t(j+tau, 3:4) - t(j, 3:4)).^2, 2)];
                    end
                end
            end
        end
        
        function res = SD_tab_1D(tab_1D)
            idxs = unique(tab_1D(:,1))';
            res = cell(length(idxs), 1);
            
            for k=1:length(idxs)
                t = tab_1D(tab_1D(:,1) == idxs(k), :);

                res{k} = zeros(size(t, 1), 1);
                for j=2:size(t, 1)
                    res{k}(j) = (t(j,3) - t(1, 3)).^2;
                end
            end
        end
        
        function res = ta_MSD_tab_1D(tab_1D)
            idxs = unique(tab_1D(:,1))';
            res = cell(length(idxs), 1);
            
            for k=1:length(idxs)
                t = tab_1D(tab_1D(:,1) == idxs(k), :);

                res{k} = cell(size(t, 1) - 1, 1);
                for tau=1:size(t, 1)-1
                    for j=1:(size(t, 1)-1-tau)
                        res{k}{tau} = [res{k}{tau}; (t(j+tau, 3) - t(j, 3)).^2];
                    end
                end
            end
        end

%         function Ds = diff_ta_MSD(taMSD, fit_N, DT)
%             Ds = [];
%             for u=1:length(taMSD)
%                 xs = (0:length(taMSD{u})) * DT;
%                 ys = cellfun(@(x) mean(x), taMSD{u});
%                 filt = cellfun(@(x) length(x) >= 3, taMSD{u});
%                 ys(~filt) = nan;

%                 xs = xs(~isnan(ys));
%                 ys = ys(~isnan(ys));
% 
%                 if length(ys) < fit_N
%                     continue
%                 end

%                 warning('off')
%                 [fi, gof] = fit(xs(1:fit_N)', ys(1:fit_N), 'poly1');
%                 warning('on')
%                 Ds = [Ds fi.p1/4];
%             end
%         end

        function Ds = compute_ta_MSD_D(taMSDs, min_size, fit_N, DT)
            Ds = [];
            for u=1:length(taMSDs)
                xs = (0:length(taMSDs{u})) * DT;
                ys = cellfun(@(x) mean(x), taMSDs{u});
                filt = cellfun(@(x) length(x) >= min_size, taMSDs{u});
                ys(~filt) = nan;

                xs = xs(~isnan(ys));
                ys = ys(~isnan(ys));

                if length(ys) < fit_N
                    continue
                end

                warning('off')
                [fi, gof] = fit(xs(3:fit_N)', ys(3:fit_N), 'a*x');
                warning('on')
                Ds = [Ds; fi.a/4];
            end
        end

        function [idxs, Ds, alphas] = compute_ta_MSD_general(taMSDs, min_size, fit_N, DT)
            idxs = [];
            Ds = [];
            alphas = [];
            for u=1:length(taMSDs)
                xs = (0:length(taMSDs{u})) * DT;
                ys = cellfun(@(x) mean(x), taMSDs{u});
                filt = cellfun(@(x) length(x) >= min_size, taMSDs{u});
                ys(~filt) = nan;

                xs = xs(~isnan(ys));
                ys = ys(~isnan(ys));

                if length(ys) < fit_N
                    continue
                end
                
                assert(all(~isnan(xs)) & all(~isnan(ys)))
                
                if any(xs(2:fit_N) == 0) || any(ys(2:fit_N) == 0)
                    continue
                end

                warning('off')
                [fi, gof] = fit(log(xs(3:fit_N))', log(ys(3:fit_N)), 'poly1', 'Lower', [0 0], 'Upper', [2, inf]);
                warning('on')
                idxs = [idxs; u];
                Ds = [Ds; exp(fi.p2/4)];
                alphas = [alphas; fi.p1];
            end
        end

        function sds = ensemble_MSD(tab)
            sds = {};
            sds{1} = [0];
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);

                for j=2:size(tr, 1)
                    if j > length(sds)
                        sds{j} = [];
                    end
                    sds{j} = [sds{j} sum((tr(j,3:4) - tr(1,3:4)).^2)];
                end
            end
        end

        function disps = displacements_tr(tr)
            disps = sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2))';
        end

        function disps = displacements(tab)
            disps = [];
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                disps = [disps sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2))'];
            end
        end

        function disps = displacements_trajs(tab)
            disps = {};
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                disps = [disps ;sqrt(sum((tr(2:end, 3:4) - tr(1:(end-1), 3:4)).^2, 2))'];
            end
        end
        
        function D = disp_max_D(disps, DT, bins, smooth_pts)
            [o,b] = hist(disps, bins);
            sdisps = smooth(o, smooth_pts);
            [no, I] = max(sdisps);
            D = b(I)^2 / DT / 2;
        end

        function Ds = disp_max_D_distrib_bootstrap(disps, DT, bins, max_Nreps)
            N = ceil(length(disps) / 10);
            Ds = zeros(max_Nreps, 1) * nan;
            for k=1:max_Nreps
                idxs = randperm(length(disps));
                idxs = idxs(1:N);
                [o,b] = hist(disps(idxs), bins);
                [no, I] = max(o);
                Ds(k) = b(I)^2 / DT / 2;
            end
        end

        function D_est = disp_D_fit_peak(Ds, DT, b, o)
            [no, I_max] = max(o);
            best_I = 1;
            best_D = nan;
            for D=Ds
                f = sqrt(D * DT * 2);
                rpd = raylpdf(b * DT, f);
                [v, I] = max(rpd);
                if (abs(b(I) - b(I_max)) < abs(b(best_I) - b(I_max)))
                    best_I = I;
                    best_D = D;
                end
            end
            D_est = best_D;            
        end

        function res = mymax(l)
            if isempty(l)
                res = nan;
            else
                res = max(l);
            end
        end
        
        function res = generate_brownian_motion(Ntrajs, Npts, D, dt, Nsampling)
            res = [];
            for k=1:Ntrajs
                X = rand(1,2);
                res = [res; k 0 X];
                for l=1:(Npts*Nsampling)
                    X = X + sqrt(2*D*dt) * randn(1,2);
                    if mod(l, Nsampling) == 0
                        res = [res; k l*dt X];
                    end
                end
            end
        end
        
        function res = match_pts_ensembles(tab1, tab2, deps)
            res = [];
            for i=1:size(tab1, 1)
                idxs = find(abs(tab2(:,2) - tab1(i,2)) < 1e-4);
                dists = sqrt(sum((tab1(i,3:4) - tab2(idxs,3:4)).^2, 2));
                
                [vmin, I] = min(dists);
                if vmin < deps
                    res = [res; i idxs(I)];
                end
            end
        end
        
        function [res_fit, res_gof, res_cint, res_BIC] = best_fit_diff(b, o, Nrep, dt)
            res_fit = [];
            res_gof = {};
            
            mypdf = @(bins, sd) raylpdf(bins, sd) / sum(raylpdf(bins, sd));
            BIC_f = @(p, n, RSS) log(n) * (p + 1) + n * (log(2 * pi * RSS / n) + 1);
            
            method = 'LAR';
            cnt = 0;
            while isempty(res_gof) || res_gof.adjrsquare < 0
                if cnt >= 5 && strcmp(method, 'LAR')
                    method = 'bisquare';
                    cnt = 0;
                elseif cnt >= 5 && strcmp(method, 'bisquare')
                    assert(false);
                end
                
                k = 0;
                while k < Nrep
                    x0 = rand + 0.001;
                    
                    [f, gof] = fit(b', o' / sum(o), @(sd, x) mypdf(x, sd), 'Robust', method, 'Lower', 0.0000001, 'Upper', 1, 'StartPoint', x0);
                    
                    if isempty(res_gof) || res_gof.adjrsquare < gof.adjrsquare && gof.adjrsquare < 1.1
                        myfit = struct();
                        myfit.f = f;
                        myfit.D = f.sd^2 / dt / 2;
                        res_fit = myfit;
                        res_gof = gof;
                        res_cint = confint(res_fit.f);
                    end
                    
                    k = k + 1;
                end
                cnt = cnt + 1;
            end
            
            res_BIC = BIC_f(1, length(o), sum(((o / sum(o))- mypdf(b, res_fit.f.sd)).^2));
        end

        function res = cmp_trajs(tr1, tr2, dmax)
            Nmin = min(size(tr1, 1), size(tr2, 1));
            Nmax = max(size(tr1, 1), size(tr2, 1));
            sq_dists = sum((tr1(1:Nmin,3:4) - tr2(1:Nmin,3:4)).^2, 2);
            res = (sum(sq_dists < dmax^2) + (Nmax - Nmin)) / Nmax;
        end

        function res = filter_gap_trajectories(tab, DT)
            res = [];
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                if all(round((tr(2:end,2) - tr(1:(end-1), 2)) / DT) == 1)
                    res = [res; tr];
                else
                    display(sprintf('traj %d has at least 1 gap', i));
                end
            end
        end

        function [res, cnt_ambig, ambig_pos, ambig_idxs, tab_succ] = ambiguities_per_traj(tab, spts, dist, tidx)
            res = zeros(length(unique(tab(:,1))), 1);
            cnt_ambig = 0;
            ambig_pos = [];
            ambig_idxs = [];
            tab_succ = zeros(size(tab,1), 1);
            k = 1;
            l = 0;
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);
                tmp = 0;
                for j=1:(size(tr, 1) - 1)
                    l = l + 1;

                    idxs = [];
                    for u=(tr(j,tidx)+1):tr(j+1,tidx)
                        idxs = [idxs; find(spts(:,1) == u)];
                    end
                    %assert(length(idxs) > 0)
                    if length(idxs) == 0
                        display(sprintf('displacement with no successor: %d, %d', i, j));
                        continue
                    end
                    cnt = sum(sum(([spts(idxs, 2) - tr(j,3) spts(idxs, 3) - tr(j, 4)]).^2, 2) <= dist^2) - 1;

                    tab_succ(l) = cnt;
                    tmp = tmp + cnt;
                    if cnt >= 1
                        cnt_ambig = cnt_ambig + 1;
                        ambig_pos = [ambig_pos; tr(j, 3:4)];
                        ambig_idxs = [ambig_idxs; i j];
                    end
                end

                res(k) = tmp;
                k = k + 1;
                l = l + 1;
            end
        end

        function res = make_unambiguous_trajectories(tab, spts, dist)
            res = [];
            i2 = 0;
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, :);

                start_idx = 1;
                for j=1:(size(tr, 1) - 1)
                    idxs = find(spts(:,1) == (tr(j, 2) + 1));
                    assert(length(idxs) > 0)
                    if sum(sum(([spts(idxs, 2) - tr(j,3) spts(idxs, 3) - tr(j, 4)]).^2, 2) < dist^2) > 1 %at least 1 ambiguity
                        res = [res; i2 * ones(j - start_idx + 1, 1) tr(start_idx:j, 2:4)];
                        i2 = i2 + 1;
                        start_idx = j + 1;
                    end
                end

                res = [res; i2 * ones(size(tr,1) - start_idx + 1, 1) tr(start_idx:size(tr,1), 2:4)];
                i2 = i2 + 1;
            end
        end
        
        function ell = MinVolEllipse(P, tolerance)
            % from: Nima Moshtagh (nima@seas.upenn.edu)

            %%%%%%%%%%%%%%%%%%%%% Solving the Dual problem%%%%%%%%%%%%%%%%%%%%%%%%%%%5
            % data points 
            [d N] = size(P);

            Q = zeros(d+1,N);
            Q(1:d,:) = P(1:d,1:N);
            Q(d+1,:) = ones(1,N);


            % initializations
            count = 1;
            err = 1;
            u = (1/N) * ones(N,1);          % 1st iteration


            % Khachiyan Algorithm
            while err > tolerance,
                X = Q * diag(u) * Q';       % X = \sum_i ( u_i * q_i * q_i')  is a (d+1)x(d+1) matrix
                M = diag(Q' * inv(X) * Q);  % M the diagonal vector of an NxN matrix
                [maximum j] = max(M);
                step_size = (maximum - d -1)/((d+1)*(maximum-1));
                new_u = (1 - step_size)*u ;
                new_u(j) = new_u(j) + step_size;
                count = count + 1;
                err = norm(new_u - u);
                u = new_u;
            end



            %%%%%%%%%%%%%%%%%%% Computing the Ellipse parameters%%%%%%%%%%%%%%%%%%%%%%
            % Finds the ellipse equation in the 'center form': 
            % (x-c)' * A * (x-c) = 1
            % It computes a dxd matrix 'A' and a d dimensional vector 'c' as the center
            % of the ellipse. 

            U = diag(u);

            % the A matrix for the ellipse
            A = (1/d) * inv(P * U * P' - (P * u)*(P*u)' );


            % center of the ellipse 
            c = P * u;

            [U, S] = svd(A);
            if U(1,1) < 0
                U = -U;
            end
            a = 1/sqrt(S(1,1));
            b = 1/sqrt(S(2,2));
            phi = atan2(U(2,1), U(1,1));
            ell = [c' a b phi];
        end

        function [z, a, b, alpha, err] = fitellipse(x, varargin)
            %FITELLIPSE   least squares fit of ellipse to 2D data
            %
            %   [Z, A, B, ALPHA] = FITELLIPSE(X)
            %       Fit an ellipse to the 2D points in the 2xN array X. The ellipse is
            %       returned in parametric form such that the equation of the ellipse
            %       parameterised by 0 <= theta < 2*pi is:
            %           X = Z + Q(ALPHA) * [A * cos(theta); B * sin(theta)]
            %       where Q(ALPHA) is the rotation matrix
            %           Q(ALPHA) = [cos(ALPHA), -sin(ALPHA); 
            %                       sin(ALPHA), cos(ALPHA)]
            %
            %       Fitting is performed by nonlinear least squares, optimising the
            %       squared sum of orthogonal distances from the points to the fitted
            %       ellipse. The initial guess is calculated by a linear least squares
            %       routine, by default using the Bookstein constraint (see below)
            %
            %   [...]            = FITELLIPSE(X, 'linear')
            %       Fit an ellipse using linear least squares. The conic to be fitted
            %       is of the form
            %           x'Ax + b'x + c = 0
            %       and the algebraic error is minimised by least squares with the
            %       Bookstein constraint (lambda_1^2 + lambda_2^2 = 1, where 
            %       lambda_i are the eigenvalues of A)
            %
            %   [...]            = FITELLIPSE(..., 'Property', 'value', ...)
            %       Specify property/value pairs to change problem parameters
            %          Property                  Values
            %          =================================
            %          'constraint'              {|'bookstein'|, 'trace'}
            %                                    For the linear fit, the following
            %                                    quadratic form is considered
            %                                    x'Ax + b'x + c = 0. Different
            %                                    constraints on the parameters yield
            %                                    different fits. Both 'bookstein' and
            %                                    'trace' are Euclidean-invariant
            %                                    constraints on the eigenvalues of A,
            %                                    meaning the fit will be invariant
            %                                    under Euclidean transformations
            %                                    'bookstein': lambda1^2 + lambda2^2 = 1
            %                                    'trace'    : lambda1 + lambda2     = 1
            %
            %           Nonlinear Fit Property   Values
            %           ===============================
            %           'maxits'                 positive integer, default 200
            %                                    Maximum number of iterations for the
            %                                    Gauss Newton step
            %
            %           'tol'                    positive real, default 1e-5
            %                                    Relative step size tolerance
            %   Example:
            %       % A set of points
            %       x = [1 2 5 7 9 6 3 8; 
            %            7 6 8 7 5 7 2 4];
            % 
            %       % Fit an ellipse using the Bookstein constraint
            %       [zb, ab, bb, alphab] = fitellipse(x, 'linear');
            %
            %       % Find the least squares geometric estimate       
            %       [zg, ag, bg, alphag] = fitellipse(x);
            %       
            %       % Plot the results
            %       plot(x(1,:), x(2,:), 'ro')
            %       hold on
            %       % plotellipse(zb, ab, bb, alphab, 'b--')
            %       % plotellipse(zg, ag, bg, alphag, 'k')
            % 
            %   See also PLOTELLIPSE

            % Copyright Richard Brown, this code can be freely used and modified so
            % long as this line is retained
            function [x, params] = parseinputs(x, params, varargin)
                % PARSEINPUTS put x in the correct form, and parse user parameters

                % CHECK x
                % Make sure x is 2xN where N > 3
                if size(x, 2) == 2
                    x = x'; 
                end
                if size(x, 1) ~= 2
                    error('fitellipse:InvalidDimension', ...
                        'Input matrix must be two dimensional')
                end
                if size(x, 2) < 6
                    error('fitellipse:InsufficientPoints', ...
                        'At least 6 points required to compute fit')
                end


                % Determine whether we are solving for geometric (nonlinear) or algebraic
                % (linear) distance
                if ~isempty(varargin) && strncmpi(varargin{1}, 'linear', length(varargin{1}))
                    params.fNonlinear = false;
                    varargin(1)       = [];
                else
                    params.fNonlinear = true;
                end

                % Parse property/value pairs
                if rem(length(varargin), 2) ~= 0
                    error('fitellipse:InvalidInputArguments', ...
                        'Additional arguments must take the form of Property/Value pairs')
                end

                % Cell array of valid property names
                properties = {'constraint', 'maxits', 'tol'};

                while length(varargin) ~= 0
                    % Pop pair off varargin
                    property      = varargin{1};
                    value         = varargin{2};
                    varargin(1:2) = [];

                    % If the property has been supplied in a shortened form, lengthen it
                    iProperty = find(strncmpi(property, properties, length(property)));
                    if isempty(iProperty)
                        error('fitellipse:UnknownProperty', 'Unknown Property');
                    elseif length(iProperty) > 1
                        error('fitellipse:AmbiguousProperty', ...
                            'Supplied shortened property name is ambiguous');
                    end

                    % Expand property to its full name
                    property = properties{iProperty};

                    % Check for irrelevant property
                    if ~params.fNonlinear && ismember(property, {'maxits', 'tol'})
                        warning('fitellipse:IrrelevantProperty', ...
                            'Supplied property has no effect on linear estimate, ignoring');
                        continue
                    end

                    % Check supplied property value
                    switch property
                        case 'maxits'
                            if ~isnumeric(value) || value <= 0
                                error('fitcircle:InvalidMaxits', ...
                                    'maxits must be an integer greater than 0')
                            end
                            params.maxits = value;
                        case 'tol'
                            if ~isnumeric(value) || value <= 0
                                error('fitcircle:InvalidTol', ...
                                    'tol must be a positive real number')
                            end
                            params.tol = value;
                        case 'constraint'
                            switch lower(value)
                                case 'bookstein'
                                    params.constraint = 'bookstein';
                                case 'trace'
                                    params.constraint = 'trace';
                                otherwise
                                    error('fitellipse:InvalidConstraint', ...
                                        'Invalid constraint specified')
                            end
                    end % switch property
                end % while
            end

            function [z, a, b, alpha] = fitbookstein(x)
                %FITBOOKSTEIN   Linear ellipse fit using bookstein constraint
                %   lambda_1^2 + lambda_2^2 = 1, where lambda_i are the eigenvalues of A

                % Convenience variables
                m  = size(x, 2);
                x1 = x(1, :)';
                x2 = x(2, :)';

                % Define the coefficient matrix B, such that we solve the system
                % B *[v; w] = 0, with the constraint norm(w) == 1
                B = [x1, x2, ones(m, 1), x1.^2, sqrt(2) * x1 .* x2, x2.^2];

                % To enforce the constraint, we need to take the QR decomposition
                [Q, R] = qr(B);

                % Decompose R into blocks
                R11 = R(1:3, 1:3);
                R12 = R(1:3, 4:6);
                R22 = R(4:6, 4:6);

                % Solve R22 * w = 0 subject to norm(w) == 1
                [U, S, V] = svd(R22);
                w = V(:, 3);

                % Solve for the remaining variables
                v = -R11 \ R12 * w;

                % Fill in the quadratic form
                A        = zeros(2);
                A(1)     = w(1);
                A([2 3]) = 1 / sqrt(2) * w(2);
                A(4)     = w(3);
                bv       = v(1:2);
                c        = v(3);

                % Find the parameters
                [z, a, b, alpha] = conic2parametric(A, bv, c);


                function [z, a, b, alpha] = fitggk(x)
                    % Linear least squares with the Euclidean-invariant constraint Trace(A) = 1

                    % Convenience variables
                    m  = size(x, 2);
                    x1 = x(1, :)';
                    x2 = x(2, :)';

                    % Coefficient matrix
                    B = [2 * x1 .* x2, x2.^2 - x1.^2, x1, x2, ones(m, 1)];

                    v = B \ -x1.^2;

                    % For clarity, fill in the quadratic form variables
                    A        = zeros(2);
                    A(1,1)   = 1 - v(2);
                    A([2 3]) = v(1);
                    A(2,2)   = v(2);
                    bv       = v(3:4);
                    c        = v(5);

                    % find parameters
                    [z, a, b, alpha] = conic2parametric(A, bv, c);
                end



                function [z, a, b, alpha, fConverged] = fitnonlinear(x, z0, a0, b0, alpha0, params)
                    % Gauss-Newton least squares ellipse fit minimising geometric distance 

                    % Get initial rotation matrix
                    Q0 = [cos(alpha0), -sin(alpha0); sin(alpha0) cos(alpha0)];
                    m = size(x, 2);

                    % Get initial phase estimates
                    phi0 = angle( [1 i] * Q0' * (x - repmat(z0, 1, m)) )';
                    u = [phi0; alpha0; a0; b0; z0];

                    % Iterate using Gauss Newton
                    fConverged = false;
                    for nIts = 1:params.maxits
                        % Find the function and Jacobian
                        [f, J] = sys(u);

                        % Solve for the step and update u
                        h = -J \ f;
                        u = u + h;

                        % Check for convergence
                        delta = norm(h, inf) / norm(u, inf);
                        if delta < params.tol
                            fConverged = true;
                            break
                        end
                    end

                    alpha = u(end-4);
                    a     = u(end-3);
                    b     = u(end-2);
                    z     = u(end-1:end);


                    function [f, J] = sys(u)
                        % SYS : Define the system of nonlinear equations and Jacobian. Nested
                        % function accesses X (but changeth it not)
                        % from the FITELLIPSE workspace

                        % Tolerance for whether it is a circle
                        circTol = 1e-5;

                        % Unpack parameters from u
                        phi   = u(1:end-5);
                        alpha = u(end-4);
                        a     = u(end-3);
                        b     = u(end-2);
                        z     = u(end-1:end);

                        % If it is a circle, the Jacobian will be singular, and the
                        % Gauss-Newton step won't work. 
                        %TODO: This can be fixed by switching to a Levenberg-Marquardt
                        %solver
                        if abs(a - b) / (a + b) < circTol
                            warning('fitellipse:CircleFound', ...
                                'Ellipse is near-circular - nonlinear fit may not succeed')
                        end

                        % Convenience trig variables
                        c = cos(phi);
                        s = sin(phi);
                        ca = cos(alpha);
                        sa = sin(alpha);

                        % Rotation matrices
                        Q    = [ca, -sa; sa, ca];
                        Qdot = [-sa, -ca; ca, -sa];

                        % Preallocate function and Jacobian variables
                        f = zeros(2 * m, 1);
                        J = zeros(2 * m, m + 5);
                        for i = 1:m
                            rows = (2*i-1):(2*i);
                            % Equation system - vector difference between point on ellipse
                            % and data point
                            f((2*i-1):(2*i)) = x(:, i) - z - Q * [a * cos(phi(i)); b * sin(phi(i))];

                            % Jacobian
                            J(rows, i) = -Q * [-a * s(i); b * c(i)];
                            J(rows, (end-4:end)) = ...
                                [-Qdot*[a*c(i); b*s(i)], -Q*[c(i); 0], -Q*[0; s(i)], [-1 0; 0 -1]];
                        end
                    end
                end % fitnonlinear



                function [z, a, b, alpha] = conic2parametric(A, bv, c)
                    % Diagonalise A - find Q, D such at A = Q' * D * Q
                    [Q, D] = eig(A);
                    Q = Q';

                    % If the determinant < 0, it's not an ellipse
                    if prod(diag(D)) <= 0 
                        error('fitellipse:NotEllipse', 'Linear fit did not produce an ellipse');
                    end

                    % We have b_h' = 2 * t' * A + b'
                    t = -0.5 * (A \ bv);

                    c_h = t' * A * t + bv' * t + c;

                    z = t;
                    a = sqrt(-c_h / D(1,1));
                    b = sqrt(-c_h / D(2,2));
                    alpha = atan2(Q(1,2), Q(1,1));
                end % conic2parametric  
            end

            error(nargchk(1, 5, nargin, 'struct'))

            % Default parameters
            params.fNonlinear = true;
            params.constraint = 'bookstein';
            params.maxits     = 200;
            params.tol        = 1e-5;

            % Parse inputs
            [x, params] = parseinputs(x, params, varargin{:});

            % Constraints are Euclidean-invariant, so improve conditioning by removing
            % centroid
            centroid = mean(x, 2);
            x        = x - repmat(centroid, 1, size(x, 2));

            % Obtain a linear estimate
            switch params.constraint
                % Bookstein constraint : lambda_1^2 + lambda_2^2 = 1
                case 'bookstein'
                    [z, a, b, alpha] = fitbookstein(x);

                % 'trace' constraint, lambda1 + lambda2 = trace(A) = 1
                case 'trace'
                    [z, a, b, alpha] = fitggk(x);
            end % switch

            % Minimise geometric error using nonlinear least squares if required
            if params.fNonlinear
                % Initial conditions
                z0     = z;
                a0     = a;
                b0     = b;
                alpha0 = alpha;

                % Apply the fit
                [z, a, b, alpha, fConverged] = ...
                    fitnonlinear(x, z0, a0, b0, alpha0, params);

                % Return linear estimate if GN doesn't converge
                if ~fConverged
                    warning('fitellipse:FailureToConverge', ...'
                        'Gauss-Newton did not converge, returning linear estimate');
                    z = z0;
                    a = a0;
                    b = b0;
                    alpha = alpha0;
                end
            end

            % Add the centroid back on
            z = z + centroid;
        end
    
        function [proj_tab, tab_1D] = project_trajs(tab, p1, p2)
            proj_tab = [];
            tab_1D = [];
            L = p2 - p1;
            for u=unique(tab(:,1))'
                tr = tab(tab(:,1) == u, :);

                for j=1:size(tr,1)
                    pt = tr(j,3:4) - p1;
                    pts = p1 + ((pt(1) * L(1) + pt(2) * L(2)) / (L(1) * L(1) + L(2) * L(2))) * L;
                    proj_tab = [proj_tab; tr(j, 1:2) pts];
                    tab_1D = [tab_1D; tr(j, 1:2) sqrt(sum((pts - p1).^2))];
                end
            end
        end
        
        function [same_dir, dist_same_dir, tr_dirs] = same_dir_1D(tab_1D, min_d)
            same_dir = [];
            dist_same_dir = [];
            tr_dirs = cell(length(unique(tab_1D(:,1))), 1);
            cpt = 0;
            for k=unique(tab_1D(:,1))'
                cpt = cpt + 1;
                tr = tab_1D(tab_1D(:,1) == k, :);
                sup = 1;
                strk = 0;
                stoped = 0;
                tr_dirs{cpt} = [];
                for j=2:size(tr,1)
                    if abs(tr(j,3) - tr(j-1,3)) <= min_d
                        strk = strk + 1;
                        if ~stoped && strk > 0
                            tr_dirs{cpt} = [tr_dirs{cpt}; sup];
                        end
                        stoped = 1;
                        continue
                    end
                    stoped = 0;

                    if tr(j,3) > tr(j-1, 3)
                        if sup == 1
                            strk = strk + 1;
                        else
                            if strk > 0
                                dist_same_dir = [dist_same_dir abs(tab_1D(j, 3) - tab_1D(j-strk, 3))];
                            end
                            same_dir = [same_dir; strk];
                            strk = 0;
                            sup = 1;
                        end
                    else
                        if sup == -1
                            strk = strk + 1;
                        else
                            if strk > 0
                                dist_same_dir = [dist_same_dir abs(tab_1D(j, 3) - tab_1D(j-strk, 3))];
                            end
                            same_dir = [same_dir; strk];
                            strk = 0;
                            sup = -1;
                        end
                    end
                end
                if strk > 0
                    tr_dirs{cpt} = [tr_dirs{cpt}; sup];
                end
            end
        end

        function res = spot_density(tab)
            res = arrayfun(@(t) sum(tab(:,2) == t), unique(tab(:,2)));
        end

        function res = dist_same_frame(tab)
            frames = unique(tab(:,2));
            res = cell(length(frames), 1);

            for k=1:length(frames)
                spts = tab(tab(:,2) == frames(k), :);
                for j=1:size(spts, 1)
                    res{k} = [res{k} sqrt(sum((spts(j, 3:4) - spts((j+1):end, 3:4)).^2, 2))'];
                end
            end
        end

        function res = closest_dist_same_frame(tab)
            frames = unique(tab(:,2));
            res = cell(length(frames), 1);

            for k=1:length(frames)
                spts = tab(tab(:,2) == frames(k), :);
                for j=1:size(spts, 1)
                    res{k} = [res{k} min(sqrt(sum((spts(j, 3:4) - spts([1:(j-1) (j+1):end], 3:4)).^2, 2)))'];
                end
            end
        end

        function res = dist_next_frame(tab)
            frames = unique(tab(:,2));
            res = cell(length(frames));

            for k=1:(length(frames)-1)
                spts1 = tab(tab(:,2) == frames(k), :);
                spts2 = tab(tab(:,2) == frames(k+1), :);
                for j=1:size(spts1, 1)
                    res{k} = [res{k} sqrt(sum((spts1(j, 3:4) - spts2(:, 3:4)).^2, 2))'];
                end
            end
        end

        function res = closest_dist_next_frame(tab)
            frames = unique(tab(:,2));
            res = cell(length(frames));

            for k=1:(length(frames)-1)
                spts1 = tab(tab(:,2) == frames(k), :);
                spts2 = tab(tab(:,2) == frames(k+1), :);
                for j=1:size(spts1, 1)
                    res{k} = [res{k} min(sqrt(sum((spts1(j, 3:4) - spts2(:, 3:4)).^2, 2)))'];
                end
            end
        end

        function res = load_mask(fname)
            tiff_info = imfinfo(fname);
            res = zeros(size(tiff_info, 1), tiff_info(1).Width, tiff_info(1).Height);
            for i=1:size(tiff_info, 1)
                res(i,:,:) = imread(fname, i);
            end
        end

        function res = position_to_px(pxsize, p)
            res = [floor(single(p / pxsize))] + 1;
        end

        function [tracks_matched, truth_idxs] = match_trajectories(truth_dats, tracks_dats, d_th)
            ec = @(x,y) sqrt(sum((x - y).^2, 2));

            truth_idxs = unique(truth_dats(:,1))';
            tracks_matched = cell(length(unique(truth_dats(:,1))), 1);
            for i=1:length(truth_idxs)
                tr = truth_dats(truth_dats(:,1) == truth_idxs(i), :);

                track_idxs = [];
                for j=1:size(tr, 1)
                    tracks_pts = tracks_dats(tracks_dats(:,2) == tr(j,2), :);
                    tracks_pts = tracks_pts(ec(tr(j, 3:4), tracks_pts(:,3:4)) < d_th, :);

                    assert(size(tracks_pts, 1) < 2);
                    if size(tracks_pts, 1) == 1
                        track_idxs = [track_idxs; tracks_pts(1,1)];
                    else
                        track_idxs = [track_idxs; -1];
                    end
                end

                tracks_matched{i} = track_idxs;
            end
            assert(all(arrayfun(@(i) sum(truth_dats(:,1) == truth_idxs(i)) == length(tracks_matched{i}), 1:length(truth_idxs))));
        end

        function dens_r = density_ring(tab, cents, dr)
            dens_r = zeros(length(cents), 1);

            ds = sqrt(sum(tab(:,3:4).^2, 2));
            for k=1:length(cents)
                dens_r(k) = sum(ds >= cents(k) - dr/2 & ds <= cents(k) + dr/2);
            end
            dens_r = dens_r ./ (pi * ((cents' + dr/2).^2 - (cents' - dr/2).^2));
        end

        function parts = cut_traj(tr, N, ovlp)
            parts = {};
            i = 1;
            while i <= (size(tr,1)-N)
                parts{length(parts)+1} = tr(i:(i+N), :);
                if ovlp
                    i = i + 1;
                else
                    i = i + N;
                end
            end
        end

        function imap = spot_intensity_map(tab, gx, gy, npts_th)
            %consider intensity information is in column 5 of tab
            r = gx(2) - gx(1);
            imap = zeros(length(gx), length(gy));
            cpt = zeros(length(gx), length(gy));
            for i=1:length(tab)-1
                line = tab(i,:);
                x = floor(single((line(3)-gx(1)) / r)) + 1;
                y = floor(single((line(4)-gy(1)) / r)) + 1;

                imap(x,y) = imap(x,y) + line(5);
                cpt(x,y) = cpt(x,y) + 1;
            end

            imap(cpt < npts_th) = 0;
            imap = imap ./ cpt;
        end

        function tab_cut = cut_ambiguities(tab, ambig_idxs)
            tab_cut = [];
            midx = max(tab(:,1)) + 1;
            for i=unique(tab(:,1))'
                tr = tab(tab(:,1) == i, 1:4);

                if isempty(ambig_idxs)
                    tab_cut = [tab_cut; tr i * ones(size(tr,1), 1)];
                    continue
                end

                aidxs = ambig_idxs(ambig_idxs(:,1) == i, 2);
                if isempty(aidxs)
                    tab_cut = [tab_cut; tr i * ones(size(tr,1), 1)];
                else
                    sub_tr = [];
                    for j=1:size(tr,1)
                        if any(aidxs == j)
                            if ~isempty(sub_tr)
                                tab_cut = [tab_cut; [midx * ones(size(sub_tr,1), 1) sub_tr(:,2:end) i * ones(size(sub_tr, 1),1)]];
                                midx = midx + 1;
                                sub_tr = [];
                            end
                        else
                            sub_tr = [sub_tr; tr(j,:)];
                        end
                    end

                    if ~isempty(sub_tr)
                        tab_cut = [tab_cut; [midx * ones(size(sub_tr,1), 1) sub_tr(:,2:end) i * ones(size(sub_tr, 1),1)]];
                        midx = midx + 1;
                        sub_tr = [];
                    end
                end
            end
        end

        function [ambig_pos, ndisps] = ambiguities_graph_dist(spts, ambig_dat, tab, l)
            ec = @(p,q) sqrt(sum((p - q).^2, 2));

            ambig = cell(size(spts, 1), 1);
            u = 1;
            while u <= size(ambig_dat, 1)
                tmp = [];
                for v=1:ambig_dat(u,2)
                    tmp = [tmp; ambig_dat(u+v,:)];
                end
                tmp(:,1) = tmp(:,1) + 1;
                ambig{ambig_dat(u,1)+1} = tmp;
                u = u + ambig_dat(u,2) + 1;
            end

            ambig_pos = zeros(size(tab, 1), 2);
            ndisps = 0;
            for u=1:(size(tab,1)-1)
                if tab(u+1, 1) ~= tab(u,1)
                    continue
                end
                ndisps = ndisps + 1;

                p = tab(u,:);
                p_idx = find(ec(p(3:4), spts(:,2:3)) < 1e-7 & tab(u,2) == spts(:,1));
                assert(length(p_idx) == 1)
                succs = find(spts(:,1) == tab(u+1, 2));
                succs = succs(round(ec(p(3:4), spts(succs, 2:3)),4) < l);

                p_ambigs = ambig{p_idx};
                p_ambigs(:,2) = round(p_ambigs(:,2), 4);
                p_ambigs(:,3) = round(p_ambigs(:,3), 4);
                if isempty(p_ambigs)
                    continue
                end

                assert(all(succs == sort(p_ambigs(p_ambigs(:,2) < l,1))))

                n_de = max([sum(p_ambigs(:,2) < l) - 1, 0]);
                n_dg = max([sum(p_ambigs(:,3) < l) - 1, 0]);

                if n_de > 0 || n_dg > 0
                    ambig_pos(u,:) = [n_de, n_dg];
                end
            end
        end

        function res = show_3D_matrix(m, precision)
            res = '';
            for i=1:size(m, 3)
                for u=size(m, 1):-1:1
                    for v=1:size(m, 2)
                        res = append(res, sprintf(sprintf(' %%.%df', precision), m(u,v,i)));
                    end
                    res = append(res, newline);
                end
                res = append(res, newline, newline);
            end
        end

        function res = show_4D_matrix(m, precision)
            res = '';
            for j=1:size(m, 3)
                for i=1:size(m, 4)
                    for u=size(m, 1):-1:1
                        for v=1:size(m, 2)
                            res = append(res, sprintf(sprintf(' %%.%df', precision), m(u,v,j,i)));
                        end
                        res = append(res, newline);
                    end
                    res = append(res, newline, newline);
                end
                res = append(res, newline, newline, newline);
            end
        end
    end
end

