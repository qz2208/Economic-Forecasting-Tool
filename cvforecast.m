%% This is the main function that does cross-validation forecasting, and plots the fan chart.

function [forecasting, varforecast, nintyquan, seventyfivequan, twentyfivequan, tenquan, cv, pweights, vweights, vars3] = cvforecast(X, y, h) 
 

%% Setting things up
  %X(X==0) = nan;
  %y(y==0) = nan;
  
  h = cell2mat(h);
  X(cellfun(@ischar, X)) = {NaN};
  X = cell2mat(X);
  y(cellfun(@ischar, y)) = {NaN};
  y = cell2mat(y);
  
  varforecast = zeros(1,h);  % variance forecasts
 
  secell = cell(1,h);  % each cell is a vector of squared errors to be used in variance forecast
  cv = zeros(1, h);    % cross-validation criterion
  forecasting = zeros(1, h);   % point forecasts
  n = size(X, 1);  % number of periods
  m = size(X, 2);  % number of explanatory variables
  number = pow2(m) - 1;  % This is the number of models. All possible 
                         % combinations of the explanatory variables,
                         % except where no variable is selected.
  % w = zeros(number, h);
  
  pweights = zeros(number, 0);  % weights of all models in point forecast
  vweights = zeros(number, 0);  % weights of all models in variance forecast
  
  %% Generating all possible combinations of models using a binary representation
  
  vars = 1:number;
  vars2 = dec2bin(vars);
  vars3 = zeros(number, m);
  for i = 1:number
      for j = 1:m
          vars3(i,j) = str2double(vars2(i,j));
      end
  end
  
  vars4 = logical(vars3);
   
  %% For each step, generate point forecast, using the indivstep function

  for k = 1:h
      
      [forecasting(k), cv(k), secell{1,k}, temppw] = indivstep(X,y,k,number,n,vars4);
      pweights = cat(2, pweights, temppw);
  
  end
   
%% For each step, generate variance forecast

for k = 1:h
    se = secell{1,k};
    newn = size(se, 1);
    [varforecast(k),~,~,tempvw] = indivstep(X((n-newn+1):n, :),se,k,number,newn,vars4);
    if varforecast(k)<0 
        varforecast(k) = 0; 
    end
    vweights = cat(2, vweights, tempvw);
end

%% Forecast quantiles, assuming normal distribution of error term

sdforecast = sqrt(varforecast);   % forecast standard deviation
nintyquan = forecasting + 1.285 * sdforecast;        % 90% quantile
seventyfivequan = forecasting + 0.675 * sdforecast;  % 75% quantile
twentyfivequan = forecasting - 0.675 * sdforecast;   % 25% quantile
tenquan = forecasting - 1.285 * sdforecast;          % 10% quantile

%% Plotting the fan chart
yplot = [transpose(y),forecasting];
horizon = size(yplot, 2);
knownhorizon = size(y, 1);
h1 = plot(1:knownhorizon, transpose(y),'k');
line([knownhorizon knownhorizon], ylim);   % vertical line seperating history and forecast
hold on
h2 = plot(knownhorizon:horizon, [y(knownhorizon),forecasting],'g');
h3 = plot(knownhorizon:horizon, [y(knownhorizon),nintyquan], '--r');
h4 = plot(knownhorizon:horizon, [y(knownhorizon),seventyfivequan], '--b');
h5 = plot(knownhorizon:horizon, [y(knownhorizon),twentyfivequan], '--b');
h6 = plot(knownhorizon:horizon, [y(knownhorizon),tenquan], '--r');
legend([h1 h2 h3 h4 h5 h6], {'historical data','point forecast','90% forecast quantile','75% forecast quantile','25% forecast quantile','10% forecast quantile'}, 'FontSize',20,'FontWeight','bold');
hold off

end