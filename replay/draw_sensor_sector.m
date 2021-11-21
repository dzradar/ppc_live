
function [xx, yy] = draw_sensor_sector(start_angle, angle_opening, radius)

theta1 = pi*start_angle/180;    % starting angle in radians
theta  = pi*angle_opening/180;   % central angle in radians

angle_ratio = theta/(2*pi);     % ratio of the sector to the complete circle
MaxPts = 100;                   % maximum number of points in a whole circle.
                                % if set to small # (e.g 10) the resolution
                                % of the curve will be poor. 
                                % generally values greater than 50
                                % will give (very) good resolution

n = abs( ceil( MaxPts*angle_ratio ) );
r = [ 0; radius*ones(n+1,1); 0 ];
theta =  theta1 + [ 0; angle_ratio*(0:n)'/n; 0 ]*2*pi;

% output
[xx,yy] = pol2cart(theta,r);

% plot if not enough output variable are given
%plot(xx, yy);

end

