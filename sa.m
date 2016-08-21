% This function does seasonal adjustment by using US census bureau's
% X-12ARIMA-SEATS algorithm. The user specifies the series to be adjusted
% and the starting date of the series. 

function postsa = sa(tobesa, startdate)

addpath 'C:\Users\thuzh_000\Desktop\Qing\cv\IRIS_Tbx_20150611'; irisstartup
% X-12ARIMA is contained in the IRIS toolbox. Change the above line to
% wherever "IRIS_Tbx_20150611" is installed on your computer.

start = strjoin(startdate);
tobesa(cellfun(@ischar, tobesa)) = {NaN};
tobe = cell2mat(tobesa);

ts = tseries(start, tobe);
saed = x12(ts, 'missing=', true);
postsa = saed.data;

end