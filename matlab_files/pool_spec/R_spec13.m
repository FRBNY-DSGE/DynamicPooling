%% ------------------------------------------------------------------------
% spec13.m: specify prior and pmmh proposal distributions for model
% specification 13
% -------------------------------------------------------------------------

%% number of parameters
para_names   = {'rho','sigma2'};
k            = length(para_names);

%% Prior specification
prior_spec   = {{'rho','B',0.8,0.1};...
                {'sigma2','IG',1,4}};

%% Proposal specification
prop_spec    = {{'rho','TrN',[0.15,0,1]};...
                {'sigma2','TrN',[0.5,0,Inf]}};

%% Parameter support
support_spec = {{'rho',[0,1]};...
                {'sigma2',[0,Inf]}};

%% Initial parameter values
para_init    = [0.5,1];

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
