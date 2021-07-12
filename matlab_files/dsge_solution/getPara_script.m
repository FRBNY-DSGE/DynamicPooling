%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Created 3/17/2014 by Matt Cocci
% Unrelated model specs deleted from this version of the script 10/28/2019 by William Chen

%% Summary/Motivation
% This script, depending on the mspec will assign values to the parameters
%   used in the mode
% This is done to allow for easy access to parameter values given a
%   parameter vector, rather than copyying the long list of output, as we
%   have below

%% Important Variables
% Important variables that must be set to run this:
%   1. para -- vector which will be assigned out to parameter names
%   2. mspec -- the mspec to use, which is crucial because different models
%       have different parameter names and numbers of parameters

%% Getting Parameter Values
% To access the modal values of the parameters
%   1. run your spec file
%   2. run forecast_mode_est_ant
%   3. set para = params
%   4. run this script

% Where this script is run:
%   1. dsgesolv.m
%   2. measure/meausurMSPEC.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch mspec

    case {805}
        [alp,zeta_p,iota_p,del,ups,Bigphi,s2,h,ppsi,nu_l,zeta_w,iota_w,law,laf,bet,Rstarn,psi1,psi2,psi3,pistar,sigmac,rho,epsp,epsw...
        gam,Lmean,Lstar,gstar,rho_g,rho_b,rho_mu,rho_z,rho_laf,rho_law,rho_rm,rho_pist...
        sig_g,sig_b,sig_mu,sig_z,sig_laf,sig_law,sig_rm,sig_pist,eta_gz,eta_laf,eta_law...
        zstar,rstar,rkstar,wstar,wl_c,cstar,kstar,kbarstar,istar,ystar,pistflag] = getpara00_805(para);

    case {904} % KEEP
        [alp,zeta_p,iota_p,del,ups,Bigphi,s2,h,ppsi,nu_l,zeta_w,iota_w,law,laf,bet,Rstarn,psi1,psi2,psi3,pistar,sigmac,rho,epsp,epsw...
        gam,Lmean,Lstar,gstar,rho_g,rho_b,rho_mu,rho_z,rho_laf,rho_law,rho_rm,rho_sigw,rho_mue,rho_gamm,rho_pist...
        sig_g,sig_b,sig_mu,sig_z,sig_laf,sig_law,sig_rm,sig_sigw,sig_mue,sig_gamm,sig_pist,eta_gz,eta_laf,eta_law...
        zstar,rstar,rkstar,wstar,wl_c,cstar,kstar,kbarstar,istar,ystar,sprd,zeta_spb,gammstar,vstar,nstar,...
        zeta_nRk,zeta_nR,zeta_nsigw,zeta_spsigw,zeta_nmue,zeta_spmue,zeta_nqk,zeta_nn] = getpara00_904(para);
	otherwise
		error('Parameters not assigned. Check getPara_script, measurMSPEC, and dsgesolv');
end
