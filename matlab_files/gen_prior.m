function [fun_handle, fun_handle_sep] = gen_prior(prior_spec)

fun_cell = {};

N = size(prior_spec,1);

for i_ = 1:N
    switch prior_spec{i_}{2}
        case 'U'
        %% Uniform
            fun_cell{i_} = ['log(x(',num2str(i_),')./x(',num2str(i_),'))'];
        case 'N'
        %% Normal
            if prior_spec{i_}{3}(2) && prior_spec{i_}{3}(2) ~= 0
                m = num2str(norminv(prior_spec{i_}{3}(1),0,1));
            elseif ~prior_spec{i_}{3}(2)
                m = num2str(prior_spec{i_}{3}(1));
            else
                error('norminv(0) undefined');
            end

            if prior_spec{i_}{4}(2) && prior_spec{i_}{4}(2) ~= 0
                s = num2str(norminv(prior_spec{i_}{4}(1),0,1));
            elseif ~prior_spec{i_}{4}(2)
                s = num2str(prior_spec{i_}{4}(1));
            else
                error('norminv(0) undefined');
            end

            fun_cell{i_} = ['log(normpdf(x(',num2str(i_),'),',...
                m,',',s,'))'];
        case 'B'
        %% Beta
            m = num2str(prior_spec{i_}{3});
            s = num2str(prior_spec{i_}{4});

            fun_cell{i_} = ['log(betapdf2(x(',num2str(i_),'),',...
                m,',',s,'))'];
        case 'IG'
        %% Inverse Gamma
            nu = prior_spec{i_}{4};
            m  = prior_spec{i_}{3};
            k  = num2str(nu/2);
            sbar = m*(nu-2)/nu;
            theta = num2str(nu*sbar/2);

            fun_cell{i_} = ['log(invgampdf(x(',num2str(i_),'),',...
                k,',',theta,'))'];
    end
end

%% Generate Function Handle

% seperate handles (no log)
if nargout > 1
    fun_cell_sep = cellfun(@(x) strcat('@(x) ',regexprep(strrep(strrep(x,'log(',''),...
        '))',')'),'x\([0-9]\)','x')),fun_cell,'UniformOutput',0);
    for i = 1:N
        fun_handle_sep{i} = eval(fun_cell_sep{i});
    end
end

% sum of log
tmp = cell(size(fun_cell));
tmp = strcat(tmp,' + ');
tmp{end} = ';';
fun_cell = strcat(fun_cell,tmp);

eval(['fun_handle = @(x) ',strcat(fun_cell{:})]);
