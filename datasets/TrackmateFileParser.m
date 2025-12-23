classdef TrackmateFileParser < Parser
    properties
        base_dir;
        data;
        prefix;
        dist_same_as_distgap;
        track_columns;
        skip_cols;
        ignore;
        ambig_col;
    end

    methods(Static)
    end

    methods
        function obj = TrackmateFileParser(base_dir, data, prefix, dist_same_as_distgap, track_columns)
            obj.base_dir = base_dir;
            obj.data = data;
            obj.prefix = prefix;
            obj.dist_same_as_distgap = dist_same_as_distgap;
            obj.track_columns = track_columns;
            obj.skip_cols = 0;
            obj.ignore = '';
            obj.ambig_col = -1;
        end

        function res = find_spots(obj)
            assert(0);
        end

        function res = load_spots(obj)
            assert(0);
        end

        function res = params_from_fname(obj, fname)
            res = struct();

            fname = fname((length(obj.prefix)+1):(length(fname) - length('.csv')));
            tmp = strsplit(fname, '_');
            for i=1:length(tmp)
                tmp2 = strsplit(tmp{i}, '=');
                if length(tmp2) < 2
                    continue;
                end

                if endsWith(tmp2{2}, '.csv')
                    tmp2{2} = tmp2{2}(1:(length(tmp2{2}) - length('.csv')));
                end

                res.(tmp2{1}) = str2num(tmp2{2});
            end
        end

        function res = find_tracks(obj, dat, constr)
            field_names = fieldnames(constr);
            res = {};

            sim_dirs = dir(sprintf('%s/%s', obj.base_dir, dat));

            for i=1:length(sim_dirs)
                if ~startsWith(sim_dirs(i).name, obj.prefix)
                    continue;
                end
                if ~isempty(obj.ignore)
                    skip = 0;
                    if iscell(obj.ignore)
                        for j=1:length(obj.ignore)
                            if ~isempty(strfind(sim_dirs(i).name, obj.ignore{j}))
                                skip = 1;
                                break
                            end
                        end
                    else
                        skip = ~isempty(strfind(sim_dirs(i).name, obj.ignore));
                    end

                    if skip
                        continue
                    end
                end

                dir_ps = obj.params_from_fname(sim_dirs(i).name);
                if Parser.matchCntrs(dir_ps, constr, {})
                    s = struct();
                    s.file = sprintf('%s/%s/%s', obj.base_dir, dat, sim_dirs(i).name);
                    s.ps = dir_ps;
                    res{length(res)+1} = s;
                end
            end
        end

        function res = load_tracks(obj, f)
            res = dlmread(f, ',', 1, obj.skip_cols);

            cols = obj.track_columns;
            if obj.ambig_col ~= -1
                cols = [cols obj.ambig_col];
            end

            res = res(:, cols); %[1 5 3 4]
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