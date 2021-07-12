function [path,file] = selectEst(mspec)

if mspec == 904
    path = 'input_data/';
    file = 'realtime_parallel_FULL_BC_estimationResults_1_m90493547000_199150-201100.mat';
elseif mspec == 805
    path = 'input_data/';
    file = 'realtime_parallel_FULL_BC_estimationResults_1_m80592617000_199150-201100.mat';
else
    error(['model ',num2str(mspec),' is not supported by calcPredDens.m']);
end
