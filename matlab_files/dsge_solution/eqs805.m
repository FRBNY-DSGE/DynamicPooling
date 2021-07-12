    %% Equilibrium conditions
euler  = 1;
inv    = 2;
capval = 3;
output = 4;
caputl = 5;
capsrv = 6;
capev  = 7;
mkupp  = 8;
phlps  = 9;
caprnt = 10;
msub   = 11;
wage   = 12;
mp     = 13;
res    = 14;
eq_g      = 15;
eq_b      = 16;
eq_mu     = 17;
eq_z      = 18;
eq_laf    = 19;
eq_law    = 20;
eq_rm     = 21;
eq_laf1   = 22;
eq_law1   = 23;
eq_Ec     = 24;
eq_Eqk    = 25;
eq_Ei     = 26;
eq_Epi    = 27;
eq_EL     = 28;
eq_Erk    = 29;
eq_Ew     = 30;
euler_f  = 31;
inv_f    = 32;
capval_f   = 33;
output_f = 34;
caputl_f = 35;
capsrv_f = 36;
capev_f  = 37;
mkupp_f  = 38;
caprnt_f = 39;
msub_f  = 40;
res_f    = 41;
eq_Ec_f     = 42;
eq_Eqk_f     = 43;
eq_Ei_f     = 44;
eq_EL_f     = 45;
eq_Erk_f    = 46;

eq_ztil = 47;
eq_pist = 48;

n_eqc = 48;

if exist('nant','var')
  if nant > 0

    % These are the anticipated shocks. For each there is both an innovation
    % (for new anticipated shocks, calculated in period T only),
    % and a process, so that the shocks can be passed from period to
    % period.

    for i = 1:nant
      eval(strcat('eq_rml',num2str(i),'  = ',num2str(n_eqc+i),';'));
    end

    n_eqc=n_eqc+nant;

  end


end
