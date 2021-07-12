%% ------------------------------------------------------------------------
% LR_spec01.m: specification 01 for static_recursive.m
% -------------------------------------------------------------------------

%% Sampling specifications
N = 10000;
nb = 1000;

%% Predictive density specifications
testName = 'output_and_inflation_annualized';
semicond = 1;

%% Lambda proposal density specifications
lambda_init = 0.5;
a     = 0;
b     = 1;
sigma_ = 0.5;

%% Save results?
save_results = 1;
