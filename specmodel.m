% This function does regression and calculate leave-h-out residuals within a specific model.
% Notice that in the input to this function, X should have one more row
% than y, reflecting the fact that we need the latest x for forecasting.
% The user also needs to make sure that there are no missing data in the
% last row of X, otherwise the function will return NaN.


function [etilde, forecast] = specmodel(X,y,h)
 Xreg = X(1:(size(X,1)-1),:);  % Part of X used in regression. That is, excluding the last row.
 mdl = fitlm(Xreg,y);          % linear regression
 
 aug = [1, X(end,:)];          % add the constant term
 forecast = aug * mdl.Coefficients{:,1};
 % cons = ones(size(Xreg,1), 1);
 % Xaug = cat(2, cons, Xreg);
 
 % e = transpose(y - Xaug * mdl.Coefficients{:,1});
 
 %% calculate leave-h-out residuals
 etilde = 1:size(Xreg,1);
 for i = 1:size(Xreg,1)
     exclude = (i-h+1): (i+h-1);   % observations to be left out
     if exclude(1) < 1
         exclude = 1: (i+h-1);
     end
     if exclude(end) > size(Xreg,1)
         exclude = exclude(1): size(Xreg,1);
     end
     yex = y(~ismember(y,y(exclude)));
     Xex = Xreg(~ismember(y,y(exclude)),:);
     exmdl = fitlm(Xex, yex);
     aug = [1, Xreg(i,:)];
     etilde(i) = y(i) - aug * exmdl.Coefficients{:,1};
 end
end


