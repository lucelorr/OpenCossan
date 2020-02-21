function fh = plotMarkovChains(obj)
    %PLOTMARKOVCHAIN This method plots the markov chains for each level of the
    %subset simulation
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/plot@SubsetOutput
    %
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    fh = figure();
    hold on;
    box on;
    grid on;
    
    chains = obj.MarkovChains;
    labels = strings(obj.NumberOfLevels + 1, 0);
    
    
    scatter(chains(1).ChainStart{:,1}, chains(1).ChainStart{:,2}, 'filled');
    labels(1) = "Initial Samples";
    
    for i = 1:obj.NumberOfLevels
        scatter(chains(i).ChainEnd{:,1}, chains(i).ChainEnd{:,2}, 'filled');
        labels(i + 1) = sprintf("Level_%i", i);
    end
    
    legend(labels);
    
    hold off;
end


