%% ------------------------------------------------------------------------
% spec04.m: specify prior and pmmh proposal distributions for model
% specification 04
% -------------------------------------------------------------------------

%% number of parameters
para_names   = {'rho'};
k            = length(para_names);

%% Prior specification
prior_spec   = {{'rho','U'}};

%% Proposal specification
prop_spec    = {{'rho','TrN',[0.15,0,1]}};

%% Parameter support
support_spec = {{'rho',[0,1]}};

%% Initial parameter values
para_init    = [0.5];

%% Fixed parameters
fixed_spec   = {};

%% Other specifications
N            = 10000;
G_in         = 1;
K_in         = 5000;
fK_in        = 0.67;
nb           = 1000;

recursive    = 1;
testName     = 'output_and_inflation_annualized';
semicond     = 1;

save_results = 0;
save_results_master = 1;
