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
    
    if have2Dtrackedvideos 

        disp('Loading your video data. This could take awhile...')
        disp('Please consider increasing nskip value on config file if the visualization takes too long')

        k = 1;
        for t =1:nskip:size(coords3d,1)
            movie1(:,:,:,k) = read(cam{1,1}, t);
            k = k+1;
        end
    
    elseif have2Dtrackedimages %when you have 2D tracked images
        
        files = dir([path2Dtrackedimages_folder '/*' format_of_images]);
        if isempty(files) 
            flag_mis = 1;
            uiwait(msgbox(sprintf('No 2D tracked images found at the location indicated by config file'),'Problem detected'))
            return
        end
        k=1;
        for t =1:nskip:length(files)
            movie1(:,:,:,k) = imread([files(t).folder '/' files(t).name]);
            k = k+1;
        end
        
           
    end
    

    
    if have2Dtrackedvideos || have2Dtrackedimages
        figure1 = figure('units','normalized','OuterPosition',[0.044 0.206 0.4 0.4]);
        colorclass = colormap(jet); %jet is default in DLC 
        color_map_self=colorclass(ceil(linspace(1,64,nfeatures)),:);
        
        % Create axes for 3D reconstructed data
        ha(1) = axes('Parent',figure1,'Position',[0.08 0.1 0.4 0.8]);

        % Create axes for camera 2 data
        ha(2) = axes('Parent',figure1,'Position',[0.55 0.1 0.4 0.8]);
    
    else
        figure1 =figure('units','normalized','OuterPosition',[0.044 0.206 0.5 0.8]);
        colorclass = colormap(jet); %jet is default in DLC 
        color_map_self=colorclass(ceil(linspace(1,64,nfeatures)),:);
        ha(1) = axes('Parent',figure1,'Position',[0.1 0.1 0.8 0.8]);
    end
    
    tic
    k = 1;
    for t =1:nskip:size(coords3d,1)

        temp = reshape(coords3d(t,:,1),3,nfeatures);
        scatter3(temp(1,:),temp(2,:),temp(3,:),250*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', ha(1));  
        hold on
        if ~any(drawline==0)
            for l = 1:size(drawline,1)
                pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
                line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1.5,'Parent', ha(1))
            end
        end
        hold off  
        set(ha(1),'view',[-127.1,21.8],'Zdir', 'reverse','Ydir', 'reverse')
        title(sprintf(['3D reconstruction of features from ' num2str(ncams) ' cameras']))

        %view to be set to suit the object being tracked 
        %the view is hardcoded here to suit the demo experiment (try different
        %views to suit your data)
        set(ha(1),'xtick',[],'ytick',[],'ztick',[],'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax]) %change view and axis limits to suit your data
        
        if have2Dtrackedvideos || have2Dtrackedimages
            imagesc(movie1(:,:,:,k),'Parent', ha(2))
            hold on
            scatter(DataAll(t,1:2:2*nfeatures,ncams),DataAll(t,2:2:2*nfeatures,ncams),250*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', ha(2)); 
            set(ha(2),'xtick',[],'ytick',[],'ztick',[])
        end
        drawnow
        
        if have2Dtrackedvideos == 1
            pause(nskip/cam{1,1}.Framerate) 
        else
            pause(0.1)
        end
                     
        if toc > 60 %after every 60 seconds prompts user to check if she/he wants to stop watching movie
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
        k = k+1;

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


%% Computing errors in reconstructed 3D data

if calc_error == 1

%Edge length reconstruction initialization

    recondata = nan(size(coords3d,1),size(drawline,1),length(modes_3drecon));
    errorinrecon = nan(size(coords3d,1),size(drawline,1),length(modes_3drecon));

    for imodes = 1:length(modes_3drecon)

        for ipairs = 1:size(drawline,1)

            i_1 = drawline(ipairs,1);
            i_2 = drawline(ipairs,2);
            %Edge length reconstruction
            recondata(:,ipairs,imodes) = sqrt(sum((coords3d(:,3*(i_1-1)+1:3*i_1,imodes) - coords3d(:,3*(i_2-1)+1:3*i_2,imodes)) .^ 2,2));
            errorinrecon(:,ipairs,imodes) = abs(recondata(:,ipairs,imodes) - ground_truth(ipairs));

        end
        temperror = errorinrecon(:,:,imodes);
        avgerrorall = nanmean(temperror(:));
        stderrorall = nanstd(temperror(:));
        disp(['Average error (mm) for reconstruction with mode ' modes_3drecon{imodes} ':' num2str(avgerrorall) ' ' char(177) ' ' num2str(stderrorall)])
        disp('Error values corresponding to individual time-points and line-segments on the skeleton available in the workspace variable errorinrecond(timeXlinesegmentsXmodes_of_3Dreconstruction)')

    end
    

end

end

    
