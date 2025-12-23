addpath('../')
addpath('../external')
addpath('../datasets')

%%%%%%%%%SIMU
%to_compute = [1 0];
% trackm_ps = generate_track_params('tracks', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});
% trackm_fbm_ps = generate_track_params('tracks', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});
% trackm_nn_ps = generate_track_params('tracks_nn', [1 5 3 4], {'dist'; 'distgap'; 'framegap'});
% trackm_fn_ps = generate_track_params('tracks_fn', [1 5 3 4], {'dist'});
% utrack_ps = generate_track_params('tracks_utrack', [1 2 3 4], {'dist'});

%datss = freespace_GT('../simu_raw/simu/freespace/', 1:5);
%datss = freespace_track('../simu_raw/simu/freespace/', 1:5, trackm_ps); %trackmate
%datss = freespace_track('../simu_raw/simu/freespace/', 1:5, trackm_nn_ps); %nearest neighb
%datss = freespace_track('../simu_raw/simu/freespace/', 1:5, trackm_fn_ps); %furthest neighb
%datss = freespace_track('../simu_raw/simu/freespace/', 1:5, utrack_ps); %utrack

%datss = freespace_fbm_GT('../simu_raw/simu/freespace_fbm2/density', 1:3, 0.25);
%datss = freespace_fbm_track('../simu_raw/simu/freespace_fbm2/density', 1:3, trackm_fbm_ps, 0.25);

%datss = freespace_fbm_GT('../simu_raw/simu/freespace_fbm2/density', 1:3, 0.75);
%datss = freespace_fbm_track('../simu_raw/simu/freespace_fbm2/density', 1:3, trackm_fbm_ps, 0.75);

%datss = freespace_mixed_GT('../simu_raw/simu/freespace_mixed', 1:3);
%datss = freespace_mixed_track('../simu_raw/simu/freespace_mixed', 1:3);

%datss = ER_GT('../simu_raw/simu/ER', 1:5);
%datss = ER_track('../simu_raw/simu/ER', 1:5); %trackmate
%datss = ER_track_struct('../simu_raw/simu/ER', 1:5);

%datss = mito_GT('../simu_raw/simu/mito', 1:5);
%datss = mito_track('../simu_raw/simu/mito', 1:5); %trackmate
%datss = mito_track_struct('../simu_raw/simu/mito', 1:5);

%datss = lines_GT('../simu_raw/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly.poly', 1:3);
%datss = lines_track('../simu_raw/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly.poly', 1:3);
%datss = lines_track_struct('../simu_raw/simu/lines/struct_line_dist=31_pxsize=0.024195525_poly.poly', 1:3);

%%%%FOR SIMULATIONS
%min_tr_lens = [0];

%%%%%%%%%DATA
% datss = {yutong_260124_dATL_235()};
% to_compute = [1 1];
% min_tr_lens = [15];

% datss = {ineuron_737_290124(); ineuron_737_290124_struct()};
%to_compute = [1 0];
% min_tr_lens = [5];

% datss = {mito_210311(); mito_210311_struct(); mito_210311_struct_first(); mito_210311_struct_last();
%          mito_210806_unt(); mito_210806_unt_struct(); mito_210806_unt_struct_first(); mito_210806_unt_struct_last()};
%to_compute = [1 0];
% min_tr_lens = [10];

% datss = {mem_210806(); mem_210806_struct(); mem_210806_struct_first(); mem_210806_struct_last()};
%to_compute = [1 0];
% min_tr_lens = [5];

% datss = {mem_210806_OA(); mem_210806_OA_nostruct()};
%to_compute = [1 0];
% min_tr_lens = [5];

% datss = {roger_250226(); roger_250226_struct()};
%to_compute = [1 0];
% min_tr_lens = [10];

% datss = {cos931_wt_bace1(); cos931_wt_bace1_struct()};
%to_compute = [1 0];
% min_tr_lens = [20];

% datss = {yutong_nb_418_716_2(); yutong_nb_418_716_717_APP(); yutong_nb_418_716_717_nb()};
%to_compute = [1 0];
% min_tr_lens = [5];

% datss = {yutong_nb_418_716_717_240123(); yutong_nb_418_716_717_240123_struct()};
% to_compute = [1 0];
% min_tr_lens = [10];


force = [0 0];

rev_order = 0;
idxs = 1:length(datss);
if rev_order
    idxs = length(datss):-1:1;
end

for k=idxs
    if to_compute(1)
        Pipeline.process_trajectories(datss{k}, datss{k}.constr, min_tr_lens, force(1), rev_order);
    end
    if to_compute(2)
        Pipeline.compute_ambiguities(datss{k}, force(2));
    end
end
