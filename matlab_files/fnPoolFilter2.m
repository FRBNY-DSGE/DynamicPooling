%% ------------------------------------------------------------------------
% fnPoolFilter_distr.m:
% -------------------------------------------------------------------------
% AUTHOR: Raiden B. Hasegawa
% ECONOMIST: Marco Del Negro
% DATE: 2013-08-02
% -------------------------------------------------------------------------

function [LL,wRep,lRep] = fnPoolFilter2(theta_in,p1,p2,G_in,K_in,...
    fK_in,para_names,varargin)
%% ------------------------------------------------------------------------
% parse theta
% -------------------------------------------------------------------------
k = length(theta_in);

% defaults
rho    = 0.5;
mu     = 0;
sigma2 = 1;

% theta
for i_ = 1:k
    eval([para_names{i_},' = ',num2str(theta_in(i_)),';']);
end

% fixed parameters
if nargin == 8
   fixed_para = varargin{1};
   for i_ = 1:size(fixed_para,1)
       eval([fixed_para{i_}{1},'=',num2str(fixed_para{i_}{2}),';']);
   end
end

%% ------------------------------------------------------------------------
% useful functions
% -------------------------------------------------------------------------

% function to propagate particles
propParticle = @(x,r,s,m) r*x+(1-r)*m +...
    sqrt(1-r^2)*sqrt(s)*randn(size(x));

% function to normalize weights
normWeights = @(w,N) w/(sum(w)/N);

% function to calculate effective sample size
ess = @(w,N) N^2/(norm(w)^2);

% function to calculate predictive density combination
predCombine = @(l,p1,p2) l.*p1+ (1-l).*p2;

% function to calculate log likelihood contributions
logLik = @(w,K) log(sum(w)/K);

%% ------------------------------------------------------------------------
% specifications
% -------------------------------------------------------------------------

% particle filter parameters
G   = G_in;      % groups
K   = K_in;  % number of particle per group
N   = G*K;    % total number of particles
fK  = fK_in;      % ess fraction threshold

T = size(p1,1); % number of dates

%% ------------------------------------------------------------------------
% filtering loop
% -------------------------------------------------------------------------

x = randn([N,1]);  % initialize particles
w = ones([N,1]);   % initialize weights

lRep = nan([N,T]); % initialize lambda matrix
wRep = nan([N,T]); % initialize particle weight matrix

LL   = zeros([1,G]);
for I = 1:T
    x = propParticle(x,rho,sigma2,mu);
    try
    l = normcdf(x);
    catch err
        keyboard;
    end
    w = w.*predCombine(l,p1(I),p2(I));

    for g = 1:G

        LL(g) = LL(g) + logLik(w(K*(g-1)+1:K*g),K);

        w_n = normWeights(w(K*(g-1)+1:K*g),K);

        if ess(w_n,K) < K*fK
            [ind,~] = multinomial_resampling3(w_n/K);
            w(K*(g-1)+1:K*g) = ones([K,1]);
            x(K*(g-1)+1:K*g) = x(ind);
        else
            w(K*(g-1)+1:K*g) = w_n;
        end

        wRep(K*(g-1)+1:K*g,I) = w(K*(g-1)+1:K*g)/sum(w(K*(g-1)+1:K*g));

    end
    lRep(:,I) = normcdf(x);
end

end
