function curr_obj_list = tracking_all_clusters(curr_obj_list, target_hist, frame_num)

% target_hist : input: cluster and points cloud in current frame
% curr_obj_list : output: tracked obj list

% improvement:
% 1. filter smooth
% 2. no show of point clouds for static object
% 3. traces for obj

% max obj num 128
max_obj = 128;

Threshold_Obj_Distance = 0.5;
alpha_beta_filter = 0.5; % 1 is very stable, 0 is very fluctuant

% cluster to obj
%loop for frame
n = frame_num;

% loop for clusters

% reset match flag of obj
for i = 1:max_obj
    curr_obj_list{2+i,6} = 0;  % 0 no match, 1 matched obj
end

for cluster = 0:target_hist{n,2}-1
    point_clouds = target_hist{n,3+cluster};
    %cluster size , xc, yc, azic, w,h
    target_hist{n,2+target_hist{n,2}+1+cluster} = mean(point_clouds(:,1:3));
    obj_w = max(point_clouds(:,1)) -min(point_clouds(:,1));
    obj_h = max(point_clouds(:,2)) -min(point_clouds(:,2));
    target_hist{n,2+target_hist{n,2}+1+cluster}(4) = obj_w;
    target_hist{n,2+target_hist{n,2}+1+cluster}(5) = obj_h;
    % reset match flag of cluster
    target_hist{n,2+target_hist{n,2}+1+cluster}(6) = 0;
    
    %xc = target_hist{n,2+target_hist{n,2}+1+cluster}(1);
    %yc = target_hist{n,2+target_hist{n,2}+1+cluster}(2);
end

% loop for all objects and match clusters
active_obj_idx = find(cat(1,curr_obj_list{3:130,5}) == 1);
leer_obj_idx = find(cat(1,curr_obj_list{3:130,5}) < 1);
new_obj_num = 0;
num_obj = size(active_obj_idx,1);
for obj_nr = 1:num_obj
    x_obj = curr_obj_list{2+active_obj_idx(obj_nr),3}(1);
    y_obj = curr_obj_list{2+active_obj_idx(obj_nr),3}(2);
    w_obj = curr_obj_list{2+active_obj_idx(obj_nr),3}(6);
    h_obj = curr_obj_list{2+active_obj_idx(obj_nr),3}(7);
    % loop for all clusters
    min_dist_cluster = 1000;
    nearest_obj_idx = -1;
    for cluster = 0:target_hist{n,2}-1
        point_clouds = target_hist{n,3+cluster};
        %cluster size , xc, yc, azic, w,h
        %target_hist{n,2+target_hist{n,2}+1+cluster} = mean(point_clouds(:,1:3));
        %obj_w = max(point_clouds(:,1)) -min(point_clouds(:,1));
        %obj_h = max(point_clouds(:,2)) -min(point_clouds(:,2));
        clu_w = target_hist{n,2+target_hist{n,2}+1+cluster}(4);
        clu_h = target_hist{n,2+target_hist{n,2}+1+cluster}(5);
        
        xc = target_hist{n,2+target_hist{n,2}+1+cluster}(1);
        yc = target_hist{n,2+target_hist{n,2}+1+cluster}(2);
        
        dist_obj_cluster = sqrt((xc - x_obj)^2 + (yc - y_obj)^2);
        dist_wh = sqrt((w_obj - clu_w)^2 + (h_obj - clu_h)^2);
        dist_cost = dist_obj_cluster*0.9 + dist_wh*0.1; 
        if min_dist_cluster > dist_cost
            % record min dist
            min_dist_cluster = dist_cost;
            nearest_obj_idx = cluster; %active_obj_idx(obj_nr);
        end
    end
    
    % delta_frame
    delta_frame = target_hist{n,3+nearest_obj_idx}(1,5)- curr_obj_list{2+active_obj_idx(obj_nr),4}(1,5);

    %target_hist{n,3+nearest_obj_idx}(1,5)
    num_pts_obj = size(curr_obj_list{2+active_obj_idx(obj_nr),4},1);
    num_pts_clu = size(target_hist{n,3+nearest_obj_idx},1);
    % overlap area
    xo_min = min(curr_obj_list{2+active_obj_idx(obj_nr),4}(:,1));
    xo_max = max(curr_obj_list{2+active_obj_idx(obj_nr),4}(:,1));
    yo_min = min(curr_obj_list{2+active_obj_idx(obj_nr),4}(:,2));
    yo_max = max(curr_obj_list{2+active_obj_idx(obj_nr),4}(:,2));
    xcl_min = min(target_hist{n,3+nearest_obj_idx}(:,1));    
    xcl_max = max(target_hist{n,3+nearest_obj_idx}(:,1));
    ycl_min = min(target_hist{n,3+nearest_obj_idx}(:,2));    
    ycl_max = max(target_hist{n,3+nearest_obj_idx}(:,2));
    
    if xo_min > xcl_max
        x_distance = xo_min - xcl_max;
    elseif  xo_max < xcl_min
        x_distance =  xcl_min - xo_max;
    else
        x_distance = 0;
    end
    
    if yo_min > ycl_max
        y_distance = yo_min - ycl_max;
    elseif  yo_max < ycl_min
        y_distance =  ycl_min - yo_max ;
    else
        y_distance = 0;
    end
    
    % frame is in missing case
    if (y_distance < 0.15) && (delta_frame >= 2)
        y_distance = 0;
    end
    if delta_frame > 3
        %delta_frame = 0
        % speical case the merging will become bigger.
        thres_dist_obj_clu = Threshold_Obj_Distance*1.5;
    else
        thres_dist_obj_clu = Threshold_Obj_Distance;
    end
    
    if (y_distance == 0) && (x_distance < thres_dist_obj_clu/2) && (min_dist_cluster < thres_dist_obj_clu)% && (abs(num_pts_obj - num_pts_clu) > num_pts_obj*0.5)
        % match and update obj
        %life time
        if delta_frame > 3
            delta_frame = 0;
        end
        curr_obj_list{2+active_obj_idx(obj_nr),2} = curr_obj_list{2+active_obj_idx(obj_nr),2} + delta_frame;
        if curr_obj_list{2+active_obj_idx(obj_nr),2} > 20
            curr_obj_list{2+active_obj_idx(obj_nr),2} = 20;
        end
        % inconfident
        if curr_obj_list{2+active_obj_idx(obj_nr),2} > 5
            curr_obj_list{2+active_obj_idx(obj_nr),1} = 1;
        end
        % center
        curr_obj_list{2+active_obj_idx(obj_nr),3} = alpha_beta_filter*curr_obj_list{2+active_obj_idx(obj_nr),3}(1:5) + (1-alpha_beta_filter)*mean(target_hist{n,3+nearest_obj_idx}(:,1:5));
        % do kalman filter
        
        % w,h
        curr_obj_list{2+active_obj_idx(obj_nr),3}(6) = target_hist{n,2+target_hist{n,2}+1+nearest_obj_idx}(4);
        curr_obj_list{2+active_obj_idx(obj_nr),3}(7) = target_hist{n,2+target_hist{n,2}+1+nearest_obj_idx}(5);
        curr_obj_list{2+active_obj_idx(obj_nr),4} = target_hist{n,3+nearest_obj_idx}(:,1:5);
        curr_obj_list{2+active_obj_idx(obj_nr),5} = 1;  % valid flag
        curr_obj_list{2+active_obj_idx(obj_nr),6} = 1;  % match flag
        curr_obj_list{2+active_obj_idx(obj_nr),7} = 0;  % moving flag
        
        % set match flag to cluster
        target_hist{n,2+target_hist{n,2}+1+nearest_obj_idx}(6) = target_hist{n,2+target_hist{n,2}+1+nearest_obj_idx}(6) + 1;
    else
        
        % check match flag of target -> lifetime decreases for unmatched targets
        % lifetime
        curr_obj_list{2+active_obj_idx(obj_nr),2} = curr_obj_list{2+active_obj_idx(obj_nr),2} - delta_frame;
        if curr_obj_list{2+active_obj_idx(obj_nr),2} < 5
            curr_obj_list{2+active_obj_idx(obj_nr),1} = 0;
        end
        if curr_obj_list{2+active_obj_idx(obj_nr),2} < 1
            curr_obj_list{2+active_obj_idx(obj_nr),1} = -1;
            curr_obj_list{2+active_obj_idx(obj_nr),2} = 0;
            curr_obj_list{2+active_obj_idx(obj_nr),3} = [];
            curr_obj_list{2+active_obj_idx(obj_nr),4} = [];
            curr_obj_list{2+active_obj_idx(obj_nr),5} = 0;
            curr_obj_list{2+active_obj_idx(obj_nr),6} = 0;
            curr_obj_list{2+active_obj_idx(obj_nr),7} = 0;
            curr_obj_list{2,1} = curr_obj_list{2,1} -1;
        end
    end
    
end


% merge all obj mapping to the same cluster
active_obj_idx = find(cat(1,curr_obj_list{3:130,5}) == 1);
num_obj = size(active_obj_idx,1);
for obj_i = 1:num_obj-1
    for obj_j = obj_i+1:num_obj
        if (curr_obj_list{2+active_obj_idx(obj_i),1} > -1) && (curr_obj_list{2+active_obj_idx(obj_j),1} > -1)
            
            if (abs(curr_obj_list{2+active_obj_idx(obj_i),3}(1) - curr_obj_list{2+active_obj_idx(obj_j),3}(1)) < 0.7)&&(abs(curr_obj_list{2+active_obj_idx(obj_i),3}(2)- curr_obj_list{2+active_obj_idx(obj_j),3}(2))<0.3)
                % same
                % delete obj with small frequency
                if curr_obj_list{2+active_obj_idx(obj_i),2} < curr_obj_list{2+active_obj_idx(obj_j),2}
                    % i < j, delete i
                    %curr_obj_list{2+active_obj_idx(obj_i),2} = curr_obj_list{2+active_obj_idx(obj_j),2};
                    
                    % delete obj_j
                    curr_obj_list{2+active_obj_idx(obj_i),1} = -1;
                    curr_obj_list{2+active_obj_idx(obj_i),2} = 0;
                    curr_obj_list{2+active_obj_idx(obj_i),3} = [];
                    curr_obj_list{2+active_obj_idx(obj_i),4} = [];
                    curr_obj_list{2+active_obj_idx(obj_i),5} = 0;
                    curr_obj_list{2+active_obj_idx(obj_i),6} = 0;
                    curr_obj_list{2+active_obj_idx(obj_i),7} = 0;
                    curr_obj_list{2,1} = curr_obj_list{2,1} -1;
                elseif curr_obj_list{2+active_obj_idx(obj_i),2} >= curr_obj_list{2+active_obj_idx(obj_j),2}
                    % delete obj_j
                    curr_obj_list{2+active_obj_idx(obj_j),1} = -1;
                    curr_obj_list{2+active_obj_idx(obj_j),2} = 0;
                    curr_obj_list{2+active_obj_idx(obj_j),3} = [];
                    curr_obj_list{2+active_obj_idx(obj_j),4} = [];
                    curr_obj_list{2+active_obj_idx(obj_j),5} = 0;
                    curr_obj_list{2+active_obj_idx(obj_j),6} = 0;
                    curr_obj_list{2+active_obj_idx(obj_j),7} = 0;
                    curr_obj_list{2,1} = curr_obj_list{2,1} -1;
                end
            end
        end
        
    end
end

% check match flag of clusters -> new target from unmatched clusters
for cluster = 0:target_hist{n,2}-1
    if target_hist{n,2+target_hist{n,2}+1+cluster}(6) == 0
        point_clouds = target_hist{n,3+cluster};
        obj_w = target_hist{n,2+target_hist{n,2}+1+cluster}(4);
        obj_h = target_hist{n,2+target_hist{n,2}+1+cluster}(5);
        %new target
        % initial new object
        curr_obj_list{2,1} = curr_obj_list{2,1}+1 ;
        % push in the list
        new_obj_num = new_obj_num + 1;
        % incinfident
        curr_obj_list{2+leer_obj_idx(new_obj_num),1} = 0;
        %life time
        curr_obj_list{2+leer_obj_idx(new_obj_num),2} = curr_obj_list{2+leer_obj_idx(new_obj_num),2} + 1;
        if curr_obj_list{2+leer_obj_idx(new_obj_num),2} > 20
            curr_obj_list{2+leer_obj_idx(new_obj_num),2} = 20;
        end
        % center
        curr_obj_list{2+leer_obj_idx(new_obj_num),3} = mean(point_clouds(:,1:5));
        % w,h
        curr_obj_list{2+leer_obj_idx(new_obj_num),3}(6) = obj_w;
        curr_obj_list{2+leer_obj_idx(new_obj_num),3}(7) = obj_h;
        curr_obj_list{2+leer_obj_idx(new_obj_num),4} = point_clouds;
        curr_obj_list{2+leer_obj_idx(new_obj_num),5} = 1;
        curr_obj_list{2+leer_obj_idx(new_obj_num),6} = 1;
        curr_obj_list{2+leer_obj_idx(new_obj_num),7} = 0;
    end
end



end