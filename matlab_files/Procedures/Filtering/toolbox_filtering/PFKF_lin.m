function [lik, all_s_up, Neff] = PFKF_lin(A, B, H, Phi, R, S2, N, yt, x0, P0)
% -----------------------------------------------------------------------
%     "KF" particle filtering for model with measurement error
% -----------------------------------------------------------------------
%                        Model( Linear Model)
% 
%              y_{t} = A + B s_{t} + u_{t}, u ~ (0, H)
%              s_{t} = Phi s_{t-1} + e_{t}, e ~ (0, S2)
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
[n_y, ns] = size(B);
T         = size(yt,1);
% sqrtS2    = R*chol(S2)';

% matrix for store
all_s_up     = zeros(T, ns, N);    % -

lik  = zeros(T,1);
Neff = zeros(T,1);

% 1. initialization
temp_s = x0;
temp_P = P0;
s_up   = repmat(temp_s, 1, N) + chol(temp_P)'*randn(ns, N);

% Rest of Steps
for tt=1:1:T
    
    % 2. forecasting using KF proposal
    %s_fore   = Phi*s_up + sqrtS2*randn(ns, N);
    s_fore   = zeros(ns,N);
    qsy_dens = zeros(1,N);
    pss_dens = zeros(1,N);
    pys_dens = zeros(1,N);
    for ii = 1:1:N
        old_s      = s_up(:,ii);
        [kfm, kfV] = kfprop(old_s, A, B, H, Phi, R, S2, yt(tt,:)');
        new_s      = (kfm + chol(kfV)'*randn(ns,1))';
        
        s_fore(:,ii)   = new_s;
        qsy_dens(1,ii) = mvnpdf(new_s, kfm, kfV);
        pss_dens(1,ii) = mvnpdf(new_s, Phi*old_s, R*S2*R');
        pys_dens(1,ii) = mvnpdf(yt(tt,:)', A+B*new_s, H);
    end
    
    % 3. un-normalized weights
    density = (pys_dens.*pss_dens)./qsy_dens;
    
    % Sum of density
    weights = density/sum(density);
    
    % Effective sample size
    Neff(tt,1) = 1/sum(weights.^2);
    
    % Resampling - systematic
    [s_up,index_rep,RepParticle] = resp_sys(s_fore, weights);
    
    % store results
    lik(tt,1)          = log(mean(density));
    all_s_up(tt,:,:)   = s_up;
end
