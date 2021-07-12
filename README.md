# DynamicPooling
These files contain the code and data necessary to replicate the results from Del Negro, Hasegawa, and Schorfheide ([2016](https://www.sciencedirect.com/science/article/abs/pii/S0304407616300094#:~:text=This%20dynamic%20linear%20prediction%20pool,to%20lie%20on%20a%20simplex.&text=These%20pools%20are%20optimal%20in,the%20pool's%20historic%20forecast%20performance)). We provide the data used to produce the results of the original paper as well as the corrected data used to produce the results contained in the [corrigendum](). 

## Installation
Matlab14a is required to run these files locally on your machine. To run the files, download them from this github repository. No further installation is necessary. 

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
