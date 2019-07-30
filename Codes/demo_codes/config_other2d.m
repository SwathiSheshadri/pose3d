% Fill in the below config file for recon3D. Since recon3D does most of the 
% pre-processing steps automatically it is important that the right
% path and filenames are available in this config file. 


%% Specify path and file name for recon3D to save your 3D reconstruction related files in
% exp_path holds the name of the folder that gets created by recon3D for
% your experiment. 
% All experiments in this folder access the same calibration files
% Therefore, everytime you move cameras or record from a different setup
% change this name, otherwise you can keep this fixed

exp_path = 'Demo_Experiments';%'AllExperiments'; %./AllExperiments **To be different for every new camera configuration/experiment setup**

% exp_name holds the name of your experiment sessions which will also get
% creates by recon3D for your session specific data files

exp_name = 'Rubikscube_other2d'; % ./AllExperiments/Experiment1; **To be different for every new experiment**

%Are you using DeepLabCut for 2D tracking?
usingdlc = 0;  %set to 0, if using any other software

%% Enter your experiment specifics
% Fill in the number of features you have tracked in 2D using DLC or any
% other 2D tracking software (eg: for our demo nfeatures = 8;)
% Change this to
nfeatures = 8; %Edit this to match your current experiment

% Fill in precise duration of experiment video recording (not of calibration file!) on which 2D tracking was done in **seconds** 
%(eg: for our demo rec_time = 10;)
rec_time =  20; %Edit this to match your experiment

% Fill in frames per second of experiment video recording (not of calibration file!)(eg: for our demo fps = 100;)
fps =1; %%Edit this to match your current experiment**

% Fill in the overall number of cameras in your experiment (for our demo we had 5 cameras)
% Change this to the number of cameras you have in your setup
ncams = 5; %Edit this to match your current experiment (minimum allowed value is 2)

%% Copy and paste your 2D tracked csv file paths with filenames

% There must be one path cell entry for primary
primary2D_datafullpath     = {'./Demo_Data/Rubikscube_other2d_Primary_CollectedData_Swathi.csv'}; %copy and paste the full path to your csv files generated by DLC
%If you are using other software use the csv files in Rubikscube_other2d folder as
%reference to ensure the row and column entries are similar

% There must be ncams-1 path cell entries for secondary cameras (we have 5 cameras of
% which 1 is primary and remaining are secondary)
secondary2D_datafullpath = [{'./Demo_Data/Rubikscube_other2d_Secondary1_CollectedData_Swathi.csv'}; 
    {'./Demo_Data/Rubikscube_other2d_Secondary2_CollectedData_Swathi.csv';};
    {'./Demo_Data/Rubikscube_other2d_Secondary3_CollectedData_Swathi.csv'}; 
    {'./Demo_Data/Rubikscube_other2d_Secondary4_CollectedData_Swathi.csv'}];


%% Calibration Specifics
squareSize = 24; %%enter your checkboard square length in mm default is 24

calib_videos = 0; %set this to zero if you have acquired calibration images and 1 if videos

% Number of frames to use for calibration
% Matlab recommends 10 to 20. If you have noisy calibration videos set this to 50 or more to account for some frames that get
% rejected automatically during stereoCameraCalibration 
frames_to_use = 25; 

%% calibfiles_format & folderwithpngs . are relevant only when you have taken images for calibration instead of videos 
% format variable relevant only if you have calibration images (i.e
% calib_videos = 0), if you have videos the file path must include the full
% file name 
calibfiles_format = '.png'; 

%this allows matlab's multi select user interfact to open this folder and
%reduces the amount of navigation user has to do to select all required
%files
folderwithpngs = '/Users/ssheshadri/Mac_local_files/workspace_3d/CubeCase1/CalibFiles/';

%% Copy and paste your calibration video paths and file names


% For recon3D there must be 4 videos recorded from primary (each video
% recorded simultaneously with every secondary camera)
calibvideos_primary    = [{'/Users/ssheshadri/Mac_local_files/JOSS_data/RecSession_11th_July_2019/Calib_top_lf4-0000.avi'};
    {'/Users/ssheshadri/Mac_local_files/JOSS_data/RecSession_11th_July_2019/Calib_top_rf4-0000.avi'};...
                             {'/Users/ssheshadri/Mac_local_files/JOSS_data/RecSession_11th_July_2019/Calib_top_lb4-0000.avi'};{'/Users/ssheshadri/Mac_local_files/JOSS_data/RecSession_11th_July_2019/Calib_top_rb4-0000.avi'};]; %path to your calibration video recorded from secondary camera 1 with primary

%Every secondary camera must have one calibration video recorded
%simultaneously with primary camera
calibvideos_secondary  = [{'/Users/ssheshadri/Mac_local_files/JOSS_data/RecSession_11th_July_2019/Calib_top_lf1-0000.avi'};
    {'/Users/ssheshadri/Mac_local_files/JOSS_data/RecSession_11th_July_2019/Calib_top_rf2-0000.avi'};...
                             {'/Users/ssheshadri/Mac_local_files/JOSS_data/RecSession_11th_July_2019/Calib_top_lb3-0000.avi'};{'/Users/ssheshadri/Mac_local_files/JOSS_data/RecSession_11th_July_2019/Calib_top_rb5-0000.avi'};]; %path to your calibration video recorded from secondary camera 1 with primary


%% You are now done with fill up the main parameters!!! edit below for post-processing
% (By default we have set to undistort images, apply DLC likelihood based threshold of 0.9 and
% apply median filter)

% Do you want to undistort 2D coordinates?
% If your videos are already undistorted or if have low distortion lens set this to 0
run_undistort = 0; %1: run undistort, 0: do not undistort

% the DLC based likelihood value threshold
llh_thresh = 0.9; %Can choose values between 0 and 1; 

% To draw a stick diagram/skeleton, list point pairs you want to join 
% If you don't want to draw skeleton, set this to 0
drawline = [ 1 2; 2 3; 3 4; 4 1; 5 6;6 7;...
    7 8;8 5;1 5; 2 6;3 7; 4 8];%Eg : [ 1 2; 2 3;], draws lines between features 1 and 2, 2 and 3 

whichfilter = 0; % 0: No filter; 1: moving average; 2:median filter (if you observe jumps in your feature trajectories try 2 or 1)
npoints = 0;%number of data points to use for filter (if you choose 1 or 2 for which filter this value has to be filled)               

nframes = rec_time*fps; %nothing to edit here

%% Some checks to make recon3D user-friendly
% Check if there are the right number csv of files & if all files are unique

if ((length(unique(secondary2D_datafullpath))) ~= ncams-1 || (length(unique(primary2D_datafullpath)) ~= 1))
   flag_mis = 1;
   uiwait(msgbox('Mismatch between number of cameras and number of 2D tracked data csv files detected. Check if all file names are unique and are as many as the number of cameras and re-run main program.'))
end

% Check if .csv files are provided for 2D tracked data 
if(~all(arrayfun(@(x,y)strcmp(secondary2D_datafullpath{x}(end-2:end),'csv'),1:4)))
    flag_mis = 1;
    uiwait(msgbox('csv file expected by recon3D. Please enter 2D tracked data in csv format and re-run main program.'))
end

%Check if there are the right number of unique calibration files
if ((length(unique(calibvideos_primary))) ~= ncams-1 || (length(unique(calibvideos_secondary)) ~= ncams-1))
   flag_mis = 1;
   uiwait(msgbox('Check if all calibration file names are unique and are included for every primary-secondary pair and re-run main program.'))
end

if ~exist('flag_mis','var')
    flag_mis = 0; %Nothing to flag, checks passed
end