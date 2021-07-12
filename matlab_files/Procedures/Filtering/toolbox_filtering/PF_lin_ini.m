function [lik, all_s_up, Neff] = PF_lin_ini(A, B, H, Phi, R, S2, N, yt, x0, P0)
% -----------------------------------------------------------------------
%     "Naive" particle filtering for model with measurement error
% -----------------------------------------------------------------------
%                        Model( Linear Model)
% 
%              y_{t} = A + B s_{t} + u_{t}, u ~ (0, H)
%              s_{t} = Phi s_{t-1} + R*e_{t}, e ~ (0, S2)
% -----------------------------------------------------------------------
% Input
%   A, B, H : parameters for measurement equation
%   Phi, S2 : parameters for transition equation
%   N       : number of particles
%   yt      : data
%   x0, P0  : initial prior for the filter
%   msval   : missing value index (observation equation matrix changes overtime)
% -----------------------------------------------------------------------
% Output
%   lik       : likelihood (T by 1)
%   all_s_up  : particles resampled (updated) (T by N)
%   Neff      : Effective sample size
% -----------------------------------------------------------------------
% rmk1) some part are not vectorized
% rmk2) not sure wheather it is a good idea that keeps all particles (memory)
% -----------------------------------------------------------------------
% housekeeping
ne        = size(S2,1);
[n_y, ns] = size(B);
T         = size(yt,1);
sqrtS2    = R*chol(S2)';

% matrix for store
all_s_up  = zeros(T, ns, N);   % resampled 
lik       = zeros(T,1);
Neff      = zeros(T,1);

% 1. initialization
temp_s = x0;
temp_P = P0;
s_up   = repmat(temp_s, 1, N) + chol(temp_P)'*randn(ns, N);

% Following matrices are changing over time
% - NONE ...

% Rest of Steps
for tt=1:1:T
    
    yy = yt(tt,:);
    
    % Propagate
    s_fore   = Phi*s_up + sqrtS2*randn(ne, N);
    
    % Un-normalized weights
    perror  = repmat(yy'-A, 1, N) - B*s_fore;
    density = mvnpdf(perror', zeros(1,size(yy,2)), H);
    
    % Sum of density (normalized weights)
    weights = density/sum(density);
    
    % Effective sample size
    Neff(tt,1) = 1/sum(weights.^2);
    
    % Resampling - systematic
    [s_up,index_rep,RepParticle] = resp_sys(s_fore, weights);
    
    % Store results
    lik(tt,1)        = log(mean(density));
    all_s_up(tt,:,:) = s_up;
    
%     plot(s_up')
%     RepParticle
%     tt = tt + 1;
    
end


