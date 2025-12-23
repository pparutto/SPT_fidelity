function res = freespace_mixed_track(base_dir, reps)
    res = {freespace_mixed_100_0_track(base_dir, reps); freespace_mixed_75_25_track(base_dir, reps); freespace_mixed_50_50_track(base_dir, reps);...
           freespace_mixed_25_75_track(base_dir, reps); freespace_mixed_0_100_track(base_dir, reps)};
end