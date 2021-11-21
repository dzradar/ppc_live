clear all
close all

s = serialport('COM3', 1382400);

frame_buff = [];

Cluster_list = [];
Target_list = [];

%only for save mode
hist_cluster = cell(0);
hist_target = cell(0);
cluster_valid_frame_num = 1;
target_valid_frame_num = 1;

% clear com buffer
if s.NumBytesAvailable > 0
    read(s,s.NumBytesAvailable,"uint8");
end

while true
    bytes = s.NumBytesAvailable;
    if bytes > 0
        data = read(s,bytes,"uint8");
        %disp('----');
        %data'
        frame_buff = [frame_buff data];
        [frame_buff Target_list Cluster_list] = data_process(frame_buff,  Target_list, Cluster_list);
        
        %only for save
        if ~isempty(Cluster_list)
            hist_cluster{cluster_valid_frame_num,1} = Cluster_list;
            cluster_valid_frame_num = cluster_valid_frame_num +1;
        end
        if ~isempty(Target_list)
            hist_target{target_valid_frame_num,1} = Target_list;
            target_valid_frame_num = target_valid_frame_num +1;
        end
        
        % save('hist_cluster.mat', 'hist_cluster');
        % save('hist_target.mat', 'hist_target')
        
        % plot
        if ~isempty(Target_list) || ~isempty(Cluster_list)
            show_all_targets_and_cluster(Target_list, Cluster_list);
            Cluster_list = [];
            Target_list = [];
            
        end
        
    end
end
