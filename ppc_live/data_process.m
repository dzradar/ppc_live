function [frame_buff Target_list Cluster_list] = data_process(rxData,  Target_list, Cluster_list)

frame_buff = [];
num = size(rxData, 2);
syncPatternUINT64 = typecast(uint16([hex2dec('0102'),hex2dec('0304'),hex2dec('0506'),hex2dec('0708')]),'uint64');
tracker_syncPatternUINT64 = typecast(uint16([hex2dec('0807'),hex2dec('0605'),hex2dec('0403'),hex2dec('0201')]),'uint64');

idx = 0;
code_format = -1;
while true
    if num >= 16
        % loop for magic word
        magicBytes = typecast(uint8(rxData((idx+1):(idx+8))), 'uint64'); 
        if( (magicBytes == syncPatternUINT64) || (magicBytes == tracker_syncPatternUINT64))
            
            if magicBytes == syncPatternUINT64
                % cluster
                code_format = 0; % 如果找到了点云的头，把标志位置0；
            elseif magicBytes == tracker_syncPatternUINT64
                % object
                code_format = 1; % 如果找到了目标的头，把标志位置1；
            end
            % find the header
            offset = 8; % 偏移8个字节的帧头magic位
            frame_num = typecast(uint8(rxData(idx+offset+1:idx+offset+4)), 'uint32'); % 四个字节的帧数
            offset = offset + 4; % 偏移4个字节的帧数位
            Ntarget = typecast(uint8(rxData(idx+offset+1:idx+offset+4)), 'int32');
            frame_len = 0;
            if code_format == 0
                frame_len = 16+24*Ntarget;
                %disp('--- cluster ---')
            elseif code_format == 1
                frame_len = 16+32*Ntarget;
                %disp('--- object ---')
            end
            
            if (frame_len+idx) <= num            % 长度是否足一帧数据量
                % ok one frame is complete
                data_frame = rxData(idx+1:frame_len+idx);
                % decode
                if code_format == 0
                    point_list = point_cloud_decoder(data_frame, frame_num, Ntarget);
                    Cluster_list = [ Cluster_list; point_list];
                    %show_points(point_list); 
                elseif code_format == 1
                    obj_list = target_obj_decoder(data_frame, frame_num, Ntarget);
                    Target_list = [Target_list; obj_list];
                    %show_targets(obj_list);
                end
              
                
                % update size
                if (frame_len+idx) < num
                    rxData = rxData(idx+frame_len+1:end);
                    num =  size(rxData, 2);
                    idx = 0;
                else 
                    rxData = [];
                    frame_buff = [];
                    num = 0;
                    idx = 0;
                end
                
            else
                %not enough data
                frame_buff = rxData(idx+1:end);
                break;
            end
        else
            idx = idx + 1; % 如果都不是点云和跟踪的帧头，则偏移
            num = num -1;
        end
        
    else
        % not enough data
        frame_buff = rxData;
        break;
    end
end

end


function show_points(point_list)

figure(1);
pause(0.01)
plot(point_list(:,3), point_list(:,4), 'r.');
grid on;
xlim([-2.5 2.5]);
ylim([0 5])
obj_str = ['Cluster = ' num2str(1+max(point_list(:,5)))];
title(obj_str);

pause(0.01)
end


function show_targets(obj_list)

figure(1)
plot(obj_list(:,1), obj_list(:,2), 'b.', 'MarkerSize',12);
grid on;
xlim([-2.5 2.5]);
ylim([0 5])
obj_str = ['Target = ' num2str(size(obj_list, 1))];
title(obj_str);

pause(0.01)
end


