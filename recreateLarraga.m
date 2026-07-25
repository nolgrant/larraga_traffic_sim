clear;
close all;

L = 1000;
tic;
% Recreate Figure 1 and 2
R_in      = repmat(0.4, 1, 5);
a_in      = [1, 0.75, 0.50, 0.25 0];
string_in = "R=0.4, Sweep Alpha";
plotstr = "Case1_1000_Final";
sweepAcrossCars(R_in, a_in, string_in, plotstr, L)
toc

tic;
R_in      = [0.2, 0.4];
a_in      = [0.25, 0.25];
string_in = "Sweep R, Alpha=0.25";
plotstr = "Case2_1000_Final";
sweepAcrossCars(R_in, a_in, string_in, plotstr, L)
toc

tic;
R_in      = repmat(0.2, 1, 5);
a_in      = [1, 0.75, 0.50, 0.25 0];
string_in = "R=0.2, SweepAlpha";
plotstr = "Case3_1000_Final";
sweepAcrossCars(R_in, a_in, string_in, plotstr, L)
toc