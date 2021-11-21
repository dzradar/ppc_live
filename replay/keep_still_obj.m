function [curr_obj_list live_people_list] = keep_still_obj(curr_obj_list, live_people_list)

bounding_box_x = 1.5;
bounding_box_y = 3.5;
% reset updated flag
valid_obj_idx = find(cat(1,live_people_list{:,7}) > 0);
if ~isempty(valid_obj_idx)
    for n = 1:size(valid_obj_idx,1)
        live_people_list{valid_obj_idx(n),8} = 0;   %updated flag, 1 updated, 0 no show object
    end
end

% if obj life time bigger than 20, keep in memory
active_obj_idx = find(cat(1,curr_obj_list{3:130,5}) == 1);
leer_obj_idx = find(cat(1,live_people_list{:,7}) == -1);
new_obj_num = 0;
idx_list = cat(1,live_people_list{:,7});
for obj_nr = 1:size(active_obj_idx,1)
    if curr_obj_list{2+active_obj_idx(obj_nr),2} == 20
        
        % is this obj new?
        % current obj ID
        cur_ID = active_obj_idx(obj_nr);
        idx_incl = find(idx_list==cur_ID);
        if isempty(idx_incl)            
            % if it is a new obj do this
            % people record
            % + ID  -1 no use, 1: exist
            new_obj_num = new_obj_num + 1;
            live_people_list{leer_obj_idx(new_obj_num),1} = curr_obj_list{2+active_obj_idx(obj_nr),1};
            live_people_list{leer_obj_idx(new_obj_num),2} = curr_obj_list{2+active_obj_idx(obj_nr),2};
            live_people_list{leer_obj_idx(new_obj_num),3} = curr_obj_list{2+active_obj_idx(obj_nr),3};
            live_people_list{leer_obj_idx(new_obj_num),4} = curr_obj_list{2+active_obj_idx(obj_nr),4};
            live_people_list{leer_obj_idx(new_obj_num),5} = curr_obj_list{2+active_obj_idx(obj_nr),5};
            live_people_list{leer_obj_idx(new_obj_num),6} = curr_obj_list{2+active_obj_idx(obj_nr),6};
            live_people_list{leer_obj_idx(new_obj_num),7} = active_obj_idx(obj_nr);
            live_people_list{leer_obj_idx(new_obj_num),8} = 1;
            live_people_list{leer_obj_idx(new_obj_num),9} = 1;
        else
            % the obj ID is already recorded
            % update the position            
            live_people_list{idx_incl(1),1} = curr_obj_list{2+active_obj_idx(obj_nr),1};
            live_people_list{idx_incl(1),2} = curr_obj_list{2+active_obj_idx(obj_nr),2};
            live_people_list{idx_incl(1),3} = curr_obj_list{2+active_obj_idx(obj_nr),3};
            live_people_list{idx_incl(1),4} = curr_obj_list{2+active_obj_idx(obj_nr),4};
            live_people_list{idx_incl(1),5} = curr_obj_list{2+active_obj_idx(obj_nr),5};
            live_people_list{idx_incl(1),6} = curr_obj_list{2+active_obj_idx(obj_nr),6};             
            live_people_list{idx_incl(1),8} = 1;
            if live_people_list{idx_incl(1),9} > 1
                live_people_list{idx_incl(1),9} = 1; %live_people_list{idx_incl(1),9} -1;
            end
        end
    end
end


% decide whether to keep still obj

valid_obj_idx = find(cat(1,live_people_list{:,7}) > 0);

if ~isempty(valid_obj_idx)
    for n = 1:size(valid_obj_idx,1)
        % check obj
        if live_people_list{valid_obj_idx(n),8} == 0   %updated flag, 1 updated, 0 no show object
            % obj is missing
            xc = live_people_list{valid_obj_idx(n),3}(1);
            yc = live_people_list{valid_obj_idx(n),3}(2);
            phi = live_people_list{valid_obj_idx(n),3}(3);            
            live_people_list{valid_obj_idx(n),9} = live_people_list{valid_obj_idx(n),9}+1;
            % case 2:
            % delete obj near field and dist < 1m, phi > 15degree
            if (yc < 0.8) && (abs(phi)>15)
                % no object keep
                
                live_people_list{valid_obj_idx(n),1} = -1;
                live_people_list{valid_obj_idx(n),2} = 0;
                live_people_list{valid_obj_idx(n),3} = [];
                live_people_list{valid_obj_idx(n),4} = [];
                live_people_list{valid_obj_idx(n),5} = 0;
                live_people_list{valid_obj_idx(n),6} = 0;
                live_people_list{valid_obj_idx(n),7} = -1;
                live_people_list{valid_obj_idx(n),8} = -1;
                live_people_list{valid_obj_idx(n),9} = 0;
            elseif (abs(xc) < bounding_box_x) && (abs(yc) < bounding_box_y) && (live_people_list{valid_obj_idx(n),9}<60)
                % obj is still in the scene and will be kept
                curr_obj_list{2+live_people_list{valid_obj_idx(n),7},1} = live_people_list{valid_obj_idx(n),1};
                curr_obj_list{2+live_people_list{valid_obj_idx(n),7},2} = live_people_list{valid_obj_idx(n),2};
                curr_obj_list{2+live_people_list{valid_obj_idx(n),7},3} = live_people_list{valid_obj_idx(n),3};
                curr_obj_list{2+live_people_list{valid_obj_idx(n),7},4} = live_people_list{valid_obj_idx(n),4};
                curr_obj_list{2+live_people_list{valid_obj_idx(n),7},5} = live_people_list{valid_obj_idx(n),5};
                curr_obj_list{2+live_people_list{valid_obj_idx(n),7},6} = live_people_list{valid_obj_idx(n),6};
                curr_obj_list{2+live_people_list{valid_obj_idx(n),7},7} = 1;
                
            else
                
                live_people_list{valid_obj_idx(n),1} = -1;
                live_people_list{valid_obj_idx(n),2} = 0;
                live_people_list{valid_obj_idx(n),3} = [];
                live_people_list{valid_obj_idx(n),4} = [];
                live_people_list{valid_obj_idx(n),5} = 0;
                live_people_list{valid_obj_idx(n),6} = 0;
                live_people_list{valid_obj_idx(n),7} = -1;
                live_people_list{valid_obj_idx(n),8} = -1;
                live_people_list{valid_obj_idx(n),9} = 0;
            end
        end
    end
end


end