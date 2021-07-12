function ax = setmyfig(fig, wdsize)
% wdsize = [2.5, 1.1, 6, 6];

set(fig, 'color', 'w');
set(fig, 'units', 'inches');
set(fig, 'outerposition', wdsize);
set(fig, 'paperpositionmode', 'auto');
ax = axes('FontSize', 15);