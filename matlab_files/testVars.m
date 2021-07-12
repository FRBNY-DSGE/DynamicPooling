function test = testVars(testName,varnames,semicond)

if semicond
    testName = [testName,'_semicond'];
end

if isempty(varnames) && ~isempty(strfind(testName,'all_common'))
    error('doh!');
end


switch testName

    case 'output_and_inflation_annualized'

        test = struct('vars', { { 'Output Growth','GDP Deflator' } },...
                                  'adj',  { [4,4] },...
                                  'k',    { 4 } );

    case 'output_and_inflation_annualized_semicond'

        test = struct('vars', { { 'Output Growth','GDP Deflator' } },...
            'adj',  { [4,4] },...
            'k',    { 4 } );

    case 'output_and_inflation'

        test = struct('vars', { { 'Output Growth','GDP Deflator' } },...
            'adj',  { [4,4] },...
            'k',    { 1 } );

    case 'output_and_inflation_semicond'

        test = struct('vars', { { 'Output Growth','GDP Deflator' } },...
            'adj',  { [4,4] },...
            'k',    { 1 } );

    case 'output_annualized'

        test = struct('vars', { { 'Output Growth' } },...
                                  'adj',  { 4 },...
                                  'k',    { 1 } );

    case 'output_4Q'

        test = struct('vars', { { 'Output Growth' } },...
                                  'adj',  { 4 },...
                                  'k',    { 4 } );
    case 'output_4Q_semicond'

        test = struct('vars', { { 'Output Growth' } },...
     		                  'adj',  { 4 },...
		                  'k',    { 4 } );

    case 'inflation_4Q'

        test = struct('vars', { { 'GDP Deflator' } },...
	       	                  'adj',  { 4 },...
		                  'k',    { 4 } );

    case 'inflation_4Q_semicond'

        test = struct('vars', { { 'GDP Deflator' } },...
	    	                  'adj',  { 4 },...
		                  'k',    { 4 } );

    case 'all_common_variables_annualized'

        exclude = { 'Spread','Long Inf' };
        obsList = setdiff( varnames, exclude );

        test = struct('vars', { obsList },...
                      'adj',  { 4*ones(1,length(obsList)) },...
                      'k',    { ones(1,length(obsList)) } );

    case 'all_common_variables_annualized_semicond'

        exclude = { 'Spread','Long Inf','Interest Rate' };
        obsList = setdiff( varnames, exclude );

        test = struct('vars', { obsList },...
                      'adj',  { 4*ones(1,length(obsList)) },...
                      'k',    { ones(1,length(obsList)) } );

    otherwise
        error(['Woops! ',testName,' is not a valid test name.']);

end
