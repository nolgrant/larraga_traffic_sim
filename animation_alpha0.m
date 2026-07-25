%% Simulation Inputs
clear all; 
close all;

% number of cars in traffic simulation
N = 55;

% number of cells
L = 100;

% number of iterations to run the simulation
T = 500;

% maximum velocity
vmax = 5;

% randomization of deceleration
R = 0.75;

a = 0;

%% Set up Simulation

% vector to track current location
% initialize to random location on the road
x = zeros(T,N);
x(1,:) = randperm(L, N);

% vector to track current velocity
% start all cars at a random velocity
v(1,:) = randi(vmax, 1, N);


%% Run Simulation

for t = 1:T-1 %iterate over all time steps
    for n = 1:N %iterate over all cars

        x_curr = x(t,n);

        v_curr = v(t, n);
        v_next = v(t, n);

        % S1: Acceleration
        if v_curr < vmax
            v_next = v_next + 1;
        end

        % S2: Randomization
        if rand < R
            v_next = v_next - 1;
        end

        % S3: Deceleration
        all_cars_x = x(t,:);
        all_cars_v = v(t,:);
        
        % find next closest vehicle's current location and velocity
        [sorted_A, sort_idx] = sort(all_cars_x);
        sort_idx = [sort_idx, sort_idx]; %duplicate array to handle roll over
        next_closest_ix = sort_idx((find(n == sort_idx,1) + 1));
        xp = all_cars_x(next_closest_ix);
        vp = all_cars_v(next_closest_ix);

        % update velocity (slow down if too close to next vehicle)
        if x_curr < xp
             d = xp - x_curr - 1; % distance to next closest vehicle
        else
            d = (L+xp) - x_curr - 1;
        end
        v_next = min(v_next, round( d + (1-a)*vp ) );


        % S4: Vehicle Movement
        x(t+1, n) = mod(x_curr + v_next - 1, L) + 1;
        % x(t+1, n) = x_curr + v_next;

        % update current velocity
        v(t+1, n) = v_next;
    end

end



%% Plot results
figure(); 

% unwrap relative to L for plotting purpose
period = L;
scale_factor = period / (2 * pi);
x_scaled = x / scale_factor;
unwrapped_scaled = unwrap(x_scaled);
x_unwrapped = unwrapped_scaled * scale_factor;

% x location wrapped
figure(); 
plot(1:T, x, '.');
xlabel('Time Step');
ylabel('Position on Road');
title('Car Positions Over Time');
grid on;

% x location unwrapped
figure(); 
plot(1:T, x_unwrapped);
xlabel('Time Step');
ylabel('Position on Road');
title('Car Positions Over Time (Unwrapped)');
grid on;

% unit circle plotting
% figure();
% xlabel('Time Step');
% ylabel('Position on Road');
% title('Car Positions Over Time (On A Ring)');
% grid on;
% 
% x_plot = cos(x_scaled);
% y_plot = sin(x_scaled);
% colors = lines(N);
% for ix = 1:T
%     scatter(x_plot(ix,:), y_plot(ix,:), 36, colors, 'filled');
%     xlim([-1.1 1.1]); ylim([-1.1 1.1]); axis equal;
%     % plot(x_plot(ix,:), y_plot(ix,:), '.')
%     pause(0.01);
% end

v = VideoWriter('animation_alpha0.mp4', 'MPEG-4');
v.FrameRate = 30;
open(v);

figure();
xlabel('Time Step'); ylabel('Position on Road');
title('Car Positions Over Time (On A Ring)');
grid on; axis equal;

N = size(x, 2);
colors = lines(N);

x_plot = cos(x_scaled);
y_plot = sin(x_scaled);

for ix = 1:T
    cla;
    scatter(x_plot(ix,:), y_plot(ix,:), 36, colors, 'filled');
    xlim([-1.4 1.4]); ylim([-1.4 1.4]); axis equal;
    title('Car Positions Over Time On A Ring - Alpha = 0');
    grid on;
    drawnow;
    frame = getframe(gcf);
    writeVideo(v, frame);
end

close(v);