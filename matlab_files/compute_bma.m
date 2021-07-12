% This file computes the BMA weights on predictive densities

%% ------------------------------------------------------------------------
% Add necessary paths
% -------------------------------------------------------------------------
list_path = {'Procedures/Filtering/toolbox_filtering/';...
    'Procedures/';'rtnormM/';'pool_spec/';'priors/'};

addpath(list_path{:})

%% ------------------------------------------------------------------------
% Set parameters
% -------------------------------------------------------------------------
if ~exist('spec_file','var')
    spec_file = 'R_spec01';
end
eval(spec_file);
test = testVars(testName,{},semicond);
prior = 0.5; % prior on SWFF

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
f805 = fopen(['input_data/predictive_density_means_805_10-Jan-1992_to_10-Apr-2011_',testName,p_string],'r');
p904 = fread(f904,'single');
p805 = fread(f805,'single');

% get date series
fd904 = fopen(['input_data/predictive_density_fdates_904_10-Jan-1992_to_10-Apr-2011_',testName,p_string],'r');
dt    = fread(fd904,'single');

T = length(dt);

lam_bma = zeros(T, 1);
lam_bma(1) = prior * p904(1) / (prior * p904(1) + (1 - prior) * p805(1));
for t = 2:T
	lam_bma(t) = lam_bma(t-1) * p904(t) / (lam_bma(t-1) * p904(t) + (1 - lam_bma(t-1)) * p805(t));
end
