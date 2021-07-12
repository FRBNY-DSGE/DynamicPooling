function [ok,err,varargout] = script_wrap_fn(script_name,script_extras,env_vars)

try
    if ~isempty(script_extras)
        eval([script_extras,';']);
    end
    
    eval([script_name,';']);
    
    if nargout == 3
        if ~exist('env_vars','var')
            varargout{1} = {};
        else
            tmp = cell(size(env_vars));
            for i_ = 1:length(env_vars)
                tmp{i_} = {env_vars{i_},eval(env_vars{i_})};
            end
            varargout{1} = tmp;
        end
    end
catch err
    ok = 0;
    
    if nargout == 3
        varargout{1} = {};
    end
    return;
end

err = {};
ok = 1;


    