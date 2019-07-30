% Template code to perform analysis and plot your 3D reconstructed data
% Fill in template_config_your_experiment_DLC2d.m file with your experiment parameters before running this
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/recon3D

if ~flag_mis == 1
    
%% Filtering as per config file specifications
%the 3D reconstructed data points can be filtered using one of the below two options
%recommended (median filter)
switch whichfilter
    case 1 %moving average
        for i = 1:3*nfeatures
            coords3dall(:,i) = conv(coords3dall(:,i),1/npoints*ones(1,npoints),'same');
            coords3davg(:,i) = conv(coords3davg(:,i),1/npoints*ones(1,npoints),'same');
        end
    case 2 %median filter
        for i = 1:3*nfeatures
            coords3dall(:,i) = oneD_medfilt(coords3dall(:,i),npoints); %if you have Signal Processing toolbox for MATLAB, this function can be replaced by medfilt1
            coords3davg(:,i) = oneD_medfilt(coords3davg(:,i),npoints);
        end
    case 0
        %do nothing
end


if plotresults
    %setting maximum and minimum of axis of visualization
    xvals = coords3dall(:,1:3:nfeatures*3); 
    yvals = coords3dall(:,2:3:nfeatures*3);
    zvals = coords3dall(:,3:3:nfeatures*3);

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

    for t =1:nskip:size(coords3dall,1)

        temp = reshape(coords3dall(t,:),3,nfeatures);
        scatter3(temp(1,:),temp(2,:),temp(3,:),250*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled');  
        hold on
        if ~any(drawline==0)
            for l = 1:size(drawline,1)
                pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
                line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1.5)
            end
        end
        hold off  
        title(sprintf(['3D reconstruction of features from ' num2str(ncams) ' cameras']))

        %view to be set to suit the object being tracked 
        %the view is hardcoded here to suit the demo experiment (try different
        %views to suit your data)
        set(gca,'xtick',[],'ytick',[],'ztick',[],'view',[-10.0500   30.6124],'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax],'Zdir', 'reverse') %change view and axis limits to fit your data

        pause(nskip/fps)  

    end
end

if whichfilter
    if ~exist([exp_path '/' exp_name '/FilteredData3d/Data3d.mat'],'file') 
        mkdir([exp_path '/' exp_name '/FilteredData3d'])
        save([exp_path '/' exp_name '/FilteredData3d/Data3d.mat'],'coords3dall')
    else
    
    answer = questdlg('Filtered data has been previously saved, do you want to overwrite it?','Save new filtered data','Yes','No','Yes');
        % Handle response
        switch answer

            case 'Yes'
                save([exp_path '/' exp_name '/FilteredData3d/Data3d.mat'],'coords3dall')
                disp('Saved the new results')

            case 'No'
                disp('Previously saved filtered data retained in saved file')

        end        
    end
end

end

    