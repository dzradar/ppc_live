function show_obj_cluster(target_hist, curr_obj_list, frame_num,  obj_traces, obj_traces_idx)

n = frame_num;
figure(1);
subplot 122
hold off;


    %set(figure(2),'Name', 'PeopleCounting&Tracking', 'unit', 'normalized', 'Position',[0,0,1,1]);
    %set(gca,'position',[0.03 0.1 0.95 0.85]);

%
start_angle = 30;   % degree
angle_opening = 120; % field of view degree
radius = 4; % max range area in m
[sec_xx, sec_yy] = draw_sensor_sector(start_angle, angle_opening, radius);
% patch( sec_xx, sec_yy, 'g', 'FaceAlpha','flat','FaceVertexAlphaData',0.01);
%
% plot obj%
active_obj_idx = find(cat(1,curr_obj_list{3:130,5}) == 1);
for m = 1:size(active_obj_idx,1)
    if curr_obj_list{2+active_obj_idx(m),2} > 5
        point_clouds = curr_obj_list{2+active_obj_idx(m),4};
        xc = curr_obj_list{2+active_obj_idx(m),3}(1);
        yc = curr_obj_list{2+active_obj_idx(m),3}(2);
        plot(xc, yc, 'b+' );
        hold on;
        
        obj_w = curr_obj_list{2+active_obj_idx(m),3}(6);
        obj_h = curr_obj_list{2+active_obj_idx(m),3}(7);
        % circle(xc,yc,0.1, 'b');
        % if moving, plot
        if curr_obj_list{2+active_obj_idx(m),7} == 0
            if active_obj_idx(m) == 1
                plot(point_clouds(:,1), point_clouds(:,2), 'r.');
                circle(xc,yc,0.07, 'r');
            elseif active_obj_idx(m) == 2
                plot(point_clouds(:,1), point_clouds(:,2), 'b.');
                circle(xc,yc,0.07, 'b');
            elseif active_obj_idx(m) == 3
                plot(point_clouds(:,1), point_clouds(:,2), 'g.');
                circle(xc,yc,0.07, 'g');
            elseif active_obj_idx(m) == 4
                plot(point_clouds(:,1), point_clouds(:,2), 'k.');
                circle(xc,yc,0.07, 'k');
            elseif active_obj_idx(m) == 5
                plot(point_clouds(:,1), point_clouds(:,2), 'y.');
                circle(xc,yc,0.07, 'y');
            else
                plot(point_clouds(:,1), point_clouds(:,2), 'm.');
                circle(xc,yc,0.07, 'm');
            end
        else
            %plot only circle
            if active_obj_idx(m) == 1
                % plot(point_clouds(:,1), point_clouds(:,2), 'r.');
                circle(xc,yc,0.07, 'r');
            elseif active_obj_idx(m) == 2
                %plot(point_clouds(:,1), point_clouds(:,2), 'b.');
                circle(xc,yc,0.07, 'b');
            elseif active_obj_idx(m) == 3
                %plot(point_clouds(:,1), point_clouds(:,2), 'g.');
                circle(xc,yc,0.07, 'g');
            elseif active_obj_idx(m) == 4
                %plot(point_clouds(:,1), point_clouds(:,2), 'k.');
                circle(xc,yc,0.07, 'k');
            elseif active_obj_idx(m) == 5
                %plot(point_clouds(:,1), point_clouds(:,2), 'y.');
                circle(xc,yc,0.07, 'y');
            else
                %plot(point_clouds(:,1), point_clouds(:,2), 'm.');
                circle(xc,yc,0.07, 'm');
            end
        end
        
        % plot traces
        xidx = (active_obj_idx(m)-1)*2+1;
        yidx = (active_obj_idx(m)-1)*2+2;
        max_hist = size(obj_traces, 1);
        hist_idx = [];
        if obj_traces_idx == 0
            hist_idx = [obj_traces_idx+2:max_hist];
        elseif obj_traces_idx <= max_hist
            hist_idx = [obj_traces_idx+1:max_hist 1:obj_traces_idx-1];
        end
        if ~isempty(hist_idx)
            x_tr = obj_traces(hist_idx,xidx);
            y_tr = obj_traces(hist_idx,yidx);
            tr_idx = find(x_tr == -1);
            
            start_idx = 1;
            if ~isempty(tr_idx)
                start_idx = tr_idx(end)+1;
            end
            end_idx = max_hist-1;
            
            if active_obj_idx(m) == 1
                plot(x_tr(start_idx:end_idx), y_tr(start_idx:end_idx), 'r');
            elseif active_obj_idx(m) == 2
                plot(x_tr(start_idx:end_idx), y_tr(start_idx:end_idx), 'b');
            elseif active_obj_idx(m) == 3
                plot(x_tr(start_idx:end_idx), y_tr(start_idx:end_idx), 'g');
            elseif active_obj_idx(m) == 4
                plot(x_tr(start_idx:end_idx), y_tr(start_idx:end_idx), 'k');
            elseif active_obj_idx(m) == 5
                plot(x_tr(start_idx:end_idx), y_tr(start_idx:end_idx), 'y');
            else
                plot(x_tr(start_idx:end_idx), y_tr(start_idx:end_idx), 'r');
                
            end
        end
    end
end
valid_obj_idx = size(find ( cat(1,curr_obj_list{3:130,2}) > 5),1);
% rectangle('Position',[-1.5 0 3 3.5],'EdgeColor', 'k');


    plot(sec_xx, sec_yy, 'k')

%patch( sec_xx, sec_yy, 'g', 'FaceAlpha','flat','FaceVertexAlphaData',0.01);


obj_str = ['Obj Num：' num2str(valid_obj_idx)];
title(obj_str);
xlim([-2.5 2.5]);
ylim([0 5]);
grid on;

%axis equal;
%pause(0.001)


%
% %plot cluster
%
% figure(1);
% hold off;
% for cluster = 0:target_hist{n,2}-1
%
%     point_clouds = target_hist{n,3+cluster};
%     if cluster == 0
%         plot(point_clouds(:,1), point_clouds(:,2), 'r.');
%         %rectangle('Position',[xc-obj_w/2 yc-obj_h/2 obj_w obj_h],'EdgeColor', 'r');
%         hold on;
%         %circle(xc,yc,(obj_w+obj_h)/2, 'r');
%     elseif cluster == 1
%         plot(point_clouds(:,1), point_clouds(:,2), 'b.');
%         %rectangle('Position',[xc-obj_w/2 yc-obj_h/2 obj_w obj_h],'EdgeColor', 'b');
%         hold on;
%         %circle(xc,yc,(obj_w+obj_h)/2, 'b');
%     elseif cluster == 2
%         plot(point_clouds(:,1), point_clouds(:,2), 'k.');
%         %circle(xc,yc,(obj_w+obj_h)/2, 'k');
%         %rectangle('Position',[xc-obj_w/2 yc-obj_h/2 obj_w obj_h],'EdgeColor', 'k');
%         hold on;
%     elseif cluster == 3
%         plot(point_clouds(:,1), point_clouds(:,2), 'g.');
%         %rectangle('Position',[xc-obj_w/2 yc-obj_h/2 obj_w obj_h],'EdgeColor', 'g');
%         hold on;
%         %circle(xc,yc,(obj_w+obj_h)/2, 'g');
%     elseif cluster == 4
%         plot(point_clouds(:,1), point_clouds(:,2), 'r.');
%         %rectangle('Position',[xc-obj_w/2 yc-obj_h/2 obj_w obj_h],'EdgeColor', 'r');
%         hold on;
%         %circle(xc,yc,(obj_w+obj_h)/2, 'r');
%     else
%         plot(point_clouds(:,1), point_clouds(:,2), 'r.');
%         %rectangle('Position',[xc-obj_w/2 yc-obj_h/2 obj_w obj_h],'EdgeColor', 'r');
%         hold on;
%         %circle(xc,yc,(obj_w+obj_h)/2, 'r');
%
%     end
% end
%
% obj_str = ['Cluster ' num2str(target_hist{n,2})];
% title(obj_str);
% xlim([-2.5 2.5]);
% ylim([0 5]);
% grid on;
% pause(0.001)
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