function [s_up, P_up, loglik] = kalman_filter_ini(x0,P0,A,B,Phi,R,H,S2, y)
% ----------------------------------------------------
% Kalman filter with x0 and P0 as an input for the function
% updated: 03/14/2012
% ----------------------------------------------------
% Model
% ----------------------------------------------------
%  y_{t} = A + B s_{t} + u
%  s_{t} = Phi s_{t-1} + R*ep
%  var(u) ~ H
%  var(ep) ~ S2
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
s_up = zeros(T,dim_s);
P_up = zeros(dim_s, dim_s, T);
y_lik = zeros(T,1);
% 1. initialization
temp_s = x0;
temp_P = P0;

for i=1:1:T
    % 2. forecast
    s_fore = Phi*temp_s;
    P_fore = Phi*temp_P*Phi' + R*S2*R';
    
    P_fore = P_fore.*(abs(P_fore)>1e-20);
    
    P_fore = 1/2*(P_fore+P_fore');
    
    y_fore = A + B*s_fore;
    F_fore = B*P_fore*B' + H;
    F_fore = 1/2*(F_fore+F_fore');
    
    % 3. conditional likelihood
    pred_err = (y(i,:)'-y_fore);
    y_lik(i,1) = (2*pi)^(-dim_y/2) * det(F_fore)^(-1/2) * exp(-1/2*pred_err'*(F_fore\pred_err));
    
    % 4. update
    temp_s = s_fore + P_fore*B'*(F_fore\pred_err);
    temp_P = P_fore - P_fore*B'*(F_fore\B)*P_fore';
    
    temp_P = temp_P.*(abs(temp_P)>1e-20);
    
    temp_P = 1/2*(temp_P'+temp_P);
	
	% SAVE
    s_up(i,:) = temp_s;
    P_up(:,:,i) = temp_P;
end
loglik = log(y_lik);

