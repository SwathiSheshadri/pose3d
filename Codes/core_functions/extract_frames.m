function flag_mis = extract_frames(full_file_path,dest_path,frames_to_use,flag_mis,num_pair,cam_type)

% Description:
% ------------
% Helperfunction showing how to extract calibration frames from video
% stereoCameraCalibrator function recommends using 10 to 20 images for
% calibration. 
% For good calibration these 10 to 20 examples must include checker board
% presented in different angles to the cameras
% Alternatively, one could extract and use ~100 to 150 frames per camera
% (takes longer then)
%
% Inputs: 
% -------
% full_file_path : of your calibration file
% dest_path      : folder for extracted frames
% frames_to_use  : number of frames you want to use for calibration
%                  Matlab recommends 10 to 20. If you have noisy videos set
%                  this to 50 or more to account for some frames that get
%                  rejected automatically during stereoCameraCalibration
% flag_mis       : to indicate success or failure of prior program modules
% num_pair       : camera pair number (max value: ncams-1)
% cam_type       :'Primary' or 'Secondary'

% Outputs: 
% -------
% Saves extracted images from calibration videos
% flag_mis : returns 1 if any problems in recorded calibration video format
%            is detected

% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/pose3d


try
    vidfile=VideoReader(full_file_path);
    nskip = ceil(vidfile.NumberOfFrames/frames_to_use);
    k = 1;
    for img = 1:nskip:vidfile.NumberOfFrames
        filename=strcat('frame',num2str(img),'.png');
        vidframe = read(vidfile, img);
        if ~mod(k,5)
            if strcmp(cam_type,'Primary')
                if contains(dest_path,'PrimarySecondary')
                    disp(['Writing calibration image ' num2str(k) ' of ' num2str(frames_to_use) ' for ' cam_type ' of camera pair ' num2str(num_pair)])
                else
                    disp(['Writing calibration image ' num2str(k) ' of ' num2str(frames_to_use) ' for ' cam_type])
                end
            else
                disp(['Writing calibration image ' num2str(k) ' of ' num2str(frames_to_use) ' for ' cam_type ' of camera pair ' num2str(num_pair)])
            end
        end
        imwrite(vidframe,[dest_path filename]);
        k=k+1;
    end

catch
    flag_mis = 1;
    msgbox('Problem when extracting frames from your video files. Ensure your calibration videos exist at the path specified in config file & can be read in by VideoReader Matlab function & rerun','Problem detected'); 
    return
end

