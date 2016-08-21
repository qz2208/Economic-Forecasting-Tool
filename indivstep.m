% This is the function that does individual-step forecasting using model 
% combination determined by cross-validation. It returns four elements:
% point forecast, cross-validation (which is an estimate of MSFE), a vector of
% squared errors to be used in variance forecast, and the weight associated
% with each model.

function [forecasting, cv, se, w] = indivstep(X,y,k,number,n,vars4)  
  forecast = zeros(0,number);  % used to record forecast given by each model
  etilde = zeros(0,n-k-1);     % matrix of leave-h-out residuals
  % e = zeros(0,n-k-1);
  
  % for each model, do the following:
  
  for i = 1:number
      %% Select variables for this particular model. 
      % Each variable has two lags. Two lags of the LHS variable (y) are
      % also included in the regressor.
      
      Xsel = X(:,vars4(i,:));
      msel = size(Xsel, 2);
      Xnew = [Xsel([1:(n-k-1),n],1), Xsel([2:(n-k),n],1)];
      if msel>1
      for j = 2:msel
        Xnew = cat(2, Xnew, Xsel([1:(n-k-1),n],j));
        Xnew = cat(2, Xnew, Xsel([2:(n-k),n],j));
      end
      end
      Xnew = cat(2,y([2:(n-k),n]),Xnew);
      Xnew = cat(2,y([1:(n-k-1),n]),Xnew);
      ynew = y((2+k):n);
      
      %% For this particular model, calculate its leave-h-out residuals and the forecast 
      % the specmodel function is invoked
      
      [etildetemp, forecast(i)] = specmodel(Xnew,ynew,k);
      etilde = cat(1, etilde, etildetemp);
      % e = cat(1, e, etemp);
      
      
  end
  
  stilde = etilde * transpose(etilde) / (n-k-1);
  
  %% solve for optimal weight by quandratic programming
  H = stilde;
  f = zeros(number, 1);
  A = zeros(1, number);
  b = 0;
  Aeq = ones(1, number);
  beq = 1;
  lb = zeros(number, 1);
  ub = ones(number, 1);
  
  [w,cv] = quadprog(H,f,A,b,Aeq,beq,lb,ub);
  
  %% combination forecasting and vector of squared errors
  forecasting = forecast * w;
  se = transpose((transpose(w) * etilde).^2);
  
end