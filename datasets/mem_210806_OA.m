function res = mem_210806_OA()
    res = struct();
    res.name = 'mem_210806_OA';
    res.pxsize = 0.0967821;
    res.base_dir = '../analysis_data/tracking/Mem/210806_OA_wdur=201';
    res.data = {'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_BSA_002.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_BSA_003.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_BSA_004.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_BSA_005.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_BSA_006.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_BSA_007.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_BSA_008.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_1in5OA_001.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_1in5OA_003.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_1in5OA_004.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_1in5OA_005.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_1in5OA_006.czi.tif';
                'C1-210806_COS7_mEM-KDEL_Sec61-Halo-PA646_1in5OA_007.czi.tif'};
    res.cat_idxs = [ones(6,1); 2*ones(7,1)];
    res.cat_names = {'UNT'; 'OA'};
    res.cat_cols = [0 0 0; 1 0 0];
    res.proc_dir = '../analysis_data/analysis/Mem/210806_OA';
    res.traj_type = 'track';
    res.mask_img_format = '%s/C2-%s_avg17_Simple Segmentation_binary.tif';

    res.constr = struct();
    res.constr.mask = 1;

    res.params = {'mask'; 'dist'; 'distgap'; 'framegap'};
    res.spots_handler = TrackmateSpotsParser(res.base_dir, 'trackmate/spots_mask=1_rad=0.75_th=1.0.csv', {'th'});
    res.track_handler = TrackmateFileParser(res.base_dir, res.data, 'tracks_struct', 1, [1 5 3 4 6 11]);
end