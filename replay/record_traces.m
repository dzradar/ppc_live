function [obj_traces obj_traces_idx] = record_traces( curr_obj_list, obj_traces, obj_traces_idx)

vec_xy = [];
for n = 1:(size(curr_obj_list, 1)-2)
    if ~isempty(curr_obj_list{n+2,3})
        vec_xy(2*(n-1)+1) = curr_obj_list{n+2,3}(1);
        vec_xy(2*(n-1)+2) = curr_obj_list{n+2,3}(2);
    else
        vec_xy(2*(n-1)+1) = -1;
        vec_xy(2*(n-1)+2) = -1;
    end
end
obj_traces(1+obj_traces_idx,:) =  vec_xy;


% update idx
obj_traces_idx = obj_traces_idx +1;
if obj_traces_idx > 10
    obj_traces_idx = 0;
end
end