% load_preprocess_DLC2d_data.m
% Called from main scripts such as demo_DLC2d.m, demo_other2d, main_pose3d
% to load, undistort and save undistorted data as requested by user's
% config file
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/pose3d


if ~flag_mis == 1
%% data load with undistortion if requested in config file
disp('Loading calibration files and 2D tracked coordinates')
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
    
    if(isempty(stereoParams.CameraParameters2.IntrinsicMatrix))
        flag_mis = 1;
        uiwait(msgbox('Maybe you close StereoCameraCalibrator too soon! Please check if you the saved calibrationSession.mat files are not empty','Problem detected'))
        return
    end
    
    cam_mat =[stereoParams.RotationOfCamera2; stereoParams.TranslationOfCamera2]*stereoParams.CameraParameters2.IntrinsicMatrix; %setting secondary camera characteristics
    cam_mat_all(:,:,icams) = cam_mat';
    
    %Loading 2d data csv folder from DLC for secondary camera # num2str(i)
    if ~run_undistort               
        
        if usingdlc
            [data2d,data2dllh,flag_mis] = load_dlcdata(secondary2D_datafullpath{icams},nframes,nfeatures,flag_mis);
        else
            [data2d,flag_mis] = load_otherdata(secondary2D_datafullpath{icams},nframes,nfeatures,flag_mis);
        end
        if flag_mis == 1 %case when the load_dlcdata function sets flag to 1
            uiwait(msgbox(['Number of rows in 2D tracked csv file ' secondary2D_datafullpath{icams} ' does not match nframes in config file. Check and re-run main function'],'Problem detected'))
            return
        end
    else
    
        if ~exist([exp_path '/' exp_name '/UndistortedData2d/Secondary' num2str(icams) '/data2d.mat'],'file') 
            disp('Undistortion takes a long while...') 
            disp(['Starting undistortion on Secondary' num2str(icams) ])
            mkdir([exp_path '/' exp_name '/UndistortedData2d/Secondary' num2str(icams)])
            if usingdlc
                [data2d,data2dllh,flag_mis] = load_dlcdata(secondary2D_datafullpath{icams},nframes,nfeatures,flag_mis);
            else
                [data2d,flag_mis] = load_otherdata(secondary2D_datafullpath{icams},nframes,nfeatures,flag_mis);
            end
            if flag_mis == 1 %case when the load_dlcdata function sets flag to 1
                uiwait(msgbox(['Number of rows in 2D tracked csv file ' secondary2D_datafullpath{icams} ' does not match nframes in config file. Check and re-run main function'],'Problem detected'))
                return
            end
            temp = permute(reshape(data2d,nframes,2,nfeatures),[1 3 2]);
            temp = reshape(temp,nframes*nfeatures,2);
            if usingdlc                              
                data2d = undistortPoints(temp,stereoParams.CameraParameters2);
            else
                data2d = nan(size(temp));
                isnan_temp = isnan(temp);
                temp(isnan_temp(:,1),:) =  [];
                data2d(~isnan_temp(:,1),:)= undistortPoints(temp,stereoParams.CameraParameters2);
            end
            temp = reshape(data2d,nframes,nfeatures,2);
            data2d = permute(temp,[1 3 2]);
            data2d = data2d(:,:);
            if usingdlc
                disp(['Saving undistorted 2D data for primary camera at ' exp_path '/' exp_name ' /UndistortedData2d/Secondary' num2str(icams)])
                save([exp_path '/' exp_name '/UndistortedData2d/Secondary' num2str(icams) '/data2d.mat'],'data2d','data2dllh')                    
            else
                disp(['Saving undistorted 2D data for primary camera at ' exp_path '/' exp_name ' /UndistortedData2d/Secondary' num2str(icams)])
                save([exp_path '/' exp_name '/UndistortedData2d/Secondary' num2str(icams) '/data2d.mat'],'data2d')
            end
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
            
            if usingdlc
                [data2d,data2dllh,flag_mis] = load_dlcdata(primary2D_datafullpath{1,1},nframes,nfeatures,flag_mis);
            else
                [data2d,flag_mis] = load_otherdata(primary2D_datafullpath{1,1},nframes,nfeatures,flag_mis);
            end
            if flag_mis == 1 %case when the load_dlcdata function sets flag to 1
                uiwait(msgbox(['Number of rows in 2D tracked csv file ' primary2D_datafullpath{1,1} ' does not match nframes in config file. Check and re-run main function'],'Problem detected'))
                return
            end

        else

            if ~exist([exp_path '/' exp_name '/UndistortedData2d/Primary' '/data2d.mat'],'file') 
                disp('Starting undistortion on 2D data from primary camera')
                mkdir([exp_path '/' exp_name '/UndistortedData2d/Primary' ])
                if usingdlc
                    [data2d,data2dllh,flag_mis] = load_dlcdata(primary2D_datafullpath{1,1},nframes,nfeatures,flag_mis);
                else
                    [data2d,flag_mis] = load_otherdata(primary2D_datafullpath{1,1},nframes,nfeatures,flag_mis);
                end
                if flag_mis == 1 %case when the load_dlcdata function sets flag to 1
                    uiwait(msgbox(['Number of rows in 2D tracked csv file ' primary2D_datafullpath{1,1} ' does not match nframes in config file. Check and re-run main function'],'Problem detected'))
                    return
                end
                temp = permute(reshape(data2d,nframes,2,nfeatures),[1 3 2]);
                temp = reshape(temp,nframes*nfeatures,2);
                
                if usingdlc                              
                    data2d = undistortPoints(temp,stereoParams.CameraParameters2);
                else
                    data2d = nan(size(temp));
                    isnan_temp = isnan(temp);
                    temp(isnan_temp(:,1),:) =  [];
                    data2d(~isnan_temp(:,1),:)= undistortPoints(temp,stereoParams.CameraParameters2);                    
                end
                
                temp = reshape(data2d,nframes,nfeatures,2);
                data2d = permute(temp,[1 3 2]);
                data2d = data2d(:,:);
                if usingdlc
                    disp(['Saving undistorted 2D data for primary camera at ' exp_path '/' exp_name ' /UndistortedData2d/Primary'])
                    save([exp_path '/' exp_name '/UndistortedData2d/Primary' '/data2d.mat'],'data2d','data2dllh')                    
                else
                    disp(['Saving undistorted 2D data for primary camera at ' exp_path '/' exp_name ' /UndistortedData2d/Primary'])
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