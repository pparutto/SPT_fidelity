classdef Parser
    methods(Static)
        function ok = matchCntrs(ps, cntrs, not_cntrs)
            field_names = fieldnames(ps);
            i = 1;
            ok = 1;
            while ok && i <= length(field_names)
                if isfield(cntrs, field_names{i}) && isa(cntrs.(field_names{i}), 'double')
                    if abs(cntrs.(field_names{i}) - ps.(field_names{i})) > eps
                        ok = 0;
                    end
                elseif isfield(cntrs, field_names{i}) && obj.(field_names{i}) ~= cntrs.(field_names{i})
                    ok = 0;
                elseif isfield(not_cntrs, field_names{i}) && any(cellfun(@(s) strcmp(s, field_names{i}), not_cntrs))
                    ok = 0;
                end
                i = i + 1;
            end
        end

        function ps_vals = extract_params(dats, ps_names)
            ps_vals = struct();
            if isempty(dats)
                return;
            end

            for j=1:length(ps_names)
                ps_vals = setfield(ps_vals, ps_names{j}, getfield(dats{1}.ps, ps_names{j}));
            end
            for i=2:length(dats)
                for j=1:length(ps_names)
                    ps_vals = setfield(ps_vals, ps_names{j}, unique([getfield(ps_vals, ps_names{j}) getfield(dats{i}.ps, ps_names{j})]));
                end
            end
        end

        function res = struct_to_cell(s, ps_names)
            res = cell(length(ps_names), 1);
            for i=1:length(ps_names)
                res{i} = getfield(s, ps_names{i});
            end
        end

        function res = all_track_params(ps_val, ps_combs)
            combs = cartprod(Parser.struct_to_cell(ps_val, ps_combs));
            res = cell(size(combs, 1), 1);
            for k=1:size(combs, 1)
                s = struct();
                for l=1:length(ps_combs)
                    s = setfield(s, ps_combs{l}, combs(k,l));
                end
                res{k} = s;
            end
        end

        function ps_val = params_track(str)
            ps_val = cellfun(@(x) str2double(x), strsplit(str, '_'));
        end

        function res = params_track_struct(str, ps_names)
            ps_val = cellfun(@(x) str2double(x), strsplit(str, '_'));
            res = struct();
            for k=1:length(ps_names)
                res = setfield(res, ps_names{k}, ps_val(k));
            end
        end

        function res = params_from_fname(prefix, fname)
            res = struct();

            fname = fname((length(prefix)+1):(length(fname) - length('.csv')));
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
    end

    methods
        function res = find_spots(obj)
            assert(0);
        end

        function res = load_spots(obj)
            assert(0);
        end

        function res = find_tracks(obj, constr)
            assert(0);
        end

        function res = load_tracks(obj)
            assert(0);
        end

        function res = combinatorial_params(obj, ps)
            assert(0);
        end
    end
end