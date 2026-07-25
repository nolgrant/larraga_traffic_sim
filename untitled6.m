figure();
hold on;
grid on; 

for ix = 1:size(x_mean_perframe,2)
    plot(x_mean_perframe(:, ix, 1));  % pick an index near the peak
end