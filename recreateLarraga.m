clear;
close all;

% Recreate Figure 1 and 2
R_in      = repmat(0.4, 1, 5);
a_in      = [1, 0.75, 0.50, 0.25 0];
string_in = "R=0.4, Sweep Alpha";
plotstr = "Case1_200_randomInitVeloc_changeS3";
sweepAcrossCars2(R_in, a_in, string_in, plotstr, 200)


% R_in      = [0.2, 0.4];
% a_in      = [0.25, 0.25];
% string_in = "Sweep R, Alpha=0.25";
% plotstr = "Case2";
% sweepAcrossCars(R_in, a_in, string_in, plotstr)
% 
% R_in      = repmat(0.2, 1, 5);
% a_in      = [1, 0.75, 0.50, 0.25 0];
% string_in = "R=0.2, SweepAlpha";
% plotstr = "Case3";
% sweepAcrossCars(R_in, a_in, string_in, plotstr)

