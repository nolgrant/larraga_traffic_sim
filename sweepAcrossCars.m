function sweepAcrossCars(R_in, a_in, string_in, plotstr, L, T_burnin)
% number of cars in traffic simulation
% N gets swept form 1:L

arguments (Input)
    R_in      = repmat(0.4, 1, 5)
    a_in      = [1, 0.75, 0.50, 0.25 0];
    string_in = "Test";
    plotstr   = "TEST";
    L = 1000
    T_burnin  = 3*L   % default to T/2
end

% number of cells
% L = 50;
% N_values = round(linspace(1, L, 20));
% L = 1000;
N_values = round(linspace(1, L, 100));

% number of iterations to run the simulation
T = 6*L;

% maximum velocity
vmax = 5;

% randomization of deceleration
% R is an input

%% Set up Simulation
collision_count = zeros(length(N_values), length(R_in));

x_mean_perframe = zeros(T-1, length(N_values), length(R_in));

%loop over each R/a combination
for iteration = 1:length(R_in)

    tic;

    R = R_in(iteration);
    a = a_in(iteration);

    % loop over each density
    for denisty_ix = 1:length(N_values)
        N = N_values(denisty_ix);

        % vector to track current location
        % initialize to random location on the road
        x_curr_vec = randperm(L, N);

        % vector to track current velocity
        % start all cars at a random velocity
        v_curr_vec = zeros(1, N);
        % v_curr_vec = randi(vmax, 1, N);

        % only save the rolling sum instead of huge matrix of all velocity
        vel_sum = 0;
        vel_count = 0;

        %% Run Simulation

        for t = 1:T-1 %iterate over all time steps

            % pre-emptive work for S3 to save computation
            all_cars_x = x_curr_vec;
            all_cars_v = v_curr_vec;
            [~, sort_idx] = sort(all_cars_x);
            sort_idx = [sort_idx, sort_idx]; %duplicate array to handle roll over

            x_next_vec = zeros(1, N);
            v_next_vec = zeros(1, N);

            for n = 1:N %iterate over all cars

                x_curr = x_curr_vec(n);
                v_curr = v_curr_vec(n);
                x_next = [];
                v_next = v_curr;

                % S1: Acceleration
                if v_curr < vmax
                    v_next = v_next + 1;
                end

                % S2: Randomization
                if rand < R
                    v_next = v_next - 1;
                end

                % S3: Deceleration

                % find next closest vehicle's current location and velocity
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
                v_next_vec(n) = v_next;

            end

            % iterate S3 using neighbors' tentative velocities
            for correction_pass = 1:(vmax)
                changed = false;
                for n = 1:N
                    next_closest_ix = sort_idx((find(n == sort_idx,1) + 1));
                    xp = all_cars_x(next_closest_ix);
                    vp = v_next_vec(next_closest_ix);
                    x_curr = all_cars_x(n);
                    if x_curr < xp
                        d = xp - x_curr - 1;
                    else
                        d = (L+xp) - x_curr - 1;
                    end
                    v_candidate = min(v_next_vec(n), round( d + (1-a)*vp ) );
                    if v_candidate < v_next_vec(n)
                        v_next_vec(n) = v_candidate;
                        changed = true;
                    end
                end
                if ~changed
                    break   % converged early -- dont need all vmax-1 passes
                end
            end

            % S4: Vehicle Movement
            x_next_vec = mod(x_curr_vec + v_next_vec - 1, L) + 1;

            % bump to next frame
            x_curr_vec = x_next_vec;
            v_curr_vec = v_next_vec;
            
            x_mean_perframe(t, denisty_ix, iteration) = sum(v_next_vec)/length(v_next_vec);

            % add all the current velocities to rolling sum
            if t >= T_burnin
                vel_sum = vel_sum + sum(v_next_vec);
                vel_count = vel_count + length(v_next_vec);
            end

            % check that frame was legal
            if ~ (numel(unique(x_curr_vec)) == N)
                collision_count(denisty_ix, iteration) = collision_count(denisty_ix, iteration) + 1;
            end
        end

        %% Get data points
        velc(denisty_ix,iteration) = vel_sum / vel_count;
        dens(denisty_ix,iteration) = N/L;
        flow(denisty_ix,iteration) = dens(denisty_ix,iteration) * velc(denisty_ix,iteration);

    end
end

elapsed_time = toc;

timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'));
dirname = timestamp + '_' + plotstr;
mkdir(dirname)


f1 = figure();
leg = {};
xlabel('Density (cars per site)');
ylabel('Flow (cars per time step)');
title(sprintf('Flow vs Density in Traffic Simulation: %s (%0.2f seconds to run)', string_in, elapsed_time ));
grid on; hold on;
for ix = 1:size(dens, 2)
    plot(dens(:,ix), flow(:,ix));
    leg(ix) = {sprintf("a = %0.2f, R = %0.2f", a_in(ix), R_in(ix))};
end
legend(leg);

filename = dirname + '/'  + 'Fig1';
savefig(f1, strcat(filename, '.fig'))
exportgraphics(f1, strcat(filename, '.jpg'), 'Resolution', 300)
close(f1);

f2 = figure();
leg = {};
xlabel('Density (cars per site)');
ylabel('Velocity (sites per time step)');
title(sprintf('Velocity vs Density in Traffic Simulation: %s (%0.2f seconds to run)', string_in, elapsed_time ));
grid on; hold on;
for ix = 1:size(dens, 2)
    plot(dens(:,ix), velc(:,ix));
    leg(ix) = {sprintf("a = %0.2f, R = %0.2f", a_in(ix), R_in(ix))};
end
legend(leg);

filename = dirname + '/'  + 'Fig2';
savefig(f2, strcat(filename, '.fig'))
exportgraphics(f2, strcat(filename, '.jpg'), 'Resolution', 300)
close(f2);

save(fullfile(dirname, 'data.mat'), 'dens', 'flow', 'velc', 'collision_count', 'elapsed_time', 'x_mean_perframe');

end