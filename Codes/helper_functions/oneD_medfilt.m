function med_filt = oneD_medfilt(x,npoints)

%helper function with 1 dimensional median filter implementation
%Inputs : x - signal to be filtered (pass a column vector)
%       : npoints - number of points to be used for the filtering process
%Outputs:med_filt - median filtered data
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/recon3D

nlength = length(x);

med_filt = nan(1,length(x));

if(mod(npoints,2)) %odd number of points
%zero padding
x = [zeros(1,(npoints-1)/2) x' zeros(1,(npoints-1)/2)];
    for i = (npoints+1)/2:1:nlength+(npoints-1)/2
        med_filt(i) = median(x(i-(npoints-1)/2:i+(npoints-1)/2));
    end
med_filt = med_filt((npoints+1)/2:nlength+(npoints-1)/2)';
else %even number of points
    %zero padding
x = [zeros(1,npoints/2) x' zeros(1,npoints/2)];
    
    for i = npoints/2 + 1:1:nlength+npoints/2
        med_filt(i) = median(x(i-npoints/2:i+npoints/2-1));
    end
med_filt = med_filt(npoints/2+1:nlength+npoints/2)';    
end



