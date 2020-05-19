function [in, eq] = evaluate(obj, varargin)
    % EVALUATE Evaluate linear inequality/equality constraints
    
    %{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2019 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License or,
(at your option) any later version.

OpenCossan is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
        ["optimizationproblem", "referencepoints"], varargin{:});
    
    optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
        ["model", "scaling", "transpose"], {{}, 1, false}, varargin{:});
    
    assert(isa(required.optimizationproblem, 'opencossan.optimization.OptimizationProblem'), ...
        'OpenCossan:optimization:constraint:evaluate',...
        'An OptimizationProblem must be passed using the property name optimizationproblem');
    
    % destructure inputs
    optProb = required.optimizationproblem;
    x = required.referencepoints;
    
    % cobyla passes the inputs transposed for some reason
    if optional.transpose
        x = x';
    end
    
    assert(optProb.NumberOfDesignVariables == size(x,2), ...
        'OpenCossan:optimization:constraint:evaluate',...
        'Number of design Variables not correct');
    
    %% Evaluate constraint(s)
    constraints = zeros(size(x, 1), length(obj));
    
    % memoized model passed
    if ~isempty(optional.model)
        output = optional.model(x);
    elseif ~isempty(optProb.Model)
        input = optProb.Input.setDesignVariable('CSnames',optProb.DesignVariableNames,'Mvalues',x);
        input = input.getTable();
        result = apply(optProb.Model, input);
        output = result.TableValues;
        opencossan.optimization.OptimizationRecorder.recordModelEvaluations(output);
    else
        input = array2table(x);
        input.Properties.VariableNames = optProb.DesignVariableNames;
        output = optProb.Input.completeSamples(input);
    end
    
    % loop over all constraints
    for j = 1:numel(obj)
        TableOutConstrains = evaluate@opencossan.workers.Mio(obj(j), ...
            output(:,obj(j).InputNames));
        
        constraints(:,j) = TableOutConstrains.(obj(j).OutputNames{1});
    end
    
    % Scale constraints
    constraints = constraints / optional.scaling;
    
    % Assign output to the inequality and equality constrains
    in = constraints(:,[obj.IsInequality]);
    eq = constraints(:,~[obj.IsInequality]);
    
    % record constraint values
    opencossan.optimization.OptimizationRecorder.recordConstraints(x, constraints);
    
end

