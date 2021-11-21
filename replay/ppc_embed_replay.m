

load('hist_cluster_gostright.mat');
load('hist_target_gostright.mat');


%replay

Cluster_list = [];
Target_list = [];



% max obj num 128
max_obj = 128;
curr_obj_list = cell(0);
curr_obj_list{1,1} = 0; % frame num
curr_obj_list{2,1} = 0; % obj num
for n = 1:max_obj
    curr_obj_list{2+n,1} = -1;  %invalid -1, inconfident 0, confident 1,
    curr_obj_list{2+n,2} = 0;  % lifetime
    curr_obj_list{2+n,3} = []; % center points xc, yc, w, h,
    curr_obj_list{2+n,4} = []; % cluster points x, y, hori, id
    curr_obj_list{2+n,5} = 0;  % 0 invalid, 1 active object or new object
    curr_obj_list{2+n,6} = 0;  % 0 no match, 1 matched obj    
    curr_obj_list{2+n,7} = 0;  % 0 moving obj, 1 static obj  
end

% memory for people counting 
live_people_list  = cell(0);
for n = 1:max_obj
    live_people_list{n,1} = -1;  %invalid -1, inconfident 0, confident 1,
    live_people_list{n,2} = 0;  % lifetime
    live_people_list{n,3} = []; % center points xc, yc, w, h,
    live_people_list{n,4} = []; % cluster points x, y, hori, id
    live_people_list{n,5} = 0;  % 0 invalid, 1 active object or new object
    live_people_list{n,6} = 0;  % 0 no match, 1 matched obj  
    live_people_list{n,7} = -1;  % ID #
    live_people_list{n,8} = -1;  % updated flag, 1 updated, 0 no show object
    live_people_list{n,9} = 0;  % silent time
end


% obj traces
obj_traces = []; % x,y
obj_traces_idx = 0;


target_hist = cell(0);
for n= 1:min(size(hist_cluster,1), size(hist_target,1))
    
    if n== 697
        n
    end
    Cluster_list = hist_cluster{n,1} ;
     % compare with embedded tracker
    Target_list = hist_target{n,1};
    show_all_targets_and_cluster(Target_list, Cluster_list);

    %pause(0.05)
    
    
    % do matlab tracking
    target_hist{1,1} = n;
    target_hist{1,2} = max(Cluster_list(:,5))+1;
    for idx_id = 0:max(Cluster_list(:,5))
        idx = find(Cluster_list(:,5)==idx_id );
        tmp_list = Cluster_list(:, [3 4 2 5]);
        tmp_list(:, 5) = n;
        target_hist{1,3+idx_id} = tmp_list;
    end
    % tracking obj
    curr_obj_list = tracking_all_clusters(curr_obj_list, target_hist, 1);
    % keep still obj        
    [curr_obj_list live_people_list] = keep_still_obj(curr_obj_list, live_people_list);
    % save obj traces    
    [obj_traces obj_traces_idx] = record_traces( curr_obj_list, obj_traces, obj_traces_idx);
    % show obj
    show_obj_cluster(target_hist, curr_obj_list, n, obj_traces, obj_traces_idx); 
    %F(n) = getframe(gcf) ;    

end

% only for avi
%record_frame(F);