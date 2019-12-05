% calibration_helper.m
%
% This script provides semi-automatic camera calibration workflow
% Messages/dialogue boxes pop-up when user input is required
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/pose3d

if ~flag_mis == 1 % check if the programs required by pose3d all exist


%% This section creates calibration files folders & prepares files for stereoCameraCalibrator application
if calib_videos == 1
   
     if ~exist([exp_path '/' 'Imagesforcalibration/'],'dir')
        
        disp('Extracting frames for calibration; try increasing nskip if this takes too long')

        if ~flag_1primary
            for icams = 1:ncams-1
                mkdir([exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/'])
                mkdir([exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/'])
                flag_mis = extract_frames(calibvideos_primary{icams},[exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/'],frames_to_use,flag_mis,num2str(icams),'Primary');
                if flag_mis == 1
                    return
                end
                flag_mis = extract_frames(calibvideos_secondary{icams},[exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/'],frames_to_use,flag_mis,num2str(icams),'Secondary') ;    
                if flag_mis == 1
                    return
                end
            end
        else
            for icams = 1:ncams-1
                mkdir([exp_path '/' 'Imagesforcalibration/Secondary' num2str(icams) '/'])
                if icams == 1
                    mkdir([exp_path '/' 'Imagesforcalibration/Primary/'])
                    flag_mis = extract_frames(calibvideos_primary{icams},[exp_path '/' 'Imagesforcalibration/Primary/'],frames_to_use,flag_mis,num2str(icams),'Primary');
                    if flag_mis == 1
                        return
                    end
                end
                flag_mis = extract_frames(calibvideos_secondary{icams},[exp_path '/' 'Imagesforcalibration/Secondary' num2str(icams) '/'],frames_to_use,flag_mis,num2str(icams),'Secondary') ;    
                if flag_mis == 1
                    return
                end
            end
        end
 
        
     else
        answer = questdlg('Imagesforcalibration folder exists, do you want to proceed to stereo camera calibration or extract images for calibration?','Calibration helper','Proceed','Extract Images','Proceed');
        % Handle response
        switch answer
            
            case 'Proceed'
                disp('Proceeding to calibration using previously existing calibration images')

            case 'Extract Images'
                rmdir([exp_path '/' 'Imagesforcalibration/'],'s')
                if exist([exp_path '/' 'CalibSessionFiles/'],'dir') %if new images are extracted calibration and undistortion must be repeated
                    rmdir([exp_path '/' 'CalibSessionFiles/'],'s')%therefore deleted previously calculated files
                end
                if exist([exp_path '/' exp_name '/UndistortedData2d/'],'dir')
                    rmdir([exp_path '/' exp_name '/UndistortedData2d/'],'s') %if calibration is repeated undistortion also has to repeat
                end
                disp('Extracting frames for calibration; try decreasing frames_to_use if this takes too long')
                
                if ~flag_1primary
                    for icams = 1:ncams-1
                        mkdir([exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/'])
                        mkdir([exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/'])
                        flag_mis = extract_frames(calibvideos_primary{icams},[exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/'],frames_to_use,flag_mis,num2str(icams),'Primary');
                        if flag_mis == 1
                            return
                        end
                        flag_mis = extract_frames(calibvideos_secondary{icams},[exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/'],frames_to_use,flag_mis,num2str(icams),'Secondary') ;    
                        if flag_mis == 1
                            return
                        end
                    end
                else
                    for icams = 1:ncams-1
                        mkdir([exp_path '/' 'Imagesforcalibration/Secondary' num2str(icams) '/'])
                        
                        if icams == 1
                            mkdir([exp_path '/' 'Imagesforcalibration/Primary/'])
                            flag_mis = extract_frames(calibvideos_primary{icams},[exp_path '/' 'Imagesforcalibration/Primary/'],frames_to_use,flag_mis,num2str(icams),'Primary');
                            if flag_mis == 1
                                return
                            end
                        end
                        
                        flag_mis = extract_frames(calibvideos_secondary{icams},[exp_path '/' 'Imagesforcalibration/Secondary' num2str(icams) '/'],frames_to_use,flag_mis,num2str(icams),'Secondary') ;    
                        if flag_mis == 1
                            return
                        end
                    end
                end
        end        
    end
    disp('Images for calibration extracted and saved. Proceeding to calibration...')
else
    CreateStruct.Interpreter = 'tex'; %for message boxes
    CreateStruct.WindowStyle = 'modal';
    if ~exist([exp_path '/' 'Imagesforcalibration/'],'dir')
        for icams = 1:ncams-1
            mkdir([exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/'])
            mkdir([exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/'])
            uiwait(msgbox(['\fontsize{14}Select all calibration images recorded from \bfprimary \rmwith secondary camera' num2str(icams)],'Select multiple images',CreateStruct))
            [filename,path] = uigetfile([folderwithpngs '*' CalibrationImages_format],'MultiSelect','on');
            if path == 0
                flag_mis = 1;
                msgbox('Images were not selected for calibration, re-run main function to proceed')
                return
            end
            if length(filename) < 2
                flag_mis = 1;
                msgbox('Select all calibration images (one image not sufficient for calibration), re-run main function to proceed')
                return
            end
            for iframes = 1:length(filename)
                copyfile([path filename{iframes}],[exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/']) 
            end
            uiwait(msgbox(['\fontsize{14}Select all calibration images recorded from \bfsecondary camera' num2str(icams)],'Select multiple images',CreateStruct))
            [filename,path] = uigetfile([folderwithpngs '*' CalibrationImages_format],'MultiSelect','on',['Select all Calibration image files from Secondary' num2str(icams)]);
            if path == 0
                flag_mis = 1;
                msgbox('Images were not selected for calibration, re-run main function to proceed')
                return
            end            
            if length(filename) < 2
                flag_mis = 1;
                msgbox('Select all calibration images (one image not sufficient for calibration), re-run main function to proceed')
                return
            end
            for iframes = 1:length(filename)
                copyfile([path filename{iframes}],[exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/']) 
            end
        end
    else
        answer = questdlg('Imagesforcalibration folder exists, do you want to proceed to stereo camera calibration?','Calibration helper','Proceed','Extract Images','Proceed');
        % Handle response
        switch answer
            
            case 'Proceed'
                disp('Proceeding to calibration using existing calibration images...')

            case 'Extract Images'
                rmdir([exp_path '/' 'Imagesforcalibration/'],'s')
                if exist([exp_path '/' 'CalibSessionFiles/'],'dir') %if new images are extracted calibration and undistortion must be repeated
                    rmdir([exp_path '/' 'CalibSessionFiles/'],'s')%therefore deleted previously calculated files
                end
                if exist([exp_path '/' exp_name '/UndistortedData2d/'],'dir')
                    rmdir([exp_path '/' exp_name '/UndistortedData2d/'],'s') %if calibration is repeated undistortion also has to repeat
                end
                for icams = 1:ncams-1
                    mkdir([exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/'])
                    mkdir([exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/'])
                    uiwait(msgbox(['\fontsize{14}Select all calibration images recorded from \bfprimary \rmwith secondary camera' num2str(icams)],'Select multiple images',CreateStruct))
                    [filename,path] = uigetfile([folderwithpngs '*' CalibrationImages_format],'MultiSelect','on');
                    if path == 0
                        flag_mis = 1;
                        msgbox('Images were not selected for calibration, re-run main function to proceed')
                        return
                    end
                    for iframes = 1:length(filename)
                        copyfile([path filename{iframes}],[exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/']) 
                    end
                    uiwait(msgbox(['\fontsize{14}Select all calibration images recorded from \bfsecondary camera' num2str(icams)],'Select multiple images',CreateStruct))
                    [filename,path] = uigetfile([folderwithpngs '*' CalibrationImages_format],'MultiSelect','on');
                    if path == 0
                        flag_mis = 1;
                        msgbox('Images were not selected for calibration, re-run main function to proceed')
                        return
                    end
                    for iframes = 1:length(filename)
                        copyfile([path filename{iframes}],[exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/']) 
                    end
                end
        end
    end

end

%% Run StereoCameraCalibration
if ~exist([exp_path '/' 'CalibSessionFiles/'],'dir')
    mkdir([exp_path '/' 'CalibSessionFiles/'])

    for icams = 1:ncams-1
        mkdir([exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/'])
        
        if  ~flag_1primary
            folder1 = [exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/'];
            folder2 = [exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/'];
            %check if there are empty folders
            d = dir(folder1);
            if((d(1).name== '.') && length(d)==2) % dir function returns '.','..' first and the files contained later
                uiwait(msgbox(sprintf(['Missing files in ' exp_path '/Imagesforcalibration/PrimarySecondary%d. Re-run main function and choose extract new images'],icams),'Problem detected'))
                flag_mis = 1; 
                return
            end
            d = dir(folder2);
            if((d(1).name== '.') && length(d)==2)
                uiwait(msgbox(sprintf(['Missing files in ' exp_path '/Imagesforcalibration/PrimarySecondary%d. Re-run main function and choose extract new images'],icams),'Problem detected'))
                flag_mis = 1; 
                return
            end
        else %when single primary folder
            folder1 = [exp_path '/' 'Imagesforcalibration/Primary/'];
            folder2 = [exp_path '/' 'Imagesforcalibration/Secondary' num2str(icams) '/'];
            %check if there are empty folders
            d = dir(folder1);
            if((d(1).name== '.') && length(d)==2) % dir function returns '.','..' first and the files contained later
                uiwait(msgbox(sprintf(['Missing files in ' exp_path '/Imagesforcalibration folder for PrimarySecondary%d. Re-run main function and choose extract new images'],icams),'Problem detected'))
                flag_mis = 1; 
                return
            end
            d = dir(folder2);
            if((d(1).name== '.') && length(d)==2)
                uiwait(msgbox(sprintf(['Missing files in ' exp_path '/Imagesforcalibration folder for PrimarySecondary%d. Re-run main function and choose extract new images'],icams),'Problem detected'))
                flag_mis = 1; 
                return
            end
        end
        
        try
            stereoCameraCalibrator(folder1, folder2, squareSize);
            CreateStruct.Interpreter = 'tex';
            CreateStruct.WindowStyle = 'non-modal';
            h = msgbox({'\fontsize{16}The main program is paused for Stereo Camera Calibrator GUI to run \bf(move this message box to a side leave it open and follow the below steps in the GUI)';''; '\rm1. Click \bfcalibrate';'';...
                        '\rm2. From save menu in the GUI, \bfselect save session as';''; ['\rm3. Save session as calibrationSession.mat in folder \bf ./' exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/'];'';...
                        '\rm4. Close GUI & \bfpress any key \rmto continue';'';'Tip : If reprojection errors are high for some calibration images, select outliers using GUI features, right click on detected outliers to remove them and recalibrate';'';},'Important steps to do next',CreateStruct);

        catch
            flag_mis = 1;
            msgbox(['Problem using Stereo Camera Calibrator for PrimarySecondary' num2str(icams) '. Check if images exist for calibration and are same in number for both primary and secondary cameras (in format readable by Stereo Camera Calibrator GUI)'],'Problem detected'); 
            return
        end
        disp('Press any key to continue')
        pause
        if exist('h', 'var')
            delete(h);
            clear('h');
        end
        
        
        if ~exist([exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/calibrationSession.mat'],'file')
            uiwait(msgbox('Save session as calibrationSession.mat before closing stereoCameraCalibrator GUI , rerun main program to proceed','Problem detected'))
            flag_mis = 1;
            return
        end

    end
else
    answer = questdlg('CalibSessionFiles folder exists. Do you want to proceed to 3D reconstruction?','Calibration helper', 'Proceed','Redo Stereo Camera Calibration','Proceed');
        % Handle response
        switch answer
            case 'Proceed'
                for icams = 1:ncams-1
                    if ~exist([exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/calibrationSession.mat'],'file')
                        uiwait(msgbox('Redo Stereo Camera Calibration and save session files as calibrationSession.mat','Problem detected'))
                        flag_mis = 1;
                        return
                    end
                    
                end
                disp('Proceeding to 3D reconstruction...')
            case 'Redo Stereo Camera Calibration'

                for icams = 1:ncams-1

                    if  ~flag_1primary
                        folder1 = [exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Primary/'];
                        folder2 = [exp_path '/' 'Imagesforcalibration/PrimarySecondary' num2str(icams) '/Secondary' num2str(icams) '/'];
                    else %when single primary folder
                        folder1 = [exp_path '/' 'Imagesforcalibration/Primary/'];
                        folder2 = [exp_path '/' 'Imagesforcalibration/Secondary' num2str(icams) '/'];
                    end
                    
                    try
                        if exist([exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/calibrationSession.mat'],'file')
                            stereoCameraCalibrator([exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/calibrationSession.mat'])
                            answer = questdlg(['Previous calibration results are displayed in the calibrator window for camera pair ' num2str(icams) '. Do you want to keep these results or redo calibration for this pair?'],'Calibration helper', 'Keep results','Redo Stereo Camera Calibration','Redo Stereo Camera Calibration');
                            
                            switch answer

                                case 'Redo Stereo Camera Calibration'
                                    msgbox('The current calibrator GUI can now be closed (if you have not yet closed it). Proceeding to recalibrate.')
                                    pause(10)
                                    delete([exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/calibrationSession.mat'])
                                    stereoCameraCalibrator(folder1, folder2, squareSize);
                                    CreateStruct.Interpreter = 'tex';
                                    CreateStruct.WindowStyle = 'non-modal';
                                    h = msgbox({'\fontsize{16}The main program is paused for Stereo Camera Calibrator GUI to run \bf(move this message box to a side leave it open and follow the below steps in the GUI)';''; '\rm1. Click \bfcalibrate';'';...
                                    '\rm2. From save menu in the GUI, \bfselect save session as';''; ['\rm3. Save session as calibrationSession.mat in folder \bf ./' exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/'];'';...
                                    '\rm4. Close GUI & \bfpress any key \rmto continue';'';'Tip : If reprojection errors are high for some calibration images, select outliers using GUI features, right click on detected outliers to remove them and recalibrate';'';},'Important steps to do next',CreateStruct);
                                    if exist([exp_path '/' exp_name '/UndistortedData2d/'],'dir')
                                        rmdir([exp_path '/' exp_name '/UndistortedData2d/'],'s') %if calibration is repeated undistortion also has to repeat
                                    end

                                case 'Keep results'
                                    msgbox('The current calibrator GUI can now be closed (if you have not yet closed it). Press any key to move to the next pair.')

                            end
                        else
                            mkdir([exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/'])
                            stereoCameraCalibrator(folder1, folder2, squareSize);
                            CreateStruct.Interpreter = 'tex';
                            CreateStruct.WindowStyle = 'non-modal';
                            h = msgbox({'\fontsize{16}The main program is paused for Stereo Camera Calibrator GUI to run \bf(move this message box to a side leave it open and follow the below steps in the GUI)';''; '\rm1. Click \bfcalibrate';'';...
                            '\rm2. From save menu in the GUI, \bfselect save session as';''; ['\rm3. Save session as calibrationSession.mat in folder \bf ./' exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/'];'';...
                            '\rm4. Close GUI & \bfpress any key \rmto continue';'';'Tip : If reprojection errors are high for some calibration images, select outliers using GUI features, right click on detected outliers to remove them and recalibrate';'';},'Important steps to do next',CreateStruct);

                        end
                        
                    catch
                        flag_mis = 1;
                        msgbox(['Problem using Stereo Camera Calibrator for PrimarySecondary' num2str(icams) '. Check if images exist for calibration and are same in number for both primary and secondary cameras (in format readable by Stereo Camera Calibrator GUI)'],'Problem detected'); 
                        return
                    end
                    
                    disp('Press any key to continue')
                    pause
                    if exist('h', 'var')
                        delete(h);
                        clear('h');
                    end                    

                    if ~exist([exp_path '/' 'CalibSessionFiles/PrimarySecondary' num2str(icams) '/calibrationSession.mat'],'file')
                        uiwait(msgbox(sprintf(['Save session as calibrationSession.mat in ' exp_path '/' 'CalibSessionFiles/PrimarySecondary%d folder before closing Stereo Camera Calibrator GUI , rerun main program to proceed'],icams),'Problem detected'))
                        flag_mis = 1;
                        return
                    end
                end

        end   
end
    disp('CalibSessionFiles for 3D reconstruction are saved. Proceeding to 3D reconstruction')
end
