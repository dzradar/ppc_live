clc;
clear all;
close all;

display('Vision：2021/11/19---展示两个区域框，颜色变化---配套最新完整嵌入式')

% 读取txt中的配置参数
flag_array = [];
% sector_show_flag, full_screen_plot,
s = importdata('param.txt');
s = s{1};
data = regexp(s,'([a-z_A-Z]+)(\-?\d*\.?\d*)','tokens');
for i = 1:numel(data)
    eval([data{i}{1} '=' data{i}{2}]);
    flag_array = [flag_array str2num(data{i}{2})];
end
show_first_rectangle = [show_first_rectangle_x show_first_rectangle_y show_first_rectangle_w show_first_rectangle_h];
show_second_rectangle = [show_sec_rectangle_x show_sec_rectangle_y show_sec_rectangle_w show_sec_rectangle_h];
% % 两个静态框区域设置
% show_first_rectangle = [1 0 2 2];
% show_second_rectangle = [-3 0 2 2];

s = serialport('COM8', 1382400);
frame_buff = [];

Cluster_list = [];
Target_list = [];

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
        [frame_buff Target_list Cluster_list] = data_process(frame_buff, Target_list, Cluster_list);
        if ~isempty(Target_list) || ~isempty(Cluster_list)
            show_all_targets_and_cluster(Target_list, Cluster_list, show_first_rectangle, show_second_rectangle);
            Cluster_list = [];
            Target_list = [];
        end
    end
end

function show_all_targets_and_cluster(Target_list, Cluster_list,first_rectangle, second_rectangle)

figure(1)
clf;

msg_list = [];
%msg_list = Target_listTarget_listTarget_listTarget_list;
%subplot(1,2,1);
rectangle('position',[first_rectangle(1),first_rectangle(2),first_rectangle(3),first_rectangle(4)],'EdgeColor','b',...
    'LineWidth',3);
rectangle('position',[second_rectangle(1),second_rectangle(2),second_rectangle(3),second_rectangle(4)],'EdgeColor','y',...
    'LineWidth',3);
text(-1,5.8,'ID      速度             距离              角度');
if size(Target_list,1) == 1
    speed = sqrt(Target_list(1,3)*Target_list(1,3)+Target_list(1,4)*Target_list(1,4)+Target_list(1,5)*Target_list(1,5));
    range = sqrt(Target_list(1,1)*Target_list(1,1)+Target_list(1,2)*Target_list(1,2)+Target_list(1,3)*Target_list(1,3));
    msg_list(1,:) = [Target_list(1,9),speed,range,Target_list(1,7)];
    text(-1,5.5,num2str(msg_list(1,:)));
    hold on;
elseif size(Target_list,1) == 2
    for n = 1:size(Target_list, 1)
        speed(n,1) = sqrt(Target_list(n,3)*Target_list(n,3)+Target_list(n,4)*Target_list(n,4)+Target_list(n,5)*Target_list(n,5));
        range(n,1) = sqrt(Target_list(n,1)*Target_list(n,1)+Target_list(n,2)*Target_list(n,2)+Target_list(n,3)*Target_list(n,3));
        msg_list(n,:) = [Target_list(n,9) speed(n,1) range(n,1) Target_list(n,7)];
        text(-1,5.5-0.3*(n-1),num2str(msg_list(n,:)));
        hold on;
    end
elseif size(Target_list,1) == 3
    for n = 1:size(Target_list, 1)
        speed(n,1) = sqrt(Target_list(n,3)*Target_list(n,3)+Target_list(n,4)*Target_list(n,4)+Target_list(n,5)*Target_list(n,5));
        range(n,1) = sqrt(Target_list(n,1)*Target_list(n,1)+Target_list(n,2)*Target_list(n,2)+Target_list(n,3)*Target_list(n,3));
        msg_list(n,:) = [Target_list(n,9) speed(n,1) range(n,1) Target_list(n,7)];
        text(-1,5.5-0.3*(n-1),num2str(msg_list(n,:)));
        hold on;
    end
% else
%     text(-4,5.5,'No one or too many people!');
end
hold on;
if ~isempty(Cluster_list)
    plot(Cluster_list(:,3), Cluster_list(:,4), 'b.');
    hold on;
end
%plot(Target_list(:,1), Target_list(:,2), 'r.');
if ~isempty(Target_list)
    for n = 1:size(Target_list, 1)
        if Target_list(n,1) > first_rectangle(1) && Target_list(n,1) < first_rectangle(1)+first_rectangle(3)  && Target_list(n,2) > first_rectangle(2) && Target_list(n,2) < first_rectangle(2)+first_rectangle(4)
            circle(Target_list(n,1), Target_list(n,2),0.18, 'k');
            hold on;
        elseif Target_list(n,1) > second_rectangle(1) && Target_list(n,1) < second_rectangle(1)+second_rectangle(3)  && Target_list(n,2) > second_rectangle(2) && Target_list(n,2) < second_rectangle(2)+second_rectangle(4)
            circle(Target_list(n,1), Target_list(n,2),0.18, 'c');
            hold on;
        else
            circle(Target_list(n,1), Target_list(n,2),0.18, 'r');
            hold on;
        end
    end
end
grid on;
xlim([-4 4]);
ylim([0 6])
%subplot(1,2,2);
%text(0.5,0.5,'bend ');
end

function circle(x,y,r, color)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth)
ang=0:0.01:2*pi+.01;
xp=r*cos(ang);
yp=r*sin(ang);

plot(x+xp,y+yp, color);
patch(x+xp,y+yp,color,'facealpha',0.3);
end