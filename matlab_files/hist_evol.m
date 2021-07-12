%% ------------------------------------------------------------------------
% hist_evol.m: plot lambda_t distribution evolution over time
% -------------------------------------------------------------------------
function [hist_out] = hist_evol(X,dt,lims,bin_rule,bin_ctr_man,max_bin)
%%% Settings used to produce Figure 6 in original paper are
%%% X = lambda draws from posterior
%%% dt = date from 1992:Q1 - 2011:Q2 (which uses models estimated on data
%%% 1991:Q2 - 1010:Q3, as we assume a quarter lag in information sets
%%% and assume h = 1 corresponds to a nowcast)
%%% lims = [0,1]
%%% bin_rule = 'fre-dia'
%%% bin_ctr_man = 0
%%% max_bin not set (so default to 200)
%%% Triple commented section added by William Chen
%% ------------------------------------------------------------------------
% check inputs
% -------------------------------------------------------------------------
mb_true = 1;
if ~exist('max_bin','var')
    max_bin = 200;
    mb_true = 0;
end

if ~exist('bin_ctr_man','var')
    bin_ctr_man = 0;
end

% check that the dimensions match
if size(X,2) ~= length(dt)
    error('date series and data series should be of the same length');
else
    T = size(X,2);
    N = size(X,1);
end

% set bin width rule if not set
if ~exist('bin-rule','var')
    bin_rule = 'fre-dia';
end

% check bin width rule
if strcmp(bin_rule,'scott')
    bw = @(X,N) (3.5*std(X))*(N^(-1/3));
elseif strcmp(bin_rule,'fre-dia')
    bw = @(X,N) 2*iqr(X)*N^(-1/3);
else
    error('supported bin width rules: ''scott'' and ''fre-dia''');
end

%% ------------------------------------------------------------------------
% plot lambda_t distribution evolution over time
% -------------------------------------------------------------------------
hist_out= cell(T,1);

for ii_ = 1:T
    % use specified bin width rule
    b_width = bw(X(:,ii_),N);
    b_num   = ceil(diff(lims)/b_width);

    if b_num > max_bin
        b_num = max_bin;
        b_width = diff(lims)/b_num;
    end

    ctr = lims(1) + [0:b_num-1]*b_width + b_width/2;

    if bin_ctr_man
        [ct,xout] = hist(X(:,ii_),ctr);
    else
        [ct,xout] = hist(X(:,ii_),b_num);
    end


    % make it 3D!
    xMat = zeros([T size(xout,2)]);
    xMat(ii_,:) = (ct/(N*b_width));
    h =bar3(xout,xMat',1);
    if ii_ == 1
        hold on;
    end

    set(h,'EdgeColor','None');
    for k = 1:length(h)
        zdata = get(h(k),'ZData');
        set(h(k),'CData',zdata,...
            'FaceColor','interp');
    end

    % save
    hist_out{ii_,1} = {b_width,N,ct,xout};

end

ylim(lims);
pbaspect([3 1.1 0.7]);

set(gca,'XTickLabel',dt(10:10:end)')
