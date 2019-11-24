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
%% Filtering as specified in config file
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
    reconbp(:,ipairs) = sqrt(sum((coords3d(:,3*(i_1-1)+1:3*i_1,2) - coords3d(:,3*(i_2-1)+1:3*i_2,2)) .^ 2,2));
    reconavg(:,ipairs) = sqrt(sum((coords3d(:,3*(i_1-1)+1:3*i_1,3) - coords3d(:,3*(i_2-1)+1:3*i_2,3)) .^ 2,2));
    
end

avgerrorall = nanmean(abs(reconall(:) - groundtruth));
stderrorall = nanstd(abs(reconall(:) - groundtruth));
disp(['Average error (mm) for reconstruction with all cameras :' num2str(avgerrorall)])

avgerrorbp = nanmean(abs(reconbp(:) - groundtruth));
disp(['Average error (mm) for reconstruction with best camera pair per time and feature :' num2str(avgerrorbp)])

avgerrortrivial = nanmean(abs(reconavg(:) - groundtruth));
disp(['Average error (mm) for reconstruction by averaging over all pairs :' num2str(avgerrortrivial)])


%% Statistics
devall = abs(reconall(:) - groundtruth);
devbp = abs(reconbp(:) - groundtruth);
devavg = abs(reconavg(:) - groundtruth);

[p,tbl,stats] = kruskalwallis([devall,devbp,devavg],[],'off');
[c] = multcompare(stats,[],'off');

pval_allvsbp = c(1,6); % 6th column returned by multcompare function holds p value
meandiff_allvsbp = c(1,4); % 4th column returned hold difference in mean between all and bp modes

pval_allvsavg = c(2,6); % 6th column returned by multcompare function holds p value
meandiff_allvsavg = c(2,4); % 4th column returned hold difference in mean between all and avg modes

if pval_allvsbp < 0.001 && meandiff_allvsbp < 0
    disp(['Deviations from true edge length is on average significantly smaller (p < '  num2str(0.001) ') when using all cameras than when using best pair'])
end

if pval_allvsavg < 0.001 && meandiff_allvsavg < 0
    disp(['Deviations from true edge length is on average significantly smaller (p < '   num2str(0.001)  ') when using all cameras than when averaging over pairs'])
end

%% Vizualization
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

   
figure1 = figure('units','normalized','OuterPosition',[0.044 0.206 0.9 0.5]);

% Create axes for 3D reconstructed data
ha(1) = axes('Parent',figure1,...
    'Position',[0.08 0.16 0.27 0.7]);

% Create axes for camera 2 data
ha(2) = axes('Parent',figure1,...
    'Position',[0.38 0.16 0.27 0.76]);

% Create axes for camera 2 data
ha(3) = axes('Parent',figure1,...
    'Position',[0.68 0.57 0.125 0.345]);

% Create axes for camera 3 data
ha(4) = axes('Parent',figure1,...
    'Position',[0.83 0.57 0.125 0.345]);

% Create axes for camera 4 data
ha(5) = axes('Parent',figure1,...
    'Position',[0.68 0.16 0.125 0.345]);

% Create axes for camera 4 data
ha(6) = axes('Parent',figure1,...
    'Position',[0.83 0.16 0.125 0.345]);


colorclass = colormap(jet); %jet is default in DLC to-date
color_map_self=colorclass(1:nfeatures:64,:);
drawline = [ 1 2; 2 3; 3 4; 4 1; 5 6;6 7;...
    7 8;8 5;1 5; 2 6;3 7; 4 8];

%Movies recorded from 5 cameras saved as videos.mat file for demo 

for icams = 1:ncams
    load(['./DemoData/videosdata_DLC2d/movie' num2str(icams) '.mat'])
end

str = sprintf(['reconstructed edge length = %0.2f ' char(177) ' %0.2f mm over %d frames'],nanmean(reconall(:)),nanstd(reconall(:)),nframes);

k = 1;
for i =1:npoints:size(coords3d,1) %movies files saved as .mat file for every 5th point (to make trying out demo easier)
    temp = reshape(coords3d(i,:,1),3,nfeatures);
    scatter3(temp(1,:),temp(2,:),temp(3,:),250*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled','Parent', ha(1));
    for l = 1:size(drawline,1)
        pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
        line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1.5,'Parent', ha(1))
    end

    imagesc(movie1(:,:,:,k),'Parent', ha(2)) %video recorded from first camera
  
    imagesc(movie2(:,:,:,k),'Parent', ha(3)) %video recorded from second camera
  
    imagesc(movie3(:,:,:,k),'Parent', ha(4))
   
    imagesc(movie4(:,:,:,k),'Parent', ha(5))

    imagesc(movie5(:,:,:,k),'Parent', ha(6))

    
    set(ha(1),'view',[-127.1,21.8],'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax],'Zdir', 'reverse','Ydir', 'reverse') %change view and axis limits to fit your data
    set(ha(1,1:6),'xtick',[],'ytick',[],'ztick',[])
    
    title(ha(1),sprintf(['3D reconstructed corners of \nRubiks cube with true edge length = 57 mm and\n' str]),'FontSize',14)
    title(ha(2),'2D tracking using DLC from camera 1','FontSize',14)
    title(ha(3),'Camera 2','FontSize',14)
    title(ha(4),'Camera 3','FontSize',14)
    title(ha(5),'Camera 4','FontSize',14)
    title(ha(6),'Camera 5','FontSize',14)
    set(gcf, 'color', 'white')
   
    pause(0.05)
    k = k+1;
    
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

    