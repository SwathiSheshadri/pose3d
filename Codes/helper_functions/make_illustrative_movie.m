% make_illustrative_movie.m (example code to make movies containing 2D and
% 3D tracked data as shown in Figure 1 of the repository readme.md file)
%
% Compute 3D data first before running this code for your experiment
% This function plots 3D reconstruction data alongside 2D tracking
% performed from select cameras (user can choose which ones to plot but
% providing the corresponding paths in the tracked_videos OR
% path2Dtrackedimages_folders variables
% In addition this function makes a movie of the same
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/pose3d


clear 
close all
clc

%% Take initialized values from config file
template_config_file %call your config file here

%% Enter paths to the videos and corresponding csv 2D tracked files to visualize
%user input is requested here again to allow users to flexibly select 
%the cameras in the set up they want include for visualization 
%Please ensure that have2Dtrackedvideos OR have2Dtrackedimages is set in
%your config file before running this code
if have2Dtrackedvideos
%path to the videos you want to visualize next to 3D tracked data 
tracked_videos = [{'Fullpath/video1.mp4';};...    %this variable is only to be filled when you have acquired videos for tracking
                  {'Fullpath/video2.mp4';};];
ncams_to_display = size(tracked_videos,1);   
elseif have2Dtrackedimages
path2Dtrackedimages_folders = [{'Fullpath/ImagesCam1/';};...    %this variable is only to be filled when you have acquired images for tracking
                               {'Fullpath/ImagesCam2/';};];
format_of_images = '.png';  %change this to the format of your images
ncams_to_display = size(path2Dtrackedimages_folders,1);   
end

%path 2D tracked csv files of the videos provided above
path_to_csv = [{'Fullpath/DataCam1.csv'};... %provide csv file order should
               {'Fullpath/DataCam2.csv'};]; %correspond to the movie file order;

%% Plotter (no more user input needed here onwards)
          

load([exp_path '/' exp_name '/Data3d/Data3d.mat'],'coords3d')
coords3dall = coords3d(:,:,1); %plots results from the first mode selected in your config file

%Code to visualize 2d videos with 3d reconstruction results
figure('units','normalized','outerposition',[0 0 1 0.5])
colorclass = colormap(jet); %jet is default in DLC to-date
color_map_self=colorclass(ceil(linspace(1,64,nfeatures)),:);

                          
           
cam = cell(ncams_to_display ,1);
DataAll = nan(nframes,nfeatures*2,ncams_to_display ) ;

for icams = 1:ncams_to_display
    
if usingdlc
    [data2d,data2dllh,flag_mis] = load_dlcdata(path_to_csv{icams},nframes,nfeatures,flag_mis);
else
    [data2d,flag_mis] = load_otherdata(path_to_csv{icams},nframes,nfeatures,flag_mis);
end
    DataAll(:,:,icams) = data2d;
    if have2Dtrackedvideos
        cam{icams,1} = VideoReader([tracked_videos{icams,1}]);
    end
    if have2Dtrackedimages
       imagespath{icams,1} = dir([path2Dtrackedimages_folders{icams,1} '*' format_of_images]);
    end
end

%to make video
if ~exist([exp_path '/' exp_name '/Videos/'],'dir')
    mkdir([exp_path '/' exp_name '/Videos/'])
end
vidfile = VideoWriter([exp_path '/' exp_name '/Videos/' exp_name '2D_3Dmovie.avi']);

if have2Dtrackedvideos
    vidfile.FrameRate = cam{1,1}.Framerate; %for images default frame rate of 30 is applied
end

open(vidfile)
    
subplot_cols = size(cam,1)+1;

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

for i =1:1:size(coords3dall,1) 
    temp = reshape(coords3dall(i,:),3,nfeatures);
    subplot(1,subplot_cols,1)
    scatter3(temp(1,:),temp(2,:),temp(3,:),50*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled');
    hold on
    for l = 1:size(drawline,1)
        pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
        line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1.5)
    end
    hold off
    %view to be set to suit the object being tracked 
    set(gca,'xtick',[],'ytick',[],'ztick',[],'view',[140.4073 -71.3356],'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax])
  
    for n = 1:size(cam,1)
        subplot(1,subplot_cols,n+1)
        if have2Dtrackedvideos
            b = read(cam{n,1}, i);
        else
            b = imread([imagespath{n,1}(i).folder '/' imagespath{n,1}(i).name]);
        end
        imshow(b)
        hold on
        scatter(DataAll(i,1:2:2*nfeatures,n),DataAll(i,2:2:2*nfeatures,n),100*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled'); 
        
    end
    set(gcf, 'color', 'white')
    drawnow
    frame = getframe(gcf);
    writeVideo(vidfile,frame);

end

close(vidfile)

%A bit of code modularization & check for pose3d appropriate data 
%Loading DLC 2D tracked data
function [data2d,data2dllh,flag_mis] = load_dlcdata(fullfilename,nframes,nfeatures,flag_mis)
    data2d = importdata(fullfilename);
    if isstruct(data2d) %case when excel contains column or row headers
        data2d = data2d.data;
    end
    data2d = data2d(:,2:end);
    data2dllh = data2d(:,3:3:end);
    data2d(:,3:3:end) = []; 
    
    if nframes~= size(data2d,1)
        flag_mis = 1;
    end
    
    if nfeatures*2 ~= size(data2d,2)
        flag_mis = 1;
    end
       
end

%loaded 2D tracked data from other software
function [data2d,flag_mis] = load_otherdata(fullfilename,nframes,nfeatures,flag_mis)
    data2d = importdata(fullfilename);
        
    if isstruct(data2d) %case when excel contains column or row headers
        data2d = data2d.data;
    end
    
    if nframes~= size(data2d,1)
        flag_mis = 1;
    end
    
    if nfeatures*2 ~= size(data2d,2)
        flag_mis = 1;
    end
       
end
