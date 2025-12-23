classdef SimuSpotsParser < Parser
    properties
        base_dir;
        fname;
        params;
        dt;
    end

    methods
        function obj = SimuSpotsParser(base_dir, fname, params, dt)
            obj.base_dir = base_dir;
            obj.fname = fname;
            obj.params = params;
            obj.dt = dt;
        end

        function res = find_spots(obj, dat, constr)
            s = struct();
            s.file = sprintf('%s/%s/%s', obj.base_dir, dat, obj.fname);
            s.ps = {};
            res = {s};
        end

        function str = spots_params(obj, ps_val, ps_names)
            str = '';
        end

        function res = load_spots(obj, f)
            res = csvread(f);
            res = res(:, [2 3 4]);
            res(:,1) = round(res(:,1), 6);
        end
    end
end