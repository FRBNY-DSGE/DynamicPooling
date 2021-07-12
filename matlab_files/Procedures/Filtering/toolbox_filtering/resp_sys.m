function [rXXX,index_rep,RepParticle]=resp_sys(XXX, weights)
%---------------------------------
% Step 3: Resampling and Updating
% - systematic resampling
% 
% OUTPUT
% rXXX: resampled XXX
% 
%---------------------------------
[ns,N] = size(XXX); %ns by Nparticle
rXXX = zeros(ns,N); % resampled XXX

% calculating the cdf for the weights
cdf_weights = cumsum(weights);
u = zeros(N, 1);

% Starting value for u(1)
constant = 1/N;
u(1) = rand*constant;
i = 1;
count = 0;

N_kind = zeros(1, N);

for j=1:1:N
    
    count = count + 1;
    
    % Move along the cdf
    u(j) = u(1) + constant*(j-1);
    while u(j) > cdf_weights(i)
        
        N_kind(1,i) = count;
        count = 0;
        
        if (i < N)
            i = i+1;
        end
    end
end
N_kind(end) = count;
% sum(N_kind)
% Generate the swarm of resampled particles for the next period
% index_rep   : # of groups (swarms)
% RepParticle : # of particles in each group
index1      = 1;
index_rep   = 0;
RepParticle = NaN*zeros(N,1);
for i=1:1:N
    
    if (N_kind(1,i)>0)
        
        rXXX(:,index1:index1+N_kind(1,i)-1) = repmat(XXX(:,i),1,N_kind(1,i));
        
        index1    = index1 + N_kind(1,i);
        index_rep = index_rep + 1;
        RepParticle(index_rep) = N_kind(i);
        
    end
    
end