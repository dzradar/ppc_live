
function show_all_targets_and_cluster(Target_list, Cluster_list)

figure(1)
subplot 121
hold off;
if ~isempty(Cluster_list)
plot(Cluster_list(:,3), Cluster_list(:,4), 'b.');hold on;
end
%plot(Target_list(:,1), Target_list(:,2), 'r.');
if ~isempty(Target_list)
for n = 1:size(Target_list, 1)
    circle(Target_list(n,1), Target_list(n,2),0.1, 'r'); hold on;
end
end
grid on;
xlim([-2.5 2.5]);
ylim([0 5])
end
