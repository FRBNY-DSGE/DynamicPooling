%% ------------------------------------------------------------------------
% static_recursive.m: recursively runs through sample estimating static
% lambda
% -------------------------------------------------------------------------
% AUTHOR: Raiden B. Hasegawa
% ECONOMIST: Marco Del Negro
% DATE: 2014-03-03
%
% MODIFIED BY: William Chen
% -------------------------------------------------------------------------

%% ------------------------------------------------------------------------
% add necessary paths
% -------------------------------------------------------------------------
addpath Procedures/
addpath Procedures/Filtering/toolbox_filtering/
addpath rtnormM/
addpath pool_spec/
addpath dsge_solution/

%% ------------------------------------------------------------------------
% Set parameters
% -------------------------------------------------------------------------

if ~exist('spec_file','var')
    spec_file = 'LR_spec01';
end
eval(spec_file);
test = testVars(testName,{},semicond);

%% ------------------------------------------------------------------------
% load predictive densities
% -------------------------------------------------------------------------

% if semi-conditional, change save file names
if semicond
  p_string='_semicond';
else
  p_string='';
end

save_tail = 'ss1'; % should be either ss1 or ss2
vintage = '210615'; % estimation vintage of static pool
f904 = fopen(['input_data/predictive_density_means_904_10-Jan-1992_to_10-Apr-2011_',testName,p_string],'r');
if strcmp(save_tail, 'ss1')
    f805 = fopen(['input_data/predictive_density_means_805_10-Jan-1992_to_10-Apr-2011_',testName,p_string],'r');
elseif strcmp(save_tail, 'ss2')
    f805 = fopen(['input_data/predictive_density_means_805_10-Jan-1992_to_10-Apr-2011_',testName,p_string, '_correct'],'r');
else
    error('save_tail must be either ss1 or ss2');
end
p904 = fread(f904,'single');
p805 = fread(f805,'single');

% get date series
fd904 = fopen(['input_data/predictive_density_fdates_904_10-Jan-1992_to_10-Apr-2011_',testName,p_string],'r');
dt    = fread(fd904,'single');
T = size(dt,1);

lRep = nan(N,T);
rejRep = nan(1,T);

%% ------------------------------------------------------------------------
% Reorganize parameters of input functions
% -------------------------------------------------------------------------
prior_fcn   = @(x) 1;
prop_fcn    = @(mu,a,b,sigma) rtnorm(a,b,mu,sigma);
propPr_fcn  = @(x,y,a,b,sigma) rtnormpdf(x,a,b,y,sigma);

%% ------------------------------------------------------------------------
% Argument lists for functions being passed to pmmh(...)
% -------------------------------------------------------------------------

prior_args  = {};
prop_args   = {a,b,sigma_};
propPr_args = prop_args;

%% ------------------------------------------------------------------------
% Run PMMH algorithm recursively
% -------------------------------------------------------------------------
tic;

for t_ = 1:T
    logLik_args = {p904(1:t_,1),p805(1:t_,1)};

    [draws_lam,~,rej_prct] = pmmh(prior_fcn,@logLikStatic,prop_fcn,...
        propPr_fcn,lambda_init,N,prior_args,logLik_args,prop_args,propPr_args);

    lRep(:,t_) = draws_lam;
    rejRep(1,t_) = rej_prct;
end

draws_lam = lRep;
if exist(['../matlab_save_files/static_lambda_' save_tail '_vint=' vintage '.mat'], 'file') == 2
    % Some Julia code writes to this same .mat file, so we add an --append
    % to avoid over-writing the variables produced by the Julia code.
    save(['../matlab_save_files/static_lambda_' save_tail '_vint=' vintage '.mat'], 'draws_lam', '-append');
else
    save(['../matlab_save_files/static_lambda_' save_tail '_vint=' vintage '.mat'], 'draws_lam');
end
