function res = roger_250110()
    res = struct();
    res.name = 'roger_250110';
    res.pxsize = 0.159;
    res.data_dir = '/mnt/data2/SPT_method/roger/u2os_HaloKDEL';
    res.base_dir = '/mnt/data2/SPT_method/tracking_opti/roger/u2os_HaloKDEL';
    res.data = {'C1-241212_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_c8';
                'C1-241219_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c3';
                'C1-250110_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c11.nd2';
                'C1-250110_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c23.nd2';
                'C1-250110_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c30.nd2';
                'C1-250110_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c37.nd2';
                'C1-250110_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c39.nd2';
                'C1-250110_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c40.nd2';
                'C1-250110_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c42.nd2';
                'C1-250110_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c47.nd2';
                'C1-250110_U2OS_Tango1_mNG_SNAP_Sec61_Halo_KDEL_10nM_PAJF646_c48.nd2'};

    res.cat_idxs = [ones(length(res.data), 1)];
    res.cat_names = {''};

    res.cat_cols = [0 0 0];
    res.proc_dir = '/mnt/data2/SPT_method/analysis_opti/roger/u2os_HaloKDEL';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    %res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=0_rad=1.0_th=3.0.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks', 1, [1 5 3 4 6]);
end