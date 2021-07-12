function [lik, all_s_fore, all_s_up, Neff, all_weights] = PF_lin_noResp(A, B, H, Phi, R, S2, N, yt, x0, P0)
% -----------------------------------------------------------------------
%     "Naive" particle filtering for model with measurement error
% Without resampling
% - To get state estimates, you need all_weights to take weighted average.
%
% -----------------------------------------------------------------------
%                        Model( Linear Model)
% 
%              y_{t} = A + B s_{t} + u_{t}, u ~ (0, H)
%              s_{t} = Phi s_{t-1} + R*e_{t}, e ~ (0, S2)
% -----------------------------------------------------------------------
% Input
%   A, B, H : parameters for measurement equation
%   Phi, S2 : parameters for transition equation
%   N : number of particles
%   yt: data
% -----------------------------------------------------------------------
% Output
%   lik         : likelihood (T by 1)
%   all_s_fore  : particles forecasted          (T by N)
%   all_s_rspl  : particles resampled (updated) (T by N)
% -----------------------------------------------------------------------
% rmk1) some part are not vectorized
% rmk2) not sure wheather it is good idea that keeps all particles (memory)
% -----------------------------------------------------------------------
% % ----------------------------------------------------
% % tester
% % ----------------------------------------------------
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
% yt = y;
% 
% N=10;
% % ----------------------------------------------------
% housekeeping
ne        = size(S2,1);
[n_y, ns] = size(B);
T         = size(yt,1);
sqrtS2    = R*chol(S2)';
% matrix for store
all_s_fore   = zeros(T, ns, N);    % forecasted
all_s_up     = zeros(T, ns, N);    % -
all_weights  = zeros(T,N);         % IS weights

lik = zeros(T,1);
Neff = zeros(T,1);


% 1. initialization
temp_s = x0;
temp_P = P0;
s_up   = repmat(temp_s, 1, N) + chol(temp_P)'*randn(ns, N);

weights = ones(N,1)*(1/N); %no IS at time 0

% Rest of Steps
for tt=1:1:T
    
    % 2. forecasting
    s_fore   = Phi*s_up + sqrtS2*randn(ne, N);
    
    % 3. un-normalized weights
    perror   = repmat(yt(tt,:)'-A, 1, N) - B*s_fore;
    density  = mvnpdf(perror', zeros(1,ns), H);
    
    % Sum of density
    weights00 = density.*weights;
    weights   = weights00/sum(weights00);
    
    % Effective sample size
    Neff(tt,1) = 1/sum(weights.^2);
    
    % No resampling
    s_up = s_fore;
    
    % store results
    lik(tt,1)           = log(mean(density)); %this might not true, be careful with IS weight ...
    all_s_fore(tt,:,:)  = s_fore;
    all_s_up(tt,:,:)    = s_up;
    all_weights(tt,:)   = weights;
end









    
    
    
    
    
    

