%% ------------------------------------------------------------------------
% Add necessary paths
% -------------------------------------------------------------------------
list_path = {'Procedures/Filtering/toolbox_filtering/';...
             'Procedures/';'rtnormM/';'pool_spec/';'priors/';'dsge_solution/'};

addpath(list_path{:});

%% ------------------------------------------------------------------------
% Set parameters
% -------------------------------------------------------------------------
% spec_file = 'R_spec06';
% T = 20;

if ~exist('spec_file','var')
    spec_file = 'spec01';
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

f904 = fopen(['input_data/predictive_density_means_904_10-Jan-1992_to_10-Apr-2011_',testName,p_string],'r');
f805 = fopen(['input_data/predictive_density_means_805_10-Jan-1992_to_10-Apr-2011_',testName,p_string,savefn_tail],'r');
p904 = fread(f904,'single');
p805 = fread(f805,'single');

% get date series
fd904 = fopen(['input_data/predictive_density_fdates_904_10-Jan-1992_to_10-Apr-2011_',testName,p_string],'r');
dt    = fread(fd904,'single');

if exist('T','var')
    dt = dt(1:T,1);
    p904 = p904(1:T,1);
    p805 = p805(1:T,1);
end

%% ------------------------------------------------------------------------
% Reorganize parameters of input functions
% -------------------------------------------------------------------------
[prior_fcn,prior_fcn_sep] = gen_prior(prior_spec);
[prop_fcn,propPr_fcn] = gen_prop(prop_spec);

%% ------------------------------------------------------------------------
% Argument lists for functions being passed to pmmh(...)
% -------------------------------------------------------------------------
filter_args = {p904,p805,G_in,K_in,fK_in,para_names};
prior_args  = {};
prop_args   = {};
propPr_args = prop_args;

if ~isempty(fixed_spec)
    filter_args{end+1} = fixed_spec;
end

%% ------------------------------------------------------------------------
% Run PMMH algorithm
% -------------------------------------------------------------------------
tic;

[draws_para,draws_lam,rej_prct,draws_LL,draws_pri] = pmmh2(prior_fcn,...
    @fnPoolFilter2,prop_fcn,propPr_fcn,para_init,N,prior_args,filter_args,...
    prop_args,propPr_args);

toc;

if exist('T','var')
    draws_lam = draws_lam(:,T);
end
