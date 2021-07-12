%/* variable indices */ THIS IS "STATES"
y_t       = 1;
c_t       = 2;
i_t       = 3;
qk_t      = 4;
k_t       = 5;
kbar_t    = 6;
u_t       = 7;
rk_t      = 8;
mc_t      = 9;
pi_t      = 10;
muw_t     = 11;%exo
w_t       = 12;
L_t       = 13;
R_t       = 14;
g_t       = 15;%exo
b_t       = 16;%exo
mu_t      = 17;%exo
z_t       = 18;%exo %%%z_t
laf_t     = 19;%exo
laf_t1    = 20;%exo
law_t     = 21;%exo
law_t1    = 22;%exo
rm_t      = 23;%exo
pist_t    = 24;%exo
E_c       = 25;%exp
E_qk      = 26;%exp
E_i       = 27;%exp
E_pi      = 28;%exp
E_L       = 29;%exp
E_rk      = 30;%exp
E_w       = 31;%exp
y_f_t     = 32;
c_f_t     = 33;
i_f_t     = 34;
qk_f_t    = 35;
k_f_t     = 36;
kbar_f_t  = 37;
u_f_t     = 38;
rk_f_t    = 39;
w_f_t     = 40;
L_f_t     = 41;
r_f_t     = 42;

E_c_f     = 43;%exp
E_qk_f    = 44;%exp
E_i_f     = 45;%exp
E_L_f     = 46;%exp
E_rk_f    = 47;%exp

ztil_t    = 48;


%/* shock indices */ EXOGENOUS
g_sh       = 1;
b_sh       = 2;
mu_sh      = 3;
z_sh       = 4;
laf_sh     = 5;
law_sh     = 6;
rm_sh      = 7;
pist_sh    = 8;

nex=8;

%/* expectation errors */
Ec_sh       = 1;
Eqk_sh      = 2;
Ei_sh       = 3;
Epi_sh      = 4;
EL_sh       = 5;
Erk_sh      = 6;
Ew_sh       = 7;
Ec_f_sh     = 8;
Eqk_f_sh    = 9;
Ei_f_sh     = 10;
EL_f_sh     = 11;
Erk_f_sh    = 12;

nstates=48; %46
n_exp=12;
n_exo=11;%9
n_end=nstates-n_exp-n_exo;

nend=n_exp;
%nend=n_end;

if exist('nant','var')
  if nant > 0

    % These are the anticipated shocks. For each there is both an innovation
    % (for new anticipated shocks, calculated in period T only),
    % and a process, so that the shocks can be passed from period to
    % period.

    for i = 1:nant
      eval(strcat('rm_shl',num2str(i),' = ',num2str(nex + i),';'));
      eval(strcat('rm_tl',num2str(i),'  = ',num2str(nstates+i),';'));
    end

    n_exo = n_exo + nant;
    nex = nex + nant;
    nstates=nstates+nant;

  end


end
