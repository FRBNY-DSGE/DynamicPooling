function [s_up, P_up, loglik] = kalman_filter(A,B,Phi,R,H,S2, y)
% ----------------------------------------------------
% Kalman Filter
% ----------------------------------------------------
% by Minchul Shin
% ----------------------------------------------------
% Model
% ----------------------------------------------------
%  y_{t} = A + B s_{t} + u,    var(u) ~ H
%  s_{t} = Phi s_{t-1} + R*ep, var(ep) ~ S2
% ----------------------------------------------------
% ----------------------------------------------------
% tester
% ----------------------------------------------------
% % parameter
% A = [1; 1];
% B = [2; 1];
% Phi = [0.3];
% R = 1;
% H = [1 0; 0 1];
% S2 = 1;
% % data
% T = 50;
% % s_t
% s = zeros(T+1,1);
% s(1,1) = 0;
% for i=2:1:T+1
%     s(i,1) = Phi * s(i-1,1) + R*sqrt(S2)*randn(1,1);
% end
% s = s(2:end,1);
% % y_t
% cH = chol(H)';
% y = zeros(T,2);
% for i=1:1:T
%     y(i,:) = (A + B*s(i,1) + cH*randn(2,1))';
% end
% ----------------------------------------------------
% housekeeping
[T, dim_y] = size(y);
dim_s = size(Phi,2);
s_up = zeros(T,dim_s^2);
P_up = zeros(T, dim_s^2);
y_lik = zeros(T,1);
% 1. initialization
temp_s = 0;
temp_P = (eye(dim_s) - kron(Phi,Phi))^(-1) * reshape((R*S2*R'),[],1);
for i=1:1:T
    % 2. forecast
    s_fore = Phi*temp_s;
    P_fore = Phi*temp_P*Phi' + R*S2*R';
    y_fore = A + B*s_fore;
    F_fore = B*P_fore*B' + H;
    % 3. conditional likelihood
    pred_err = (y(i,:)'-y_fore);
    y_lik(i,1) = (2*pi)^(-dim_y/2) * det(F_fore)^(-1/2) * exp(-1/2*pred_err'*(F_fore\pred_err));
    % 4. update
    temp_s = s_fore + P_fore*B'*(F_fore\pred_err);
    temp_P = P_fore - P_fore*B'*(F_fore\B)*P_fore';
    s_up(i,:) = temp_s;
    P_up(i,:) = reshape((temp_P)', [],1);
end
loglik = log(y_lik);
% loglik = sum(log(y_lik));

























