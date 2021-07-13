# DynamicPooling
These files contain the code and data necessary to replicate the results from Del Negro, Hasegawa, and Schorfheide ([2016](https://www.sciencedirect.com/science/article/abs/pii/S0304407616300094#:~:text=This%20dynamic%20linear%20prediction%20pool,to%20lie%20on%20a%20simplex.&text=These%20pools%20are%20optimal%20in,the%20pool's%20historic%20forecast%20performance)). We provide the data used to produce the results of the original paper as well as the corrected data used to produce the results contained in the [corrigendum](). 

## Installation
MATLAB14a is required to run these files locally on your machine. To run the files, download them from this github repository. No further installation is necessary. 

## Usage
To replicate the results shown in the corrigendum, follow this workflow.
We assume that the predictive densities have already been calculated or that the user
will utilize the ones that are provided by this replication folder. 

* Run `static_recursive.m` twice, once with `save_tail = 'ss1'`
  and once with `save_tail = 'ss2'` (see line 42). The estimation vintage `vintage`
  should also be updated to avoid over-writing previous results. Note that, unlike the other MATLAB scripts,
  the vintage date format is "YYMMDD".
* Run `recursive_inference.m` for each specification of the dynamic pool you want.
  Go to lines 16-26. You'll want to change `vint` to avoid over-writing the original results.
  You will also need to update `spec_file` and `savefn_tail`
  to run this script for six permutations:
    1. `spec_file = 'R_spec04'`, `savefn_tail = ''`
    2. `spec_file = 'R_spec04'`, `savefn_tail = '_correct'`
    3. `spec_file = 'R_spec06'`, `savefn_tail = ''`
    4. `spec_file = 'R_spec06'`, `savefn_tail = '_correct'`
    5. `spec_file = 'R_spec13'`, `savefn_tail = ''`
    6. `spec_file = 'R_spec13'`, `savefn_tail = '_correct'`
* Run `produce_3d_histogram.m` to produce the 3D histograms (Figures 3 and 4 in the corrigendum).
* Change directories to `make_plots/`.
* Run `make_plots.m` multiple times to obtain Figures 1, 2, 5, 6, 7, and 9 as well as Table 1 as follows:
  * Re-run the script 6 times to generate results for each permutation of `estim_fn`
    (will be either `"wrongorigmatlab"` or `"right805orig904"`) and `prior`
    (`1`, `2`, or `3`)
  * Unless you want to use different vintages, leave `static_vintage` and `vintage_date`
    as `"210615"`.
  * Figure 1 doesn't depend on `estim_fn` or `prior`.
  *  `estim_fn = "wrongorigmatlab"`, `prior = 1` -> Figure 2(a), Figure 5(a), and Row 1 of Table 1.
  *  `estim_fn = "right805orig904"`, `prior = 1` -> Figure 2(b), Figure 5(b), and Row 2 of Table 1.
  *  `estim_fn = "wrongorigmatlab"`, `prior = 2` -> Figure 6(a), Figure 7(a), Figure 9(a), Figure 10(a), and Row 3 of Table 1.
  *  `estim_fn = "right805orig904"`, `prior = 2` -> Figure 6(b), Figure 7(b), Figure 9(b), Figure 10(b), and Row 4 of Table 1.
  *  `estim_fn = "wrongorigmatlab"`, `prior = 3` -> Row 5 of Table 1.
  *  `estim_fn =  "right805orig904"`, `prior = 3` -> Row 6 of Table 1. 
* Run `make_fig8.m` to create Figure 8. To replicate the figure exactly, you must set `use_matlab_draws = true`.

## Directory Structure 
* `matlab_files/`: MATLAB scripts for 
  * computing predictive densities from processed real-time data
  * estimating dynamic pool, static pool, and BMA
  * plotting results, contained within \path{make_plots}
* `matlab_save_files/`: common directory for MATLAB output files produced from MATLAB scripts
    * mat files containing parameter and lambda draws specified by data vintage and prior
    * mat files containing static lambda values specified by data vintage 

## Description of MATLAB Files
The MATLAB code can be partitioned into 5 parts: computing predictive density, estimation using a pooling method, analysis of estimation results, plotting, and helper functions. Below, we provide brief descriptions of most scripts found in `matlab_files/`.
* Predictive Density code
    * `calcPredDens.m`: master script for computing predictive density, given model and observables data
    *  `dsge_solution/`: folder of scripts related to solution of DSGEs (from structural matrices to reduced form)
    *  `predDens.m`: function computing $h$-step ahead predictive density
* Pooling master scripts
    * `compute_bma.m`: compute BMA weights 
    * `static_recursive.m`: compute real-time static pool estimation to obtain the real-time posterior
    * `parameter_inference.m`: compute dynamic pool estimation for a given information set
    * `recursive_inference.m`: compute real-time dynamic pool estimation  to obtain the real-time posterior
* Pooling code 
    * `pmmh2.m`: estimates the dynamic pool hyperparameters using Metropolis-Hastings with a particle filter
    * `pmmh.m`: estimates the Bayesian static pool parameter $\lambda$ using Metropolis-Hastings
    *  `fnPoolFilter.m`: particle filter (for likelihood calculation) 
    *  `logLikStatic.m`: likelihood function for static pool
    *  `gen_prior.m`: construct prior function handles for code computing priors found in `priors/`
    *   `gen_prop.m`: construct proposal distribution for Metropolis-Hastings
    *   `lamfcast.m`: forecast of `lambda_t` in h-periods
* Analysis code
    * `hist_evol.m`: function for computing 3D histogram
    * `produce_3d_histogram.m`: script for producing the 3D evolution histogram of posterior using output from MATLAB estimations
* Plotting code within `make_plots/`
    * `make_plots.m`: script for producing plots within the corrigendum
    * `estimate_bma.m`: function used to for plotting bma results.
    * `make_fig8.m`: script for producing figure 8 from the corrigendum.
    * `rgb.m`: helper function for translating colors to rgb values while plotting.
* Helper functions
    * `script_wrap_fn.m`: wrapper function assisting `recursive_inference.m`
    * `selectEst.m`: load estimation results
    * `testVars.m`: determines for which variables to compute predictive densities and what kind of densities
* Other helper folders
    * `input_data/`:
        * holds input data to compute predictive densities
        * output directory for predictive densities since the pooling methods use these densities as inputs
    * `model_spec/`: spec files for DSGE models
    * `pool_spec/`: spec files for dynamic pools
    * `priors/`: holds functions that compute prior densities
    * `Procedures/`:
        *  multinomial resampling
        *  `rgb.m` function
    * `rtnormM/`: pseudorandom numbers from a truncated Gaussian distribution

## Disclaimer
Copyright Federal Reserve Bank of New York. You may reproduce, use, modify, make derivative works of, and distribute and this code in whole or in part so long as you keep this notice in the documentation associated with any distributed works. Neither the name of the Federal Reserve Bank of New York (FRBNY) nor the names of any of the authors may be used to endorse or promote works derived from this code without prior written permission. Portions of the code attributed to third parties are subject to applicable third party licenses and rights. By your use of this code you accept this license and any applicable third party license.

THIS CODE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT ANY WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY WARRANTIES OR CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, EXCEPT TO THE EXTENT THAT THESE DISCLAIMERS ARE HELD TO BE LEGALLY INVALID. FRBNY IS NOT, UNDER ANY CIRCUMSTANCES, LIABLE TO YOU FOR DAMAGES OF ANY KIND ARISING OUT OF OR IN CONNECTION WITH USE OF OR INABILITY TO USE THE CODE, INCLUDING, BUT NOT LIMITED TO DIRECT, INDIRECT, INCIDENTAL, CONSEQUENTIAL, PUNITIVE, SPECIAL OR EXEMPLARY DAMAGES, WHETHER BASED ON BREACH OF CONTRACT, BREACH OF WARRANTY, TORT OR OTHER LEGAL OR EQUITABLE THEORY, EVEN IF FRBNY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES OR LOSS AND REGARDLESS OF WHETHER SUCH DAMAGES OR LOSS IS FORESEEABLE.
