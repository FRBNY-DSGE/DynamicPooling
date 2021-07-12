function [kfm, kfV] = kfprop(s, A, B, H, Phi, R, S2, y)
% -----------------------------------------------------------------------
% Mean and variance for the Kalman filter proposal distribution
% s : ns by 1
% -----------------------------------------------------------------------
%                        Model( Linear Model)
%
%              y_{t} = A + B s_{t} + u_{t}, u ~ (0, H)
%              s_{t} = Phi s_{t-1} + R*e_{t}, e ~ (0, S2)
% -----------------------------------------------------------------------

% Forecast
s_fore = Phi*s;
P_fore = R*S2*R'; %note that this line is different from KF because we know s for sure in this case
y_fore = A + B*s_fore;
F_fore = B*P_fore*B' + H;

pred_err = (y-y_fore);

% Update
kfm = s_fore + P_fore*B'*(F_fore\pred_err);
kfV = P_fore - P_fore*B'*(F_fore\B)*P_fore';

