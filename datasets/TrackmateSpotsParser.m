classdef TrackmateSpotsParser < Parser
    properties
        base_dir;
        fname;
        params;
        dt;
        frameid;
    end

    methods
        function obj = TrackmateSpotsParser(base_dir, fname, params, frameid)
            obj.base_dir = base_dir;
            obj.fname = fname;
            obj.params = params;
            obj.dt = 1;
        end

        function res = find_spots(obj, dat, constr)
            s = struct();
            s.file = sprintf('%s/%s/%s', obj.base_dir, dat, obj.fname);
            s.ps = obj.params_from_fname('', obj.fname);
            res = {s};
        end

        function str = spots_params(obj, ps_val, ps_names)
            str_fmt = '%g';
            for k=2:length(ps_names)
                str_fmt = strcat(str_fmt, '_%g');
            end

            c = cell(length(ps_names), 1);
            for i=1:length(ps_names)
                c{i} = getfield(ps_val, ps_names{i});
            end
            str = sprintf(str_fmt, c{:});
        end

        function res = load_spots(obj, f)
            res = csvread(f, 1, 0);
            res = res(:, [4 2 3]);
        end
    end
end