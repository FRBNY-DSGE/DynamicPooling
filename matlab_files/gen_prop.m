function [prop_handle,propPr_handle] = gen_prop(prop_spec)

fun_cell = {};
fun_cell_pr = {};

N = size(prop_spec,1);

for i_ = 1:N
    switch prop_spec{i_}{2}
        case 'N'
        %% Normal
            s = num2str(prop_spec{i_}{3});
            fun_cell{i_} = ['x(i_) + randn()*',s];
            fun_cell_pr{i_} = ['log(normpdf(x(',num2str(i_),'),y(',...
                num2str(i_),'),',s,'))'];
        case 'TrN'
        %% Truncated Normal
            s = num2str(prop_spec{i_}{3}(1));
            a = num2str(prop_spec{i_}{3}(2));
            b = num2str(prop_spec{i_}{3}(3));
            fun_cell{i_} = ['rtnorm(',a,',',b,',x(',num2str(i_),...
                '),',s,')'];
            fun_cell_pr{i_} = ['log(rtnormpdf(x(',num2str(i_),'),'...
                ,a,',',b,',y(',num2str(i_),'),',s,'))'];
    end
end

%% Generate Function Handles
% Proposal function
tmp = cell(size(fun_cell));
tmp = strcat(tmp,',');
tmp{end} = '';
fun_cell = strcat(fun_cell,tmp);

eval(['prop_handle = @(x) [',strcat(fun_cell{:}),'];']);

% Log Proposal Probability
tmp = cell(size(fun_cell_pr));
tmp = strcat(tmp,' + ');
tmp{end} = ';';
fun_cell_pr = strcat(fun_cell_pr,tmp);

eval(['propPr_handle = @(x,y) ',strcat(fun_cell_pr{:})]);
