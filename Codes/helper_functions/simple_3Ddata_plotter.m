% Template code to perform analysis and plot your 3D reconstructed data
% called by the main_pose3d script
%
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


if plotresults
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
    tic
    for t =1:nskip:size(coords3d,1)

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
        title(sprintf(['3D reconstruction of features from ' num2str(ncams) ' cameras']))

        %view to be set to suit the object being tracked 
        %the view is hardcoded here to suit the demo experiment (try different
        %views to suit your data)
        set(gca,'xtick',[],'ytick',[],'ztick',[],'view',[-10.0500   30.6124],'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax],'Zdir', 'reverse') %change view and axis limits to fit your data

        pause(nskip/fps)  
        
        
        if toc > 60 %after every 60 seconds prompts user to stop watching movie
            answer = questdlg('Stop watching movie and save all results?','Save results?','Yes, save results', ...
            'No, continue watching','Yes, save results');
            % Handle response
            switch answer
                case 'Yes, save results'
                    break
                case 'No, continue watching'
                    tic
                    continue
            end
        end

    end
end

if whichfilter
    if ~exist([exp_path '/' exp_name '/FilteredData3d/Data3d.mat'],'file') 
        mkdir([exp_path '/' exp_name '/FilteredData3d'])
        save([exp_path '/' exp_name '/FilteredData3d/Data3d.mat'],'coords3d')
    else
    
    answer = questdlg('Filtered data has been previously saved, do you want to save again?','Save','Yes','No','Yes');
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

    