classdef SimuFileParser < Parser
    properties
        base_dir;
        data;
        dist_same_as_distgap;
        simu_file;
        ambig_col = -1;
    end

    methods
        function obj = SimuFileParser(base_dir, data, dist_same_as_distgap, simu_file)
            obj.base_dir = base_dir;
            obj.data = data;
            obj.dist_same_as_distgap = dist_same_as_distgap;
            obj.simu_file = simu_file;
        end

        function res = find_spots(obj)
            assert(0);
        end

        function res = load_spots(obj)
            assert(0);
        end

        function res = find_tracks(obj, dat, constr)
            s = struct();
            s.file = sprintf('%s/%s/%s', obj.base_dir, dat, obj.simu_file);
            s.ps = {};
            res = {s};
        end

        function res = load_tracks(obj, f)
            res = dlmread(f, ',', 0, 0);
            res = res(:, [1 2 3 4]);
            res(:,2) = round(res(:,2), 6);
        end

        function res = combinatorial_params(obj, params)
            res = {};
            for k=1:length(params)
                if ~obj.dist_same_as_distgap || ~strcmp(params{k}, 'distgap')
                    res = [res; params{k}];
                end
            end
        end

        function str = track_params(obj, ps_val, ps_names)
            str_fmt = '%g';
            for k=2:length(ps_names)
                str_fmt = strcat(str_fmt, '_%g');
            end

            c = cell(length(ps_names), 1);
            for i=1:length(ps_names)
                if strcmp(ps_names{i}, 'distgap') && obj.dist_same_as_distgap
                    c{i} = getfield(ps_val, 'dist');
                else
                    c{i} = getfield(ps_val, ps_names{i});
                end
            end
            str = sprintf(str_fmt, c{:});
        end
    end
end