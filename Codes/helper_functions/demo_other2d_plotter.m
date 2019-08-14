% Demo analysis and plotting of 3D reconstructed data
% Fill in template_config_your_experiment_DLC2d.m file with your experiment parameters before running this
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/pose3d

if ~flag_mis == 1
    
%% Filtering as per config file specifications
%the 3D reconstructed data points can be filtered using one of the below two options
%recommended (median filter)
if whichfilter
filtereddata = nan(size(coords3d));
switch whichfilter
    case 1 %moving average
        for i = 1:3*nfeatures
            for imodes = 1:length(modes_3drecon)
                filtereddata(:,i,imodes) = conv(coords3d(:,i,imodes),1/npoints*ones(1,npoints),'same');
            end
        end
    case 2 %median filter
        for i = 1:3*nfeatures
            for imodes = 1:length(modes_3drecon)
                filtereddata(:,i,imodes) = oneD_medfilt(coords3d(:,i,imodes),npoints); %if you have Signal Processing toolbox for MATLAB, this function can be replaced by medfilt1
            end
        end
end
coords3d = filtereddata;
filtereddata =[];
end

%% Edge reconstruction accuracy measurement to compare modes of 3D reconstruction

%3x3 Rubik's cube of standard size (edge length 57 mm)
groundtruth = 57;

%Edge length reconstruction initialization
reconall = nan(nframes,size(drawline,1));
reconbp = nan(nframes,size(drawline,1));
reconavg = nan(nframes,size(drawline,1));

for ipairs = 1:size(drawline,1)
    
    i_1 = drawline(ipairs,1);
    i_2 = drawline(ipairs,2);
    %Edge length reconstruction
    reconall(:,ipairs) = sqrt(sum((coords3d(:,3*(i_1-1)+1:3*i_1,1) - coords3d(:,3*(i_2-1)+1:3*i_2,1)) .^ 2,2));
    reconavg(:,ipairs) = sqrt(sum((coords3d(:,3*(i_1-1)+1:3*i_1,2) - coords3d(:,3*(i_2-1)+1:3*i_2,2)) .^ 2,2));
    
end

avgerrorall = nanmean(abs(reconall(:) - groundtruth));
stderrorall = nanstd(abs(reconall(:) - groundtruth));
disp(['Average error (mm) for reconstruction with all cameras :' num2str(avgerrorall)])

avgerrortrivial = nanmean(abs(reconavg(:) - groundtruth));
disp(['Average error (mm) for reconstruction by averaging over all pairs :' num2str(avgerrortrivial)])


%% Statistics
devall = abs(reconall(:) - groundtruth);
devavg = abs(reconavg(:) - groundtruth);

[p,tbl,stats] = kruskalwallis([devall,devavg],[],'off');
[c] = multcompare(stats,[],'off');
pval_allvsavg = c(1,6); % 6th column returned by multcompare function holds p value
meandiff_allvsavg = c(1,4); % 4th column returned hold difference in mean between all and avg modes

if pval_allvsavg < 0.001 && meandiff_allvsavg < 0
    disp(['Deviations from true edge length is on average significantly smaller (p < '   num2str(0.001)  ') when using all cameras than when averaging over pairs'])
end

%setting maximum and minimum of axis of visualization
xvals = coords3d(:,1:3:nfeatures*3,1); 
yvals = coords3d(:,2:3:nfeatures*3,1);
zvals = coords3d(:,3:3:nfeatures*3,1);

xmax = max(xvals(:));
xmin = min(xvals(:));
ymax = max(yvals(:));
ymin = min(yvals(:));
zmax = max(zvals(:));
zmin = min(zvals(:));

%% Vizualizing Rubik's Cube corners in 3D 
%looping over time to plot cube reconstruction over different time points
figure

colorclass = colormap(jet); %jet is default in DLC 
color_map_self=colorclass(1:nfeatures:64,:);

for t =1:1:size(coords3d,1)
    
    temp = reshape(coords3d(t,:,1),3,nfeatures);
    scatter3(temp(1,:),temp(2,:),temp(3,:),250*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled');  
    hold on
    if ~any(drawline==0)
        for l = 1:size(drawline,1)
            pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
            line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1.5)
        end
    end
    hold off  
    title(sprintf(['3D reconstruction of Rubiks cube corners\n from manual 2D tracked data across ' num2str(ncams) ' cameras']))
    
    %view to be set to suit the object being tracked 
    %the view is hardcoded here to suit the demo experiment (try different
    %views to suit your data)
    set(gca,'xtick',[],'ytick',[],'ztick',[],'view',[-10.0500   30.6124],'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax],'Zdir', 'reverse') %change view and axis limits to fit your data
    
    pause(0.5)  

end


if whichfilter
    if ~exist([exp_path '/' exp_name '/FilteredData3d/Data3d.mat'],'file') 
        mkdir([exp_path '/' exp_name '/FilteredData3d'])
        save([exp_path '/' exp_name '/FilteredData3d/Data3d.mat'],'coords3d')
    else
    
    answer = questdlg('Filtered data has been previously saved, do you want to save again?','Save new filtered data','Yes','No','Yes');
        % Handle response
        switch answer

            case 'Yes'
                save([exp_path '/' exp_name '/FilteredData3d/Data3d.mat'],'coords3d')
                disp('Saved the new results')

            case 'No'
                disp('Previously saved filtered data retained in saved file')

        end        
    end
end
    
end

    