% load_preprocess_DLC2d_data.m
% Called from main scripts such as Demo_Rubikscube_DLC2d.m and template_your_experiment_DLC2d
% to load, undistort and save undistorted data
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/recon3D


if ~flag_mis == 1
%% To automatically move 2D tracked data into the folder structure necessary for this toolbox

if ~exist([exp_path '/' exp_name '/Data2d/'],'dir')
    dest_fold = [exp_path '/' exp_name '/Data2d/Primary/'];
    mkdir(dest_fold)
    copyfile(primary2D_datafullpath{1},dest_fold)
    for icams = 1:ncams-1
        dest_fold = [exp_path '/' exp_name '/Data2d/Secondary' num2str(icams) '/'];
        mkdir(dest_fold)
        copyfile(secondary2D_datafullpath{icams},dest_fold)
    end
else
    answer = questdlg('Data2d folder exists, do you want to proceed to 3D reconstruction?','Copy 2D data helper','Proceed','Copy new','Proceed');
        % Handle response
        switch answer

            case 'Proceed'
                for icams = 1:ncams-1
                    dest_fold = [exp_path '/' exp_name '/Data2d/Secondary' num2str(icams) '/'];
                    d = dir(dest_fold);
                    if((d(1).name== '.') && length(d)==2)
                        flag_mis = 1; 
                        uiwait(msgbox(sprintf(['Missing files in ' exp_path '/' exp_name '/Data2d/Secondary%d. Re-run main function and choose to copy the 2D data'],icams),'Problem detected'))
                        return
                    end
                end
                disp('Proceeding to calibration')

            case 'Copy new'
                rmdir([exp_path '/' exp_name '/Data2d/'],'s')
                if exist([exp_path '/' exp_name '/UndistortedData2d/'],'dir')
                    rmdir([exp_path '/' exp_name '/UndistortedData2d/'],'s')
                end
                dest_fold = [exp_path '/' exp_name '/Data2d/Primary/'];
                mkdir(dest_fold)
                copyfile(primary2D_datafullpath{1},dest_fold)
                for icams = 1:ncams-1
                    dest_fold = [exp_path '/' exp_name '/Data2d/Secondary' num2str(icams) '/'];
                    mkdir(dest_fold)
                    copyfile(secondary2D_datafullpath{icams},dest_fold)
                end
        end        
end
disp('2D tracked csv files exist in corresponding folders for recon3D')

%% data load with undistortion if requested in config file
fprintf('Loading calibration files and undistorting 2D coordinates (this might take awhile the first time you run this code for an experiment) \n ...\n')
stereoParams = cell(ncams-1,1);
cam_mat_all = nan(3,4,ncams);
DataAll = nan(nframes,nfeatures*2,ncams) ;

if usingdlc %likelihood per tracked point is given only for DLC
    DataAll_llh = nan(nframes,nfeatures*2,ncams) ;
end

for icams = 1:ncams-1 % since calibration is done pairwise, primary camera parameters need not be loaded separately
    
    if ~exist([ exp_path '/CalibSessionFiles/PrimarySecondary' num2str(icams) '/calibrationSession.mat'],'file')
        flag_mis = 1;
        uiwait(msgbox(sprintf(['Missing required files in' exp_path '/CalibSessionFiles/PrimarySecondary%d'],icams),'Problem detected'))
        return
    end

    %'Loading the stereoCalib file for primary and secondary camera #' num2str(i)
    load([ exp_path '/CalibSessionFiles/PrimarySecondary' num2str(icams) '/calibrationSession.mat']);
    stereoParams = calibrationSession.CameraParameters;
    cam_mat =[stereoParams.RotationOfCamera2; stereoParams.TranslationOfCamera2]*stereoParams.CameraParameters2.IntrinsicMatrix; %setting secondary camera characteristics
    cam_mat_all(:,:,icams) = cam_mat';
    
    %Loading 2d data csv folder from DLC for secondary camera # num2str(i)
    if ~run_undistort               
        csvname = dir([exp_path '/' exp_name '/Data2d/Secondary' num2str(icams)  '/*.csv']);
        if  isempty(csvname) %there has to be only one csv file in this directory, dir function returns '.','..' first and then the files contained
            flag_mis = 1;
            uiwait(msgbox(sprintf(['Missing required number of csv files in' exp_path '/' exp_name '/Data2d/Secondary%d'],icams),'Problem detected'))
            return
        end
        if usingdlc
            [data2d,data2dllh,flag_mis] = load_dlcdata([csvname.folder '/' csvname.name],nframes,nfeatures,flag_mis);
        else
            [data2d,flag_mis] = load_otherdata([csvname.folder '/' csvname.name],nframes,nfeatures,flag_mis);
        end
        if flag_mis == 1 %case when the load_dlcdata function sets flag to 1
            uiwait(msgbox(['Number of data entries in 2D tracked csv file at ' csvname.folder 'does not match specified duration of recording and frame rate in config file. Check and re-run main function'],'Problem detected'))
            return
        end
    else
    
        if ~exist([exp_path '/' exp_name '/UndistortedData2d/Secondary' num2str(icams) '/data2d.mat'],'file') 
            mkdir([exp_path '/' exp_name '/UndistortedData2d/Secondary' num2str(icams)])
            csvname = dir([exp_path '/' exp_name '/Data2d/Secondary' num2str(icams)  '/*.csv']);
            if  isempty(csvname) %there has to be only one csv file in this directory
                flag_mis = 1;
                uiwait(msgbox(sprintf(['Missing required number of csv files in' exp_path '/' exp_name '/Data2d/Secondary%d'],icams),'Problem detected'))
                return
            end
            if usingdlc
                [data2d,data2dllh,flag_mis] = load_dlcdata([csvname.folder '/' csvname.name],nframes,nfeatures,flag_mis);
            else
                [data2d,flag_mis] = load_otherdata([csvname.folder '/' csvname.name],nframes,nfeatures,flag_mis);
            end
            if flag_mis == 1 %case when the load_dlcdata function sets flag to 1
                uiwait(msgbox(['Number of data entries in 2D tracked csv file at ' csvname.folder 'does not match specified duration of recording and frame rate in config file. Check and re-run main function'],'Problem detected'))
                return
            end
            temp = permute(reshape(data2d,nframes,2,nfeatures),[1 3 2]);
            temp = reshape(temp,nframes*nfeatures,2);
            if usingdlc                              
                data2d = undistortPoints(temp,stereoParams.CameraParameters2);
            else
                isnan_temp = isnan(temp);
                data2d = nan(size(temp,1),size(temp,2));
                data2d(~isnantemp) = undistortPoints(temp(~isnantemp),stereoParams.CameraParameters2);
            end
            temp = reshape(data2d,nframes,nfeatures,2);
            data2d = permute(temp,[1 3 2]);
            data2d = data2d(:,:);
            save([exp_path '/' exp_name '/UndistortedData2d/Secondary' num2str(icams) '/data2d.mat'],'data2d','data2dllh')
        else
            
            %incase you have already run this code before then the saved
            %undistorted data is directly loaded
            load([exp_path '/' exp_name '/UndistortedData2d/Secondary' num2str(icams) '/data2d.mat'])
        end
    end
    
    DataAll(:,:,icams) = data2d;
    if usingdlc
        tempp = repmat(reshape(data2dllh,[nframes,1,nfeatures]), [1 2 1]); %for x and y coords same threshold is applied
        DataAll_llh(:,:,icams) = reshape(tempp,[nframes,nfeatures*2]);
    end
    
    if icams == ncams-1
        %setting primary camera characteristics (every stereoParams file
        %has primary camera matrix so if calibration is accurately done
        %across camera pairs it does not matter from which stereoParams
        %primary camera matrix is obtained
        
        %primary camera is chosen as the center of the coordinate system
        %therefore data recorded from it is neither rotated nor translated
        cam_mat = [eye(3); [0 0 0]]*stereoParams.CameraParameters1.IntrinsicMatrix;
        cam_mat_all(:,:,icams+1) = cam_mat';
        %Loading 2d data csv folder from DLC for primary camera
        if ~run_undistort
            csvname = dir([exp_path '/' exp_name '/Data2d/Primary'  '/*.csv']);
            if  isempty(csvname) %there has to be only one csv file in this directory, dir function returns '.','..' first and then the files contained
                flag_mis = 1;
                uiwait(msgbox(sprintf(['Missing required number of csv files in' exp_path '/' exp_name '/Data2d/Primary']),'Problem detected'))
                return
            end
            if usingdlc
                [data2d,data2dllh,flag_mis] = load_dlcdata([csvname.folder '/' csvname.name],nframes,nfeatures,flag_mis);
            else
                [data2d,flag_mis] = load_otherdata([csvname.folder '/' csvname.name],nframes,nfeatures,flag_mis);
            end
            if flag_mis == 1 %case when the load_dlcdata function sets flag to 1
                uiwait(msgbox(['Number of data entries in 2D tracked csv file at ' csvname.folder ' does not match specified duration of recording and frame rate in config file. Check and re-run main function to proceed'],'Problem detected'))
                return
            end

        else

            if ~exist([exp_path '/' exp_name '/UndistortedData2d/Primary' '/data2d.mat'],'file') 
                mkdir([exp_path '/' exp_name '/UndistortedData2d/Primary' ])
                csvname = dir([exp_path '/' exp_name '/Data2d/Primary'  '/*.csv']);
                if usingdlc
                    [data2d,data2dllh,flag_mis] = load_dlcdata([csvname.folder '/' csvname.name],nframes,nfeatures,flag_mis);
                else
                    [data2d,flag_mis] = load_otherdata([csvname.folder '/' csvname.name],nframes,nfeatures,flag_mis);
                end
                if flag_mis == 1 %case when the load_dlcdata function sets flag to 1
                    uiwait(msgbox(['Number of data entries in 2D tracked csv file at ' csvname.folder ' does not match specified duration of recording and frame rate in config file. Check and re-run main function to proceed'],'Problem detected'))
                    return
                end
                temp = permute(reshape(data2d,nframes,2,nfeatures),[1 3 2]);
                temp = reshape(temp,nframes*nfeatures,2);
                
                if usingdlc                              
                    data2d = undistortPoints(temp,stereoParams.CameraParameters2);
                else
                    isnan_temp = isnan(temp);
                    data2d = nan(size(temp,1),size(temp,2));
                    data2d(~isnantemp) = undistortPoints(temp(~isnantemp),stereoParams.CameraParameters2);
                end
                
                temp = reshape(data2d,nframes,nfeatures,2);
                data2d = permute(temp,[1 3 2]);
                data2d = data2d(:,:);
                if usingdlc
                    save([exp_path '/' exp_name '/UndistortedData2d/Primary' '/data2d.mat'],'data2d','data2dllh')
                else
                    save([exp_path '/' exp_name '/UndistortedData2d/Primary' '/data2d.mat'],'data2d')
                end
            else
                %incase you have already run this code before then the saved
                %undistorted data is directly loaded
                load([exp_path '/' exp_name '/UndistortedData2d/Primary'  '/data2d.mat'])
            end
        end 
        DataAll(:,:,icams+1) = data2d;
        
        if usingdlc
            tempp = repmat(reshape(data2dllh,[nframes,1,nfeatures]), [1 2 1]); %for x and y coords same threshold is applied
            DataAll_llh(:,:,icams+1) = reshape(tempp,[nframes,nfeatures*2]);
        end
    end
    
end



end

%A bit of code modularization & check for recon3D appropriate data 
%Loading DLC 2D tracked data
function [data2d,data2dllh,flag_mis] = load_dlcdata(fullfilename,nframes,nfeatures,flag_mis)
    data2d = importdata(fullfilename);
    data2d = data2d.data;
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
    data2d = data2d.data;
    
    if nframes~= size(data2d,1)
        flag_mis = 1;
    end
    
    if nfeatures*2 ~= size(data2d,2)
        flag_mis = 1;
    end
       
end